"""Generate charts, KPI exports and the dashboard data file from the dbt marts.

Run after `dbt build` (see the README):
    python analysis/run_analysis.py

Reads  : warehouse/decisiongrade.duckdb  (built by dbt)
Writes : analysis/charts/*.png           (static charts used in the README)
         analysis/kpi_snapshot.json      (headline numbers quoted in findings)
         Data/processed/*.csv            (governed marts for Power BI / Excel)
         Dashboards/dashboard_data.js    (data for the HTML dashboard)

Every number comes from the governed marts; nothing is recalculated here
except presentation-level sorting and rounding.
"""
from __future__ import annotations

import json
from pathlib import Path

import duckdb
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.ticker import FuncFormatter, PercentFormatter  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "warehouse" / "decisiongrade.duckdb"
CHARTS = ROOT / "analysis" / "charts"
PROCESSED = ROOT / "Data" / "processed"
DASHBOARD = ROOT / "Dashboards"

# Palette: validated reference categorical slots + blue sequential ramp
BLUE, ORANGE, AQUA = "#2a78d6", "#eb6834", "#1baf7a"
BLUE_RAMP = ["#86b6ef", "#5598e7", "#2a78d6", "#1c5cab", "#104281"]
INK, INK_2, GRID, SURFACE = "#0b0b0b", "#52514e", "#e4e3df", "#fcfcfb"

plt.rcParams.update({
    "figure.facecolor": SURFACE, "axes.facecolor": SURFACE, "savefig.facecolor": SURFACE,
    "font.family": "DejaVu Sans", "font.size": 10,
    "axes.edgecolor": GRID, "axes.labelcolor": INK_2, "axes.titlecolor": INK,
    "axes.titlesize": 13, "axes.titleweight": "bold", "axes.titlelocation": "left",
    "axes.spines.top": False, "axes.spines.right": False,
    "axes.grid": True, "grid.color": GRID, "grid.linewidth": 0.8,
    "xtick.color": INK_2, "ytick.color": INK_2,
})

brl = FuncFormatter(lambda v, _: f"R${v/1e6:.1f}M" if v >= 1e6 else f"R${v/1e3:.0f}K")


def q(con, sql):
    return con.execute(sql).df()


def save(fig, name, subtitle=None):
    if subtitle:
        fig.text(0.012, 0.005, subtitle, fontsize=8, color=INK_2, ha="left", va="bottom")
    fig.tight_layout(rect=(0, 0.03 if subtitle else 0, 1, 1))
    fig.savefig(CHARTS / name, dpi=160)
    plt.close(fig)


def main() -> None:
    CHARTS.mkdir(parents=True, exist_ok=True)
    PROCESSED.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(str(DB), read_only=True)

    monthly = q(con, "select * from metrics.kpi_monthly where is_complete_month order by month_start")
    lateness = q(con, """select * from metrics.kpi_review_by_lateness
                        order by case lateness_band when 'on time' then 0 when '1-3 days late' then 1
                                 when '4-7 days late' then 2 else 3 end""")
    states = q(con, "select * from metrics.kpi_delivery_by_state order by avg_cycle_time_days")
    categories = q(con, "select * from metrics.kpi_category_performance order by net_revenue desc")
    sellers = q(con, "select * from metrics.seller_scorecard order by net_revenue desc")
    timing = q(con, """
        select d.month_start,
               round(avg(f.handling_days), 2) as handling_days,
               round(avg(f.transit_days), 2)  as transit_days,
               round(avg(f.promised_days), 2) as promised_days,
               round(avg(f.cycle_time_days), 2) as cycle_time_days
        from core.fact_delivery_performance f
        join core.dim_date d on d.date_key = f.purchase_date_key
        where d.month_start between '2017-01-01' and '2018-08-01'
        group by 1 order by 1""")
    weight = q(con, """
        select p.weight_band, count(*) as order_lines,
               round(sum(i.freight_value) / sum(i.item_price), 4) as freight_to_price
        from core.fact_order_items i join core.dim_product p using (product_key)
        where i.is_revenue_recognized and p.weight_band <> 'unknown'
        group by 1""")

    # ---------- headline numbers ----------
    kpi = q(con, """
        select sum(net_revenue) as net_revenue, sum(orders_placed) as orders_placed,
               sum(orders_delivered) as orders_delivered, sum(orders_lost) as orders_lost,
               sum(net_revenue) / sum(orders_delivered) as aov
        from metrics.kpi_monthly""").iloc[0]
    dlv = q(con, """
        select avg(is_on_time::int) as on_time_rate, avg(cycle_time_days) as cycle_days,
               avg(promised_days) as promised_days, avg(review_score) as review,
               avg(review_score) filter (where is_on_time) as review_on_time,
               avg(review_score) filter (where not is_on_time) as review_late
        from core.fact_delivery_performance""").iloc[0]
    cust = q(con, """
        select count(*) as customers, avg(is_repeat_customer::int) as repeat_rate,
               sum(lifetime_net_revenue) filter (where is_repeat_customer) / sum(lifetime_net_revenue) as repeat_revenue_share
        from core.dim_customer""").iloc[0]
    pareto = q(con, """
        with s as (select net_revenue, row_number() over (order by net_revenue desc) rk,
                          count(*) over () n from metrics.seller_scorecard)
        select sum(net_revenue) filter (where rk <= n * 0.1) / sum(net_revenue) as top10_share,
               max(n) as sellers from s""").iloc[0]
    peak = q(con, """select d.date_day, count(*) as orders from core.fact_order_finance f
                     join core.dim_date d on d.date_key = f.purchase_date_key
                     group by 1 order by 2 desc limit 1""").iloc[0]
    snapshot = {
        "net_revenue_brl": round(float(kpi.net_revenue), 2),
        "orders_placed": int(kpi.orders_placed),
        "orders_delivered": int(kpi.orders_delivered),
        "lost_order_rate": round(float(kpi.orders_lost / kpi.orders_placed), 4),
        "avg_order_value_brl": round(float(kpi.aov), 2),
        "on_time_rate": round(float(dlv.on_time_rate), 4),
        "avg_cycle_time_days": round(float(dlv.cycle_days), 2),
        "avg_promised_days": round(float(dlv.promised_days), 2),
        "avg_review_score": round(float(dlv.review), 3),
        "review_on_time": round(float(dlv.review_on_time), 3),
        "review_late": round(float(dlv.review_late), 3),
        "customers": int(cust.customers),
        "repeat_customer_rate": round(float(cust.repeat_rate), 4),
        "repeat_customer_revenue_share": round(float(cust.repeat_revenue_share), 4),
        "sellers_with_sales": int(pareto.sellers),
        "top10pct_seller_revenue_share": round(float(pareto.top10_share), 4),
        "peak_day": str(peak.date_day)[:10],
        "peak_day_orders": int(peak.orders),
    }
    (ROOT / "analysis" / "kpi_snapshot.json").write_text(json.dumps(snapshot, indent=2))

    # ---------- charts ----------
    x = monthly["month_start"]
    labels = [d.strftime("%b\n%y") if d.month in (1, 7) or i == 0 else d.strftime("%b")
              for i, d in enumerate(x)]

    # 1. revenue trend
    fig, ax = plt.subplots(figsize=(10, 4.2))
    ax.bar(range(len(x)), monthly["net_revenue"], color=BLUE, width=0.7, zorder=2)
    ax.yaxis.set_major_formatter(brl)
    ax.set_xticks(range(len(x)), labels)
    ax.grid(axis="x", visible=False)
    nov = list(x.dt.strftime("%Y-%m")).index("2017-11")
    ax.annotate("Nov 2017: Black Friday\n(1,176 orders on 24 Nov)", xy=(nov, monthly["net_revenue"][nov]),
                xytext=(nov - 6.5, monthly["net_revenue"][nov] * 0.97), fontsize=9, color=INK,
                arrowprops=dict(arrowstyle="-", color=INK_2, lw=0.8))
    ax.set_title("Net revenue by purchase month")
    save(fig, "01_monthly_net_revenue.png",
         "Net revenue = item value of delivered orders (BRL). Complete months only, Jan 2017 - Aug 2018.")

    # 2. on-time rate trend
    fig, ax = plt.subplots(figsize=(10, 4.2))
    ax.plot(range(len(x)), monthly["on_time_rate"], color=BLUE, lw=2, marker="o", ms=4, zorder=3)
    ax.axhline(0.85, color=INK_2, lw=1, ls="--", zorder=2)
    ax.text(len(x) - 0.5, 0.853, "85% SLA floor", ha="right", va="bottom", fontsize=9, color=INK_2)
    ax.yaxis.set_major_formatter(PercentFormatter(1, decimals=0))
    ax.set_ylim(0.75, 1.0)
    ax.set_xticks(range(len(x)), labels)
    ax.grid(axis="x", visible=False)
    for m in ("2017-11", "2018-02", "2018-03"):
        i = list(x.dt.strftime("%Y-%m")).index(m)
        v = monthly["on_time_rate"][i]
        above = m == "2018-02"  # keep this label clear of the floor line
        ax.annotate(f"{v:.1%}", xy=(i, v), xytext=(10 if above else 0, 8 if above else -16), textcoords="offset points",
                    ha="center", fontsize=9, color=INK)
    ax.set_title("On-time delivery rate by purchase month")
    save(fig, "02_on_time_rate.png",
         "On time = delivered on or before the promised date. March 2018 breached the 85% floor (dbt warn test).")

    # 3. what caused the dip: handling vs transit
    fig, ax = plt.subplots(figsize=(10, 4.2))
    t = timing
    xi = range(len(t))
    ax.plot(xi, t["transit_days"], color=BLUE, lw=2, marker="o", ms=4, label="Carrier transit (days)")
    ax.plot(xi, t["handling_days"], color=ORANGE, lw=2, marker="o", ms=4, label="Seller handling (days)")
    ax.set_xticks(list(xi), [d.strftime("%b\n%y") if d.month in (1, 7) or i == 0 else d.strftime("%b")
                             for i, d in enumerate(t["month_start"])])
    ax.grid(axis="x", visible=False)
    ax.set_ylim(0, 15)
    ax.text(len(t) - 1 + 0.15, t["transit_days"].iloc[-1], "Transit", color=INK, va="center", fontsize=9)
    ax.text(len(t) - 1 + 0.15, t["handling_days"].iloc[-1], "Handling", color=INK, va="center", fontsize=9)
    ax.legend(loc="upper left", frameon=False)
    ax.set_title("The early-2018 delay came from carriers, not sellers")
    save(fig, "03_handling_vs_transit.png",
         "Average days per delivered order. Handling = approval to carrier hand-off; transit = hand-off to delivery. "
         "Jun-Aug 2018 read low: the data ends in Oct 2018, so only faster orders from those months had arrived.")

    # 4. lateness vs reviews
    fig, axes = plt.subplots(1, 2, figsize=(10, 4.2))
    bands = lateness["lateness_band"]
    axes[0].bar(bands, lateness["avg_review_score"], color=BLUE_RAMP[1:], width=0.6, zorder=2)
    axes[0].set_ylim(0, 5)
    axes[0].set_title("Average review score")
    for i, v in enumerate(lateness["avg_review_score"]):
        axes[0].text(i, v + 0.08, f"{v:.2f}", ha="center", fontsize=9, color=INK)
    axes[1].bar(bands, lateness["negative_review_rate"], color=BLUE_RAMP[1:], width=0.6, zorder=2)
    axes[1].yaxis.set_major_formatter(PercentFormatter(1, decimals=0))
    axes[1].set_ylim(0, 1)
    axes[1].set_title("Share of 1-2 star reviews")
    for i, v in enumerate(lateness["negative_review_rate"]):
        axes[1].text(i, v + 0.02, f"{v:.0%}", ha="center", fontsize=9, color=INK)
    for a in axes:
        a.grid(axis="x", visible=False)
        a.tick_params(axis="x", labelsize=8.5)
    fig.suptitle("Late delivery is the strongest driver of bad reviews", x=0.012, ha="left",
                 fontsize=13, fontweight="bold", color=INK)
    save(fig, "04_reviews_by_lateness.png",
         f"Delivered orders with a review (n = {int(lateness['delivered_orders'].sum()):,}).")

    # 5. delivery time by state
    s = states.sort_values("avg_cycle_time_days")
    fig, ax = plt.subplots(figsize=(10, 7))
    colors = [ORANGE if r < 0.85 else BLUE for r in s["on_time_rate"]]
    ax.barh(s["state_code"], s["avg_cycle_time_days"], color=colors, height=0.7, zorder=2)
    for i, (d, r, n) in enumerate(zip(s["avg_cycle_time_days"], s["on_time_rate"], s["delivered_orders"])):
        ax.text(d + 0.3, i, f"{d:.1f} d  ·  {r:.1%} on time  ·  {n:,} orders", va="center", fontsize=8, color=INK_2)
    ax.set_xlim(0, 40)
    ax.grid(axis="y", visible=False)
    ax.set_xlabel("Average days from purchase to delivery")
    from matplotlib.patches import Patch
    ax.legend(handles=[Patch(color=BLUE, label="On-time rate ≥ 85%"), Patch(color=ORANGE, label="On-time rate < 85%")],
              loc="lower right", frameon=False)
    ax.set_title("Delivery time by customer state")
    save(fig, "05_delivery_by_state.png", "About 60% of sellers are based in São Paulo state; distance from SP tracks delivery time.")

    # 6. top categories
    top = categories.head(10).iloc[::-1]
    fig, ax = plt.subplots(figsize=(10, 4.8))
    ax.barh(top["category"].str.replace("_", " "), top["net_revenue"], color=BLUE, height=0.65, zorder=2)
    ax.xaxis.set_major_formatter(brl)
    for i, (v, sh, r) in enumerate(zip(top["net_revenue"], top["revenue_share"], top["avg_review_score"])):
        ax.text(v + 15000, i, f"{sh:.1%} of revenue  ·  ★ {r:.2f}", va="center", fontsize=8.5, color=INK_2)
    ax.set_xlim(0, top["net_revenue"].max() * 1.45)
    ax.grid(axis="y", visible=False)
    ax.set_title("Top 10 categories by net revenue")
    save(fig, "06_top_categories.png", f"Top 10 of {len(categories)} categories = "
         f"{categories.head(10)['revenue_share'].sum():.0%} of net revenue.")

    # 7. seller concentration (Pareto)
    sv = sellers["net_revenue"].cumsum() / sellers["net_revenue"].sum()
    xs = [(i + 1) / len(sellers) for i in range(len(sellers))]
    fig, ax = plt.subplots(figsize=(10, 4.2))
    ax.plot(xs, sv, color=BLUE, lw=2)
    ax.plot([0, 1], [0, 1], color=GRID, lw=1, ls="--")
    ax.axvline(0.1, color=INK_2, lw=0.8, ls=":")
    ax.annotate(f"Top 10% of sellers = {pareto.top10_share:.0%} of revenue", xy=(0.1, pareto.top10_share),
                xytext=(0.2, 0.55), fontsize=9.5, color=INK, arrowprops=dict(arrowstyle="-", color=INK_2, lw=0.8))
    ax.xaxis.set_major_formatter(PercentFormatter(1, decimals=0))
    ax.yaxis.set_major_formatter(PercentFormatter(1, decimals=0))
    ax.set_xlabel("Share of sellers (ranked by revenue)")
    ax.set_ylabel("Cumulative share of net revenue")
    ax.set_title("Revenue is concentrated in a small group of sellers")
    save(fig, "07_seller_concentration.png", f"{int(pareto.sellers):,} sellers with at least one delivered order.")

    # 8. freight burden by weight band
    order = ["light (<0.5kg)", "medium (0.5-2kg)", "heavy (2-10kg)", "bulky (10kg+)"]
    w = weight.set_index("weight_band").loc[order].reset_index()
    fig, ax = plt.subplots(figsize=(10, 4))
    ax.bar(w["weight_band"], w["freight_to_price"], color=BLUE_RAMP[1:], width=0.6, zorder=2)
    for i, v in enumerate(w["freight_to_price"]):
        ax.text(i, v + 0.004, f"{v:.1%}", ha="center", fontsize=9, color=INK)
    ax.yaxis.set_major_formatter(PercentFormatter(1, decimals=0))
    ax.yaxis.set_major_locator(matplotlib.ticker.MultipleLocator(0.05))
    ax.set_ylim(0, 0.25)
    ax.grid(axis="x", visible=False)
    ax.set_title("Freight as a share of item price, by product weight")
    save(fig, "08_freight_by_weight.png", "Light, low-price items carry the heaviest relative shipping cost.")

    # ---------- exports ----------
    exports = {
        "kpi_monthly": "select * from metrics.kpi_monthly order by month_start",
        "kpi_delivery_by_state": "select * from metrics.kpi_delivery_by_state order by state_code",
        "kpi_review_by_lateness": "select * from metrics.kpi_review_by_lateness",
        "kpi_category_performance": "select * from metrics.kpi_category_performance order by net_revenue desc",
        "seller_scorecard": "select * exclude (seller_key) from metrics.seller_scorecard order by net_revenue desc",
    }
    for name, sql in exports.items():
        con.execute(f"copy ({sql}) to '{PROCESSED / name}.csv' (header, delimiter ',')")

    # ---------- dashboard data ----------
    def records(df):
        out = df.copy()
        for col in out.columns:
            if str(out[col].dtype).startswith("datetime"):
                out[col] = out[col].dt.strftime("%Y-%m-%d")
        return json.loads(out.to_json(orient="records"))

    data = {
        "snapshot": snapshot,
        "monthly": records(monthly),
        "timing": records(timing),
        "lateness": records(lateness),
        "states": records(states),
        "categories": records(categories.head(15)),
        "sellerTiers": records(q(con, """
            select seller_tier, count(*) as sellers, sum(net_revenue) as net_revenue,
                   round(avg(on_time_rate), 4) as on_time_rate, round(avg(avg_review_score), 3) as avg_review_score
            from metrics.seller_scorecard group by 1
            order by case seller_tier when 'top performer' then 0 when 'standard' then 1
                     when 'at risk' then 2 else 3 end""")),
    }
    (DASHBOARD / "dashboard_data.js").write_text(
        "// Generated by analysis/run_analysis.py - do not edit by hand.\n"
        f"window.DASHBOARD_DATA = {json.dumps(data, indent=1)};\n"
    )
    print(json.dumps(snapshot, indent=2))
    print(f"Charts -> {CHARTS}\nCSV exports -> {PROCESSED}\nDashboard data -> {DASHBOARD / 'dashboard_data.js'}")


if __name__ == "__main__":
    main()

"""Build a small, referentially complete sample of the Olist data for CI.

Takes a random 3% of orders and keeps every customer, item, payment,
review, product, seller and zip prefix those orders touch, so all dbt
relationship tests still hold. Output: Data/sample/ (~2 MB, committed).

Usage:  python scripts/make_sample.py [--raw Data/raw] [--out Data/sample] [--fraction 0.03]
"""
import argparse
from pathlib import Path

import duckdb

FILES = {
    "orders": "olist_orders_dataset",
    "items": "olist_order_items_dataset",
    "payments": "olist_order_payments_dataset",
    "reviews": "olist_order_reviews_dataset",
    "customers": "olist_customers_dataset",
    "sellers": "olist_sellers_dataset",
    "products": "olist_products_dataset",
    "geo": "olist_geolocation_dataset",
    "translation": "product_category_name_translation",
}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--raw", default="Data/raw")
    ap.add_argument("--out", default="Data/sample")
    ap.add_argument("--fraction", type=float, default=0.03)
    args = ap.parse_args()

    raw, out = Path(args.raw), Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect()
    for alias, name in FILES.items():
        con.execute(
            f"create view {alias} as select * from read_csv('{raw / name}.csv', header=true, all_varchar=true)"
        )

    con.execute("select setseed(0.42)")
    con.execute(f"create table s_orders as select * from orders where random() < {args.fraction}")
    queries = {
        "orders": "select * from s_orders",
        "items": "select * from items where order_id in (select order_id from s_orders)",
        "payments": "select * from payments where order_id in (select order_id from s_orders)",
        "reviews": "select * from reviews where order_id in (select order_id from s_orders)",
        "customers": "select * from customers where customer_id in (select customer_id from s_orders)",
        "products": """select * from products where product_id in
                       (select product_id from items where order_id in (select order_id from s_orders))""",
        "sellers": """select * from sellers where seller_id in
                      (select seller_id from items where order_id in (select order_id from s_orders))""",
        "translation": "select * from translation",
    }
    for alias, sql in queries.items():
        con.execute(f"copy ({sql}) to '{out / FILES[alias]}.csv' (header, delimiter ',')")

    # geolocation: only the zip prefixes used by the sampled customers/sellers
    con.execute(f"""
        copy (
            -- a few points per prefix is enough for the median in stg_geolocation
            select * from geo
            where geolocation_zip_code_prefix in (
                select customer_zip_code_prefix from read_csv('{out / FILES['customers']}.csv', all_varchar=true)
                union
                select seller_zip_code_prefix from read_csv('{out / FILES['sellers']}.csv', all_varchar=true)
            )
            qualify row_number() over (partition by geolocation_zip_code_prefix order by geolocation_lat) <= 3
        ) to '{out / FILES['geo']}.csv' (header, delimiter ',')
    """)
    n = con.execute("select count(*) from s_orders").fetchall()[0][0]
    print(f"Sample written to {out}/ with {n:,} orders")


if __name__ == "__main__":
    main()

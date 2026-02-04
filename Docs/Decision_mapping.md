# Decision Mapping — DecisionGrade Analytics Platform

## Purpose

This document maps business decisions to supporting metrics and identifies risks associated with inaccurate data.

---

## Executive Decisions

| Decision | Primary Metric | Risk |
|----------|---------------|------|
| Revenue Forecasting | Net Revenue | Financial misguidance |
| Market Expansion | Regional Growth | Capital misallocation |
| Pricing Strategy | Gross Margin | Profit erosion |

---

## Operations Decisions

| Decision | Primary Metric | Risk |
|----------|---------------|------|
| Carrier Management | On-Time Delivery % | SLA penalties |
| Capacity Planning | Order Throughput | Bottlenecks |
| Staffing | Daily Volume | Service delays |

---

## Supply Chain Decisions

| Decision | Primary Metric | Risk |
|----------|---------------|------|
| Reordering | Inventory Turnover | Stockouts |
| Supplier Review | Lead Time | Supply disruption |
| SKU Optimization | GMROI | Dead stock |

---

## Finance & Compliance

| Decision | Primary Metric | Risk |
|----------|---------------|------|
| Reporting | Recognized Revenue | Audit risk |
| Budgeting | Cost per Order | Cost overruns |
| Cash Flow | AR Turnover | Liquidity issues |

---

## Metric Ownership

| Metric | Business Owner | Technical Owner |
|--------|---------------|-----------------|
| Net Revenue | CFO | Analytics Lead |
| On-Time Delivery | Ops Head | Data Platform |
| Inventory Turnover | Supply Director | Analytics Lead |

---

## Governance Rule

All production metrics must support documented business decisions and pass automated validation.


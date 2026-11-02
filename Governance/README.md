# Governance

How metrics are defined, tested, owned and changed in DecisionGrade.

| File | What it covers |
|---|---|
| [metric_definitions.md](metric_definitions.md) | Every KPI: formula, grain, source model, owner |
| [data_quality_rules.md](data_quality_rules.md) | The quality controls, why each exists, and what happens when one fails |
| [test_catalog.md](test_catalog.md) | All 90 automated dbt tests (generated from dbt metadata) |
| [change_management.md](change_management.md) | Branching, pull requests, required checks, code owners |
| [change_log.md](change_log.md) | Record of changes to models and metric definitions |

## Principles

1. **One definition per metric.** KPIs are calculated once in `DBT/models/marts/metrics/`. Dashboards read them and never recalculate them.
2. **Business rules live upstream.** Revenue recognition, SLA rules and data-quality quarantines are coded in `int_orders_enriched`, not in BI tools.
3. **Failures stop the pipeline.** Error-severity tests fail `dbt build`, which skips every downstream model and fails the CI check on the pull request.
4. **Every change is reviewed.** Changes reach `main` only through pull requests that pass CI and get code-owner approval.
5. **Lineage is visible.** The dbt docs site (`Docs/dbt_docs/index.html`) shows how every column flows from raw file to dashboard.

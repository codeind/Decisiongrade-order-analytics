# Change log

Changes to models, tests and metric definitions. Newest first.

| Date | Change | Metrics affected | PR |
|---|---|---|---|
| 2026-11 | Raw Olist files restored to `Data/raw/` so the pipeline runs straight after cloning | None | — |
| 2026-11 | Built dbt project: 8 staging, 4 intermediate, 8 core and 5 metric models; 90 tests; CI workflow | All (initial definitions) | #1 |
| 2026-11 | Quarantine rule for carrier dates earlier than purchase (166 orders) | Handling and transit time | #1 |
| 2026-11 | Dropped inventory turnover and GMROI: no inventory data in source | Removed | #1 |
| 2026-02 | Project scope, architecture and governance design documented | — | — |

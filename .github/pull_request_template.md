## What changed

<!-- One or two sentences. Link the issue if there is one. -->

## Type of change

- [ ] New model or column
- [ ] Change to a metric definition (needs metric owner approval)
- [ ] Data quality test added or changed
- [ ] Dashboard / analysis only (no change to dbt logic)
- [ ] Docs only

## Checklist

- [ ] `dbt build` passes locally on the full data (`make build`)
- [ ] New or changed models have tests in their `.yml` file
- [ ] `Governance/metric_definitions.md` updated if any KPI formula changed
- [ ] `Governance/change_log.md` has an entry for this change
- [ ] Lineage docs regenerated if models were added or renamed (`make docs`)

## Impact on reported numbers

<!-- Which KPIs move, and by how much? Paste before/after if relevant. Write "none" if no KPI changes. -->

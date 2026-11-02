# dbt project

```
DBT/
├── dbt_project.yml        # layers, schemas, test severities, business thresholds (vars)
├── profiles.yml           # dev (local DuckDB), cloud (MotherDuck), ci (sample data)
├── macros/                # raw_csv reader, schema naming
├── seeds/br_states.csv    # Brazilian states → region
├── models/
│   ├── staging/           # silver: 8 stg_ models, typed and cleaned
│   ├── intermediate/      # silver: 4 int_ models, business rules
│   └── marts/
│       ├── core/          # gold: 3 facts + 5 dimensions
│       └── metrics/       # gold: 5 governed KPI tables
└── tests/
    ├── critical/          # error severity: blocks the pipeline
    └── business/          # warn severity: monitored thresholds
```

## Run

```bash
cd DBT
dbt build --profiles-dir .                 # full data, local warehouse
dbt build --profiles-dir . --target ci     # sample data (what CI runs)
dbt build --profiles-dir . --target cloud  # MotherDuck (needs MOTHERDUCK_TOKEN)
dbt docs generate --static --profiles-dir .
```

`dbt build` runs seeds, models and tests in dependency order. When an error-severity test fails, dbt skips every model downstream of it.

# Run from the repository root.
.PHONY: setup data build test docs analysis all ci

setup:
	pip install -r requirements.txt

data:
	python scripts/download_data.py

build:
	cd DBT && dbt build --profiles-dir .

test:
	cd DBT && dbt test --profiles-dir .

docs:
	cd DBT && dbt docs generate --static --profiles-dir . && cp target/static_index.html ../Docs/dbt_docs/index.html

analysis:
	python analysis/run_analysis.py

all: build docs analysis

ci:
	cd DBT && dbt build --profiles-dir . --target ci

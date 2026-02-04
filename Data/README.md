# Data Directory — DecisionGrade Order Analytics System

## Purpose

This directory contains all datasets used to power the analytics platform.  
It serves as the foundation for all downstream transformations, metrics, and reporting.

All data in this directory is treated as source-of-truth input and is preserved in its original form.

No business logic is applied at this stage.

---

## Directory Structure

data/
│
├── raw/ # Original source files (immutable)
├── processed/ # Cleaned and standardized extracts (generated)
└── sources.md # Dataset documentation

---

## Raw Data Layer

The `raw/` directory contains unmodified source datasets extracted from the Olist Brazilian E-Commerce platform.

These files are preserved to:

- Enable auditability
- Support data lineage
- Allow full reprocessing
- Prevent accidental data loss

Files in this directory must never be edited manually.

---

## Processed Data Layer

The `processed/` directory contains derived datasets generated during exploratory analysis and validation.

These files are used for:

- Initial profiling
- Schema verification
- Quality checks
- Testing transformations

All files in this directory are reproducible from raw sources.

---

## Data Governance Principles

1. Raw data is immutable
2. All transformations are version-controlled
3. No business logic is embedded in raw files
4. All derived datasets must be reproducible
5. Source metadata must be documented

---

## Dataset Inventory

| Dataset | Description | Source |
|---------|-------------|--------|
| olist_customers | Customer master data | Olist Platform |
| olist_orders | Order records | Olist Platform |
| olist_order_items | Line items | Olist Platform |
| olist_payments | Payment records | Olist Platform |
| olist_reviews | Customer reviews | Olist Platform |
| olist_products | Product master | Olist Platform |
| olist_sellers | Seller master | Olist Platform |
| olist_geolocation | Location reference | Olist Platform |
| category_translation | Category mapping | Olist Platform |

---

## Usage Policy

This data is intended exclusively for analytics system development, testing, and demonstration.

It must not be used for commercial purposes or redistributed without proper authorization.

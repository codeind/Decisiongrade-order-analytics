# System Architecture — DecisionGrade Analytics Platform

## Design Principles

- Business logic is centralized and version-controlled.
- Dashboards do not define metrics.
- All transformations are auditable.

---

## Architecture Overview

Source Systems
→ Raw Data Layer
→ Staging Layer
→ Business Logic Layer
→ Analytics Marts
→ Metrics Layer
→ BI Tools

---

## Source Systems

- E-commerce Platform
- Warehouse Management System
- Inventory Management System
- CRM
- ERP

---

## Raw Data Layer

Purpose:
- Preserve original data
- Enable reprocessing
- Support audits

Characteristics:
- Immutable
- Metadata-enabled
- Source-aligned

---

## Staging Layer

Purpose:
- Standardize formats
- Normalize identifiers
- Validate schema

Activities:
- Type casting
- Column renaming
- Deduplication

---

## Business Logic Layer

Purpose:
- Resolve complex relationships
- Encode business rules
- Track lifecycle events

Activities:
- Order-shipment reconciliation
- Return handling
- SLA computation

---

## Analytics Marts

Fact Tables:
- fact_order_finance
- fact_delivery_performance
- fact_inventory_snapshot

Dimensions:
- dim_customer
- dim_product
- dim_location
- dim_date

---

## Metrics Layer

Purpose:
- Centralize KPIs
- Ensure consistency

Activities:
- Revenue calculation
- Performance ratios
- Trend analysis

---

## BI Layer

Purpose:
- Visualization
- Exploration

Constraints:
- No business logic
- No metric creation

---

## Governance

All changes require:

- Pull request
- Review
- Testing
- Documentation update


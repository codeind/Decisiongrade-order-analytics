# Business Context — DecisionGrade Order Analytics System

## Company Overview

This project represents a mid-size multi-channel retail company operating in the United States with annual revenue between $150M and $300M.

The company sells products through:

- Direct-to-Consumer website and mobile application
- Wholesale distributors
- Third-party retail partners

Operations are supported by centralized warehouses and regional fulfillment centers.

---

## Order-to-Delivery Process

1. Customer places an order.
2. Payment is authorized.
3. Inventory is reserved.
4. Order is routed to fulfillment center.
5. Shipment is created.
6. Package is dispatched.
7. Carrier delivers package.
8. Delivery confirmation is received.
9. Returns and refunds are processed.

---

## Inventory Management

- Inventory levels are updated continuously.
- Nightly inventory snapshots are recorded.
- Manual adjustments are performed for damaged or lost items.

---

## Revenue Recognition

- Sales recognizes revenue at order creation.
- Finance recognizes revenue at shipment confirmation.
- Refunds and returns are processed asynchronously.

---

## Data Sources

| System | Data Type | Frequency |
|--------|-----------|-----------|
| E-commerce Platform | Orders | Real-time |
| WMS | Shipments | Hourly |
| Inventory System | Stock Levels | Daily |
| CRM | Customer Data | Daily |
| ERP | Financial Records | Daily |

---

## Reporting Challenges

### Revenue Discrepancies
Different departments apply inconsistent revenue definitions, resulting in conflicting reports.

### Delivery Performance Conflicts
Operations and Customer Support use different delivery timelines, producing inconsistent SLA metrics.

### Inventory Visibility
Lack of standardized snapshots causes inaccurate stock assessments.

---

## Business Risks

| Risk | Impact |
|------|--------|
| Misreported revenue | Audit findings |
| SLA violations | Contract penalties |
| Stock imbalances | Lost revenue |
| Low data trust | Poor decisions |

---

## Project Objective

Establish a centralized, governed analytics platform that enforces consistent metric definitions and enables reliable business decision-making.


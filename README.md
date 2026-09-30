# Enterprise Data Warehouse & Analytics with SQL Server (Medallion Architecture)

[![SQL Server](https://img.shields.io/badge/Database-SQL%20Server-red?logo=microsoftsqlserver)](https://www.microsoft.com/sql-server)
[![T-SQL](https://img.shields.io/badge/Language-T--SQL-blue)](https://docs.microsoft.com/sql/t-sql/)
[![Architecture](https://img.shields.io/badge/Architecture-Medallion%20(Bronze%2FSilver%2FGold)-green)](#architecture-overview)
[![Dimensional Model](https://img.shields.io/badge/Model-Kimball%20Star%20Schema-purple)](#star-schema--data-mart-gold-layer)

An end-to-end Data Warehousing and Business Intelligence solution built on Microsoft SQL Server. This project models and delivers an enterprise analytics layer by integrating disparate raw datasets from CRM and ERP systems, applying rigorous ETL transformations, implementing data quality frameworks, and constructing an analytical Kimball Star Schema.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture Overview](#architecture-overview)
- [Data Pipeline Flow](#data-pipeline-flow)
- [Source Datasets](#source-datasets)
- [Medallion Layers Breakdown](#medallion-layers-breakdown)
  - [Bronze Layer (Raw Ingestion)](#1-bronze-layer-raw-ingestion)
  - [Silver Layer (Cleansing & Transformation)](#2-silver-layer-cleansing--transformation)
  - [Gold Layer (Analytical Star Schema)](#3-gold-layer-analytical-star-schema)
- [Data Quality & Testing Framework](#data-quality--testing-framework)
- [Repository Structure](#repository-structure)
- [Setup & Execution Guide](#setup--execution-guide)
- [Key SQL & Engineering Highlights](#key-sql--engineering-highlights)

---

## Project Overview

In real-world enterprise environments, business data is often fragmented across multiple systems (e.g., customer relationship systems, ERP financial systems), formatted inconsistently, and riddled with duplicates, malformed dates, and missing records.

This project delivers a centralized **Data Warehouse** (`DataWarehouse`) that:
1. **Ingests** unstructured and semi-structured CRM and ERP CSV exports into an ingestion landing zone (**Bronze**).
2. **Standardizes, deduplicates, cleanses, and enriches** the data using T-SQL stored procedures (**Silver**).
3. **Models** data into a Kimball Star Schema with dimension views and a fact view optimized for high-performance reporting and analytics (**Gold**).
4. **Verifies** data integrity at every step with an extensive suite of automated data quality tests.

---

## Architecture Overview

The project adheres to the **Medallion Architecture**, dividing the data estate into three structured layers of refinement:

```
[ CRM & ERP Source CSVs ]
            │
            ▼ (BULK INSERT via bronze.load_bronze)
┌──────────────────────────────────────────────┐
│                BRONZE LAYER                  │
│   Raw, unaltered copy of ingested sources    │
└──────────────────────────────────────────────┘
            │
            ▼ (ETL Transforms via silver.load_silver)
┌──────────────────────────────────────────────┐
│                SILVER LAYER                  │
│ Cleaned, conformed, standardized & validated │
└──────────────────────────────────────────────┘
            │
            ▼ (Analytical Modeling via Views)
┌──────────────────────────────────────────────┐
│                 GOLD LAYER                   │
│     Kimball Star Schema (Facts & Dims)       │
└──────────────────────────────────────────────┘
```

---

## Data Pipeline Flow

```mermaid
flowchart TD
    subgraph Sources["Source Systems"]
        CRM_Cust["CRM cust_info.csv"]
        CRM_Prd["CRM prd_info.csv"]
        CRM_Sales["CRM sales_details.csv"]
        ERP_Cust["ERP CUST_AZ12.csv"]
        ERP_Loc["ERP LOC_A101.csv"]
        ERP_Px["ERP PX_CAT_G1V2.csv"]
    end

    subgraph Bronze["Bronze Layer (Raw Staging)"]
        b_crm_cust["bronze.crm_cust_info"]
        b_crm_prd["bronze.crm_prd_info"]
        b_crm_sales["bronze.crm_sales_details"]
        b_erp_cust["bronze.erp_cust_az12"]
        b_erp_loc["bronze.erp_loc_a101"]
        b_erp_px["bronze.erp_px_cat_g1v2"]
    end

    subgraph Silver["Silver Layer (Cleaned & Standardized)"]
        s_crm_cust["silver.crm_cust_info"]
        s_crm_prd["silver.crm_prd_info"]
        s_crm_sales["silver.crm_sales_details"]
        s_erp_cust["silver.erp_cust_az12"]
        s_erp_loc["silver.erp_loc_a101"]
        s_erp_px["silver.erp_px_cat_g1v2"]
    end

    subgraph Gold["Gold Layer (Star Schema Mart)"]
        g_dim_cust["gold.dim_customers (Dimension)"]
        g_dim_prd["gold.dim_products (Dimension)"]
        g_fact_sales["gold.fact_sales (Fact)"]
    end

    CRM_Cust -->|BULK INSERT| b_crm_cust
    CRM_Prd -->|BULK INSERT| b_crm_prd
    CRM_Sales -->|BULK INSERT| b_crm_sales
    ERP_Cust -->|BULK INSERT| b_erp_cust
    ERP_Loc -->|BULK INSERT| b_erp_loc
    ERP_Px -->|BULK INSERT| b_erp_px

    b_crm_cust -->|Deduplication & Formatting| s_crm_cust
    b_crm_prd -->|Key Split & Date Range Windowing| s_crm_prd
    b_crm_sales -->|Date Casting & Price Validation| s_crm_sales
    b_erp_cust -->|Prefix Stripping & Gender Mapping| s_erp_cust
    b_erp_loc -->|Key Cleanup & Country Normalization| s_erp_loc
    b_erp_px -->|Category Trim & Maintenance Validation| s_erp_px

    s_crm_cust --> g_dim_cust
    s_erp_cust --> g_dim_cust
    s_erp_loc --> g_dim_cust

    s_crm_prd --> g_dim_prd
    s_erp_px --> g_dim_prd

    s_crm_sales --> g_fact_sales
    g_dim_cust -.->|Referential Join| g_fact_sales
    g_dim_prd -.->|Referential Join| g_fact_sales
```

---

## Source Datasets

The raw data is stored in the `datasets/` directory and partitioned across two business sources:

### 1. Customer Relationship Management (CRM)
- `datasets/source_crm/cust_info.csv`: Customer identification, full name, marital status, gender, and profile creation date.
- `datasets/source_crm/prd_info.csv`: Product catalog containing product keys, names, costs, product lines, and active validity date windows.
- `datasets/source_crm/sales_details.csv`: Historical sales transactions, tracking orders, order dates, ship dates, due dates, quantities, and price points.

### 2. Enterprise Resource Planning (ERP)
- `datasets/source_erp/CUST_AZ12.csv`: Demographic records providing customer birth dates and additional gender values with legacy `NAS` prefixes.
- `datasets/source_erp/LOC_A101.csv`: Geographical location mapping linking customer IDs (with hyphen formatting) to country codes.
- `datasets/source_erp/PX_CAT_G1V2.csv`: Product classification details mapping category keys to high-level categories, subcategories, and maintenance requirements.

---

## Medallion Layers Breakdown

### 1. Bronze Layer (Raw Ingestion)
- **Script**: `scripts/bronze/ddl_bronze.sql`
- **Stored Procedure**: `scripts/bronze/proc_load_bronze.sql`
- **Purpose**: Provides a low-latency raw landing zone without transformations, preserving original source fidelity.
- **Features**:
  - Drops and recreates 6 target tables inside the `bronze` schema.
  - Implements `TRUNCATE TABLE` followed by `BULK INSERT` for fast data ingestion.
  - Wraps execution in `BEGIN TRY...BEGIN CATCH` blocks.
  - Tracks and outputs detailed execution runtimes per table and across the entire batch.

### 2. Silver Layer (Cleansing & Transformation)
- **Script**: `scripts/silver/ddl_silver.sql`
- **Stored Procedure**: `scripts/silver/proc_load_silver.sql`
- **Purpose**: Cleanses, deduplicates, validates, and harmonizes Bronze data into structured analytical tables with an audit timestamp (`dwh_create_date`).
- **Core Transformations**:
  - **Deduplication**: Resolves duplicate customer IDs in `crm_cust_info` using `ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC)` to preserve only the most recent entry.
  - **Text Trimming & Standardization**: Strips unwanted leading and trailing whitespace; normalizes marital statuses (`M` -> `Married`, `S` -> `Single`) and gender values (`M` / `MALE` -> `Male`, `F` / `FEMALE` -> `Female`).
  - **Key Normalization**: Strips legacy system artifacts (e.g., removes `NAS` prefix from ERP `cid`, removes hyphens from location keys) to allow seamless cross-system joins.
  - **Derived Attribute Extraction**: Splits composite product keys into clean sub-attributes (`cat_id` and `prd_key`).
  - **SCD Historical Interval Handling**: Dynamically calculates product expiration dates (`prd_end_dt`) using the window function `LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1`.
  - **Data Type Casting & Cleansing**: Converts integer dates (e.g. `20230101`) to proper `DATE` types while filtering out zero or malformed lengths.
  - **Calculation Integrity**: Corrects sales values if missing or negative using `sls_quantity * ABS(sls_price)`, and backfills unit prices using `sls_sales / NULLIF(sls_quantity, 0)`.

### 3. Gold Layer (Analytical Star Schema)
- **Script**: `scripts/gold/ddl_gold.sql`
- **Purpose**: Surfaces clean, modeled business views optimized for reporting tools (Power BI, Tableau, Excel) via a dimensional Star Schema.

```mermaid
erDiagram
    dim_customers ||--o{ fact_sales : "places"
    dim_products ||--o{ fact_sales : "ordered in"

    dim_customers {
        bigint customer_key PK "Surrogate Key"
        int customer_id "CRM Customer ID"
        nvarchar customer_number "Business Key"
        nvarchar first_name
        nvarchar last_name
        nvarchar country "Enriched from ERP"
        nvarchar marital_status
        nvarchar gender "Consolidated CRM/ERP"
        date birthdate "Enriched from ERP"
        date create_date
    }

    dim_products {
        bigint product_key PK "Surrogate Key"
        int product_id "CRM Product ID"
        nvarchar product_number "Business Key"
        nvarchar product_name
        nvarchar category_id
        nvarchar category "Enriched from ERP"
        nvarchar subcategory "Enriched from ERP"
        nvarchar maintenance
        int cost
        nvarchar product_line
        date start_date
    }

    fact_sales {
        nvarchar order_number
        bigint product_key FK "Surrogate Key"
        bigint customer_key FK "Surrogate Key"
        date order_date
        date shiping_date
        date due_date
        int sales_amount "Measure"
        int quantity "Measure"
        int price "Measure"
    }
```

- **`gold.dim_customers`**: Combines CRM customer data with ERP demographics (`erp_cust_az12`) and locations (`erp_loc_a101`), assigning a surrogate `customer_key` via `ROW_NUMBER()`.
- **`gold.dim_products`**: Blends CRM product details with ERP catalog metadata (`erp_px_cat_g1v2`), filtering for currently active items (`prd_end_dt IS NULL`) and assigning a surrogate `product_key`.
- **`gold.fact_sales`**: Granular transaction fact view that joins `silver.crm_sales_details` to the customer and product dimensions via surrogate keys.

---

## Data Quality & Testing Framework

Comprehensive SQL test scripts ensure data accuracy, domain compliance, and referential integrity across the pipeline:

### Silver Layer Checks (`tests/quality_checks_silver.sql`)
- **Primary Key Uniqueness & Nullability**: Validates that all primary identifiers have zero duplicates and no nulls.
- **Whitespace Checks**: Identifies lingering leading/trailing whitespace across names, countries, and categories.
- **Domain Consistency**: Asserts standard categorical domains for marital status, gender, product lines, and countries.
- **Date & Chronology Sanity**:
  - Ensures customer birth dates and account creation dates are not in the future.
  - Ensures product start dates precede end dates.
  - Enforces order fulfillment chronology: `sls_order_dt <= sls_ship_dt <= sls_due_dt`.
- **Financial & Calculation Checks**: Verifies `sls_sales > 0`, `sls_quantity > 0`, `sls_price > 0`, and checks that `sls_sales = sls_quantity * ABS(sls_price)`.
- **Reconciliation Audit**: Computes unionized row counts across Bronze and Silver to evaluate ingestion and deduplication loss.

### Gold Layer Checks (`tests/quality_checks_gold.sql`)
- **Dimension Key Uniqueness**: Confirms surrogate keys `customer_key` and `product_key` are strictly unique.
- **Referential Integrity**: Detects orphaned sales transactions by testing for unmatched foreign keys (`WHERE p.product_key IS NULL OR c.customer_key IS NULL`).

---

## Repository Structure

```plaintext
Data-Analysis-Using-SQL/
├── README.md                           # Comprehensive project documentation
├── datasets/                           # Source raw data files
│   ├── source_crm/                     # CRM source exports
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/                     # ERP source exports
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
├── scripts/                            # DDL and ETL pipeline scripts
│   ├── init_database.sql               # Database and schema initialization script
│   ├── bronze/
│   │   ├── ddl_bronze.sql              # Table definitions for Bronze layer
│   │   └── proc_load_bronze.sql        # Stored procedure for Bronze BULK INSERT
│   ├── silver/
│   │   ├── ddl_silver.sql              # Table definitions for Silver layer
│   │   └── proc_load_silver.sql        # Stored procedure for Silver ETL cleaning
│   └── gold/
│       └── ddl_gold.sql                # Dimension and fact view definitions
└── tests/                              # Data quality and testing suites
    ├── quality_checks_silver.sql       # Quality assertions for Bronze & Silver layers
    └── quality_checks_gold.sql         # Quality checks for Gold Star Schema & RI
```

---

## Setup & Execution Guide

### Prerequisites
- **Database Engine**: Microsoft SQL Server (2016 or newer recommended).
- **Client Tool**: SQL Server Management Studio (SSMS), Azure Data Studio, or the VS Code mssql extension.
- **Permissions**: Permissions to create databases, schemas, views, stored procedures, and execute `BULK INSERT`.

### Execution Order

#### Step 1: Initialize Database & Schemas
Open and execute `scripts/init_database.sql` to create the `DataWarehouse` database and the three schemas (`bronze`, `silver`, `gold`):
```sql
USE master;
GO
-- Executes scripts/init_database.sql
```

#### Step 2: Build & Load Bronze Layer
1. Execute `scripts/bronze/ddl_bronze.sql` to create the raw ingestion tables.
2. In `scripts/bronze/proc_load_bronze.sql`, ensure the absolute file paths point to your local clone's `datasets/` folder.
3. Compile the stored procedure, then load the data:
```sql
USE DataWarehouse;
GO
EXEC bronze.load_bronze;
```

#### Step 3: Build & Load Silver Layer
1. Execute `scripts/silver/ddl_silver.sql` to create the cleansed tables.
2. Compile `scripts/silver/proc_load_silver.sql`.
3. Run the Silver ETL transformation:
```sql
USE DataWarehouse;
GO
EXEC silver.load_silver;
```

#### Step 4: Create Gold Views
Execute `scripts/gold/ddl_gold.sql` to create the Star Schema views (`gold.dim_customers`, `gold.dim_products`, and `gold.fact_sales`).

#### Step 5: Run Data Quality Checks
Execute the test suites in `tests/` to validate the warehouse:
- Run `tests/quality_checks_silver.sql` to verify deduplication, transformation, and reconciliation.
- Run `tests/quality_checks_gold.sql` to confirm surrogate key uniqueness and referential integrity.

---

## Key SQL & Engineering Highlights

- **Window Functions**: Leveraged `ROW_NUMBER() OVER(PARTITION BY ... ORDER BY ...)` for state-based deduplication and `LEAD()` for calculating historical active date ranges.
- **Defensive Data Handling**: Applied `NULLIF()`, `COALESCE()`, and `CASE` statements to guard against divide-by-zero errors, negative prices, and cross-system null values.
- **Robust Error Handling**: Structured stored procedures inside `BEGIN TRY ... BEGIN CATCH` blocks capturing `ERROR_MESSAGE()`, `ERROR_NUMBER()`, and `ERROR_STATE()`.
- **Pipeline Observability**: Integrated runtime metric logs using `GETDATE()` and `DATEDIFF()` to trace execution speed across each pipeline stage.
- **Enterprise Modeling Standards**: Adheres to dimensional modeling principles using surrogate integer keys, conformed dimensions, and separated fact metrics.

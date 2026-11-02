"""Download the Olist Brazilian E-Commerce dataset into Data/raw/.

The data is public on Kaggle (CC BY-NC-SA 4.0):
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Option A (this script): needs a Kaggle API token in ~/.kaggle/kaggle.json
    pip install kaggle
    python scripts/download_data.py
Option B: download the zip from the page above and unzip the CSVs into Data/raw/.
"""
from pathlib import Path

EXPECTED = [
    "olist_customers_dataset.csv",
    "olist_geolocation_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_products_dataset.csv",
    "olist_sellers_dataset.csv",
    "product_category_name_translation.csv",
]


def main() -> None:
    raw = Path(__file__).resolve().parents[1] / "Data" / "raw"
    raw.mkdir(parents=True, exist_ok=True)
    missing = [f for f in EXPECTED if not (raw / f).exists()]
    if not missing:
        print(f"All {len(EXPECTED)} files already in {raw}")
        return
    from kaggle.api.kaggle_api_extended import KaggleApi

    api = KaggleApi()
    api.authenticate()
    api.dataset_download_files("olistbr/brazilian-ecommerce", path=str(raw), unzip=True)
    still_missing = [f for f in EXPECTED if not (raw / f).exists()]
    if still_missing:
        raise SystemExit(f"Download finished but these files are missing: {still_missing}")
    print(f"Downloaded {len(EXPECTED)} files to {raw}")


if __name__ == "__main__":
    main()

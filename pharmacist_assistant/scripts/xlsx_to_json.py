#!/usr/bin/env python3
import json
import math
import sys
from pathlib import Path

import pandas as pd


def normalize_header_row(df: pd.DataFrame) -> pd.DataFrame:
    # Find the first row containing the header labels
    header_row_idx = None
    for i in range(min(20, len(df))):
        row = list(df.iloc[i].astype(str).fillna(""))
        if "New Drug Code" in row and "Greenrain Code" in row:
            header_row_idx = i
            break
    if header_row_idx is None:
        # fallback to third row based on sample
        header_row_idx = 2
    headers = [str(v).strip() for v in df.iloc[header_row_idx].tolist()]
    df2 = df.iloc[header_row_idx + 1 :].copy()
    df2.columns = headers
    return df2


def clean_value(v):
    # Normalize NaNs
    try:
        if isinstance(v, float) and math.isnan(v):
            return None
    except Exception:
        pass

    # Normalize pandas/numpy NaT/NaN
    try:
        import pandas as pd
        import numpy as np

        if isinstance(v, (pd.Timestamp,)):
            # Serialize dates to ISO8601 date string
            return v.isoformat()
        if isinstance(v, (np.floating,)):
            return float(v)
        if isinstance(v, (np.integer,)):
            return int(v)
        if pd.isna(v):
            return None
    except Exception:
        pass

    # Python datetime
    try:
        import datetime as _dt

        if isinstance(v, (_dt.datetime, _dt.date)):
            return v.isoformat()
    except Exception:
        pass

    if isinstance(v, str):
        v = v.strip()
        return v if v != "" else None
    return v


def map_dosage_to_category(dosage_form: str | None) -> str:
    if not dosage_form:
        return "Other"
    df = dosage_form.lower()
    if "tablet" in df:
        return "Tablets"
    if "capsule" in df:
        return "Capsules"
    if "injection" in df or "inj" in df or "ampoule" in df:
        return "Injections"
    if "syrup" in df or "solution" in df or "suspension" in df:
        return "Liquids"
    if "cream" in df or "ointment" in df or "gel" in df:
        return "Topicals"
    if "drops" in df or "eye" in df or "ear" in df or "nasal" in df:
        return "Drops"
    if "suppository" in df:
        return "Suppositories"
    if "powder" in df or "granule" in df:
        return "Powders"
    if "homeo" in df or "homeopathic" in df:
        return "Homeopathic"
    return "Other"


def compute_savings(public_price: float | None, pharmacy_price: float | None):
    if public_price is None or pharmacy_price is None:
        return {
            "difference": None,
            "percent": None,
        }
    try:
        diff = max(public_price - pharmacy_price, 0)
        percent = (diff / public_price * 100) if public_price > 0 else None
        return {"difference": round(diff, 2), "percent": round(percent, 2) if percent is not None else None}
    except Exception:
        return {"difference": None, "percent": None}


def convert(xlsx_path: Path, output_json: Path, head_limit: int | None = None):
    xl = pd.ExcelFile(xlsx_path)
    df = xl.parse(xl.sheet_names[0], header=None)
    df = normalize_header_row(df)

    # Normalize expected columns
    rename_map = {
        "New Drug Code": "drugCode",
        "Greenrain Code": "greenrainCode",
        "Insurance Plan": "insurancePlan",
        "New Tier": "tier",
        "Package Name": "packageName",
        "Generic Name": "genericName",
        "Strength": "strength",
        "Dosage Form": "dosageForm",
        "Package Size": "packageSize",
        "Package Price to Public": "pricePublic",
        "Package Price to Pharmacy": "pricePharmacy",
        "Unit Price to Public": "unitPricePublic",
        "Unit Price to Pharmacy": "unitPricePharmacy",
        "Status": "status",
        "Delete Effective Date": "deleteEffectiveDate",
        "Last Change": "lastChange",
        "Agent Name": "agentName",
        "Manufacturer Name": "manufacturerName",
    }
    # Drop columns not in rename_map
    df = df[[c for c in df.columns if c in rename_map]].rename(columns=rename_map)

    records = []
    for _, row in df.iterrows():
        rec = {k: clean_value(row.get(k)) for k in rename_map.values()}
        # Ensure numeric for prices when possible
        for price_field in [
            "pricePublic",
            "pricePharmacy",
            "unitPricePublic",
            "unitPricePharmacy",
        ]:
            v = rec.get(price_field)
            try:
                if v is not None:
                    rec[price_field] = float(v)
            except Exception:
                rec[price_field] = None

        rec["category"] = map_dosage_to_category(rec.get("dosageForm"))
        savings = compute_savings(rec.get("pricePublic"), rec.get("pricePharmacy"))
        rec["savingsDifference"] = savings["difference"]
        rec["savingsPercent"] = savings["percent"]
        records.append(rec)

        if head_limit is not None and len(records) >= head_limit:
            break

    output_json.parent.mkdir(parents=True, exist_ok=True)
    with output_json.open("w", encoding="utf-8") as f:
        json.dump(records, f, ensure_ascii=False)
    print(f"Wrote {len(records)} records to {output_json}")


def main():
    xlsx_path = Path("/workspace/F-PHM-001_250701-Daman-Drug-Formulary-DDF_V1R0.xlsx")
    output_json = Path("/workspace/pharmacist_assistant/assets/drugs.json")
    head_limit = None
    if len(sys.argv) > 1:
        try:
            head_limit = int(sys.argv[1])
        except Exception:
            pass
    convert(xlsx_path, output_json, head_limit=head_limit)


if __name__ == "__main__":
    main()


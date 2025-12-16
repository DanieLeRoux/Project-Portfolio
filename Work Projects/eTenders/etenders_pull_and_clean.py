"""
etenders_pull_and_clean (Delta + Master)

Fetch currently advertised tenders from the South African eTenders API,
clean/normalise them, and maintain:

1) MASTER Excel: append-only "all tenders ever seen" (deduped by bid_number)
2) DELTA Excel: "new tenders discovered this run only" (Power Automate-friendly table)

Typical daily run:
    python etenders_pull_and_clean.py --since-days 14

Optional:
    python etenders_pull_and_clean.py --since-days 21
    python etenders_pull_and_clean.py --stop-on-seen  (uses state file to early-stop paging)
"""

from __future__ import annotations

import os
import sys
import time
import json
import logging
import argparse
from typing import Optional, List, Dict, Any, Set

import requests
import pandas as pd
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# pylint: disable=abstract-class-instantiated

BASE_PAGE = "https://www.etenders.gov.za/Home/opportunities?id=1"
API_URL = "https://www.etenders.gov.za/Home/PaginatedTenderOpportunities"

# ---- tunables ----
PAGE_SIZE = 200
STATUS = 1  # 1 = "Currently Advertised"
ORDER_COL = 2
ORDER_DIR = "desc"
SLEEP_S = 0.4
TIMEOUT_S = 60
MAX_PAGES = 200  # safety brake; PAGE_SIZE*MAX_PAGES = max rows
# -------------------

# === Root Folder (your structure) ===
BASE_ROOT = r"C:\Users\HF\OneDrive - Henry Fagan\Desktop\Data Analytics\eTenders"

LOG_DIR = os.path.join(BASE_ROOT, "Logs")
OUTPUT_DIR = os.path.join(BASE_ROOT, "Outputs")
STATE_DIR = os.path.join(BASE_ROOT, "State")

LOG_PATH = os.path.join(LOG_DIR, "etenders_run.log")

# Files
MASTER_XLSX = os.path.join(OUTPUT_DIR, "etenders_master.xlsx")
DELTA_XLSX = os.path.join(OUTPUT_DIR, "etenders_delta.xlsx")
RAW_CSV = os.path.join(OUTPUT_DIR, "etenders_active_raw.csv")
RAW_XLSX = os.path.join(OUTPUT_DIR, "etenders_active_raw_full.xlsx")
STATE_FILE_DEFAULT = os.path.join(STATE_DIR, "seen_ids.json")
LOCK_FILE = os.path.join(STATE_DIR, "run.lock")


def setup_logging():
    """Create log directory and configure root logger with file + stdout handlers."""
    os.makedirs(LOG_DIR, exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)s | %(message)s",
        handlers=[
            logging.FileHandler(LOG_PATH, encoding="utf-8"),
            logging.StreamHandler(sys.stdout),
        ],
    )


def build_session() -> requests.Session:
    """Requests session with retry/backoff for flaky endpoints."""
    sess = requests.Session()
    sess.headers.update(
        {
            "User-Agent": "Mozilla/5.0",
            "Accept": "application/json, text/javascript, */*; q=0.01",
        }
    )

    retry = Retry(
        total=5,
        connect=5,
        read=5,
        status=5,
        backoff_factor=0.8,
        status_forcelist=(429, 500, 502, 503, 504),
        allowed_methods=frozenset(["GET"]),
        raise_on_status=False,
    )
    adapter = HTTPAdapter(max_retries=retry)
    sess.mount("https://", adapter)
    sess.mount("http://", adapter)
    return sess


def _normalize_bid(bid) -> str:
    """Normalize `bid_number` for stable comparison: strip whitespace and lowercase."""
    if bid is None:
        return ""
    return str(bid).strip().lower()


def _load_seen_ids(path: str) -> Set[str]:
    """Load seen `bid_number` IDs from a JSON state file."""
    try:
        if not os.path.exists(path):
            return set()
        with open(path, "r", encoding="utf-8") as fh:
            data = json.load(fh)
        return set(_normalize_bid(x) for x in (data or []))
    except (OSError, ValueError, TypeError) as e:
        logging.exception("Failed to load state file: %s -- %s", path, e)
        return set()


def _save_seen_ids(path: str, ids: Set[str]):
    """Persist sorted list of seen IDs to `path` (atomic write)."""
    try:
        norm = sorted(_normalize_bid(x) for x in ids)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        tmp = path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as fh:
            json.dump(norm, fh, ensure_ascii=False)
        os.replace(tmp, path)
    except (OSError, TypeError) as e:
        logging.exception("Failed to save state file: %s -- %s", path, e)


def acquire_lock(lock_path: str) -> None:
    """Simple lockfile to prevent concurrent runs."""
    os.makedirs(os.path.dirname(lock_path), exist_ok=True)
    if os.path.exists(lock_path):
        raise RuntimeError(f"Lock file exists (another run may be active): {lock_path}")
    with open(lock_path, "w", encoding="utf-8") as fh:
        fh.write(f"pid={os.getpid()}\n")


def release_lock(lock_path: str) -> None:
    try:
        if os.path.exists(lock_path):
            os.remove(lock_path)
    except OSError:
        logging.exception("Failed to remove lock file: %s", lock_path)


def fetch_etenders(
    since_date: Optional[pd.Timestamp] = None,
    seen_ids: Optional[Set[str]] = None,
) -> List[Dict[str, Any]]:
    """Fetch currently advertised tenders.

    If `since_date` is provided, stop paging when rows are older than `since_date`
    (assumes API returns results ordered newest->oldest).

    If `seen_ids` is provided, stop paging when a tender_No already in `seen_ids`
    is encountered (stop-on-seen behaviour).
    """
    sess = build_session()

    r = sess.get(BASE_PAGE, timeout=TIMEOUT_S)
    r.raise_for_status()

    all_rows: List[Dict[str, Any]] = []
    start = 0
    total = None
    page_count = 0

    base_params = {
        "draw": 1,
        "length": PAGE_SIZE,
        "start": 0,
        "status": STATUS,
        "order[0][column]": ORDER_COL,
        "order[0][dir]": ORDER_DIR,
        "search[value]": "",
        "search[regex]": "false",
    }

    stop_paging = False

    while True:
        page_count += 1
        if page_count > MAX_PAGES:
            logging.warning("MAX_PAGES reached; stopping pagination as a safety brake.")
            break

        params = dict(base_params, start=start)
        r = sess.get(API_URL, params=params, timeout=TIMEOUT_S)
        r.raise_for_status()

        try:
            j = r.json()
        except ValueError:
            j = json.loads(r.text)

        rows = j.get("data") or j.get("aaData") or []
        if total is None:
            total = j.get("recordsFiltered") or j.get("recordsTotal")

        if not rows:
            break

        for row in rows:
            if seen_ids:
                bid = row.get("tender_No")
                if bid is not None and _normalize_bid(bid) in seen_ids:
                    stop_paging = True
                    break

            if since_date is not None:
                raw = row.get("date_Published")
                rd = pd.to_datetime(raw, errors="coerce")
                if pd.notna(rd) and rd < since_date:
                    stop_paging = True
                    break

            all_rows.append(row)

        start += PAGE_SIZE

        if stop_paging:
            logging.info("Stopping early due to since_date/seen_ids condition (page %d)", page_count)
            break

        if total and start >= total:
            break
        if len(rows) < PAGE_SIZE:
            break

        time.sleep(SLEEP_S)

    logging.info("Fetched rows: %d (pages: %d, total: %s)", len(all_rows), page_count, total)
    return all_rows


def drop_duplicate_sources(df: pd.DataFrame) -> pd.DataFrame:
    """Prefer *_name fields where the API includes both."""
    df = df.copy()
    if "categories_name" in df.columns and "category" in df.columns:
        df.drop(columns=["category"], inplace=True)
    if "provinces_name" in df.columns and "province" in df.columns:
        df.drop(columns=["province"], inplace=True)
    return df


def map_and_clean(df: pd.DataFrame) -> pd.DataFrame:
    """Map columns to stable schema, coerce dates, and de-duplicate by bid_number."""
    colmap = {
        "tender_No": "bid_number",
        "description": "description",
        "categories_name": "category",
        "organ_of_State": "client",
        "provinces_name": "province",
        "closing_Date": "closing_date",
        "date_Published": "date_published",
        "status": "status",
        "type": "type",
        "compulsory_briefing_session": "briefing_session_details",
        "briefingVenue": "briefing_venue",
        "contactPerson": "contact_person",
        "email": "contact_email",
        "telephone": "contact_telephone",
        "briefingCompulsory": "briefing_compulsory",
        "validity": "tender_validity_period",
    }

    present = {k: v for k, v in colmap.items() if k in df.columns}
    if not present:
        raise RuntimeError("No expected columns found for mapping. eTenders schema likely changed.")

    mapped = df.rename(columns=present)

    desired_order = [
        "bid_number",
        "description",
        "category",
        "client",
        "province",
        "status",
        "type",
        "date_published",
        "closing_date",
        "briefing_session_details",
        "briefing_venue",
        "briefing_compulsory",
        "contact_person",
        "contact_email",
        "contact_telephone",
        "tender_validity_period",
    ]
    keep = [c for c in desired_order if c in mapped.columns]
    mapped = mapped[keep].copy()

    for c in ("closing_date", "date_published"):
        if c in mapped.columns:
            mapped[c] = pd.to_datetime(mapped[c], errors="coerce")

    if "bid_number" in mapped.columns:
        mapped["bid_number"] = mapped["bid_number"].fillna("").astype(str).str.strip()
        mapped = mapped[mapped["bid_number"].ne("")]

        # Sort newest first so dedupe keeps newest record
        if "date_published" in mapped.columns:
            mapped = mapped.sort_values("date_published", ascending=False, na_position="last")

        mapped = mapped.drop_duplicates(subset=["bid_number"], keep="first")

    return mapped


def write_excel_with_table(df: pd.DataFrame, path: str, sheet_name: str, table_name: str):
    """Write XLSX and create an Excel Table (Power Automate-friendly). Atomic replace."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp.xlsx"

    with pd.ExcelWriter(tmp, engine="xlsxwriter", datetime_format="yyyy-mm-dd") as writer:
        df.to_excel(writer, index=False, sheet_name=sheet_name)
        worksheet = writer.sheets[sheet_name]

        nrows, ncols = df.shape
        if ncols == 0:
            return

        columns = [{"header": col} for col in df.columns]

        # Excel table range is inclusive. Header row is 0. Last row is nrows (0 rows => 0).
        last_row = nrows
        worksheet.add_table(
            0,
            0,
            last_row,
            ncols - 1,
            {"name": table_name, "columns": columns},
        )
        worksheet.freeze_panes(1, 0)

    os.replace(tmp, path)


def load_master(path: str) -> pd.DataFrame:
    """Load master Excel if it exists; else empty DF."""
    if not os.path.exists(path):
        return pd.DataFrame()
    try:
        df = pd.read_excel(path, sheet_name="Master", engine="openpyxl")
        return df
    except Exception as e:
        logging.exception("Failed to read master file (%s): %s", path, e)
        return pd.DataFrame()


def append_and_dedupe_master(master: pd.DataFrame, new_rows: pd.DataFrame) -> pd.DataFrame:
    """Append new rows to master and dedupe by bid_number (keep newest by date_published)."""
    if master.empty:
        out = new_rows.copy()
    else:
        out = pd.concat([master, new_rows], ignore_index=True)

    if "bid_number" not in out.columns:
        return out

    out["bid_number"] = out["bid_number"].astype(str).str.strip()
    out = out[out["bid_number"].ne("")]

    if "date_published" in out.columns:
        out["date_published"] = pd.to_datetime(out["date_published"], errors="coerce")
        out = out.sort_values("date_published", ascending=False, na_position="last")

    out = out.drop_duplicates(subset=["bid_number"], keep="first")
    return out


def main():
    parser = argparse.ArgumentParser(description="Fetch and clean eTenders data (Delta + Master)")
    parser.add_argument(
        "--since-date",
        help="stop paging when rows are older than this date (parseable by pandas)",
    )
    parser.add_argument(
        "--since-days",
        type=int,
        help="stop paging when rows are older than N days (shorthand). Recommended: 14.",
    )
    parser.add_argument(
        "--stop-on-seen",
        action="store_true",
        help="stop paging early when a previously seen bid_number is encountered (uses --state-file)",
    )
    parser.add_argument(
        "--state-file",
        default=STATE_FILE_DEFAULT,
        help="path to JSON file storing seen bid_number IDs (used for stop-on-seen optimisation)",
    )
    args = parser.parse_args()

    setup_logging()
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(STATE_DIR, exist_ok=True)

    try:
        acquire_lock(LOCK_FILE)

        # since_date (for paging early-stop)
        if args.since_date:
            since_date = pd.to_datetime(args.since_date)
        elif args.since_days is not None:
            since_date = pd.Timestamp.today().normalize() - pd.Timedelta(days=args.since_days)
        else:
            since_date = None

        # Optional early-stop state
        seen_ids = _load_seen_ids(args.state_file) if args.stop_on_seen else None

        rows = fetch_etenders(
            since_date=since_date,
            seen_ids=seen_ids if args.stop_on_seen else None,
        )
        if not rows:
            logging.warning("No rows returned from eTenders.")
            return 0

        df_full = pd.json_normalize(rows, sep="_")
        logging.info("Raw rows fetched: %d | cols: %d", len(df_full), len(df_full.columns))

        # Raw outputs (optional but useful for debugging)
        df_full.to_csv(RAW_CSV, index=False)
        logging.info("Saved raw CSV: %s", RAW_CSV)

        with pd.ExcelWriter(RAW_XLSX, engine="xlsxwriter") as writer:
            df_full.to_excel(writer, index=False, sheet_name="Raw_Data")
        logging.info("Saved raw Excel: %s", RAW_XLSX)

        # Clean pipeline (NO weekly filter; reporting logic belongs in Power BI)
        df_for_clean = drop_duplicate_sources(df_full)
        mapped = map_and_clean(df_for_clean)

        # Load master and compute delta
        master_df = load_master(MASTER_XLSX)

        if not master_df.empty and "bid_number" in master_df.columns:
            master_ids = set(
                master_df["bid_number"].fillna("").astype(str).str.strip().str.lower().tolist()
            )
            mapped_ids = mapped["bid_number"].astype(str).str.strip().str.lower()
            delta_df = mapped[~mapped_ids.isin(master_ids)].copy()
        else:
            delta_df = mapped.copy()

        logging.info("Delta rows this run: %d", len(delta_df))

        # Write delta (Power Automate ingests this)
        write_excel_with_table(
            delta_df,
            DELTA_XLSX,
            sheet_name="Delta",
            table_name="tbl_delta",
        )
        logging.info("Saved delta Excel: %s | rows: %d", DELTA_XLSX, len(delta_df))

        # Update master (append-only, deduped)
        updated_master = append_and_dedupe_master(master_df, delta_df)
        write_excel_with_table(
            updated_master,
            MASTER_XLSX,
            sheet_name="Master",
            table_name="tbl_master",
        )
        logging.info("Saved master Excel: %s | rows: %d", MASTER_XLSX, len(updated_master))

        # Update state from the MASTER (keeps state consistent even if delta empty)
        master_seen = set(
            updated_master["bid_number"].fillna("").astype(str).str.strip().str.lower().tolist()
        )
        _save_seen_ids(args.state_file, master_seen)

        return 0

    except (requests.RequestException, ValueError, RuntimeError, OSError) as e:
        logging.exception("FAILED: %s", e)
        return 1

    finally:
        release_lock(LOCK_FILE)


if __name__ == "__main__":
    raise SystemExit(main())
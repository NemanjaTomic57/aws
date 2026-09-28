#!/usr/bin/env bash
#
# put_price_events.sh
# Sends randomly generated product price-change events (JSON) to an
# Amazon Data Firehose delivery stream using the AWS CLI.
#
# Usage:
#   ./put_price_events.sh <delivery-stream-name> [count] [delay-seconds]
#
# Examples:
#   ./put_price_events.sh my-price-stream            # 10 events, 1s apart
#   ./put_price_events.sh my-price-stream 100 0.2    # 100 events, 0.2s apart
#   ./put_price_events.sh my-price-stream 0          # run forever (Ctrl+C to stop)
#
# Region/profile come from your normal AWS CLI config, or set
# AWS_REGION / AWS_PROFILE before running.

set -euo pipefail

STREAM_NAME="${1:-}"
COUNT="${2:-10}"
DELAY="${3:-1}"

if [[ -z "$STREAM_NAME" ]]; then
  echo "Usage: $0 <delivery-stream-name> [count] [delay-seconds]" >&2
  exit 1
fi

command -v aws >/dev/null 2>&1 || { echo "AWS CLI not found in PATH" >&2; exit 1; }

# --- Sample catalog: "product_id|product_name|department" -------------------
PRODUCTS=(
  "P-1001|Organic Bananas (1 lb)|Produce"
  "P-1002|Avocado Hass|Produce"
  "P-1003|Baby Spinach 5oz|Produce"
  "P-2001|Whole Milk 1 Gallon|Dairy"
  "P-2002|Greek Yogurt Plain 32oz|Dairy"
  "P-2003|Sharp Cheddar 8oz|Dairy"
  "P-3001|Sourdough Loaf|Bakery"
  "P-3002|Blueberry Muffins 4pk|Bakery"
  "P-4001|Ground Coffee Dark Roast 12oz|Grocery"
  "P-4002|Spaghetti 1 lb|Grocery"
  "P-4003|Extra Virgin Olive Oil 500ml|Grocery"
  "P-5001|Paper Towels 6 Rolls|Household"
  "P-5002|Laundry Detergent 100oz|Household"
  "P-6001|Wireless Earbuds|Electronics"
  "P-6002|USB-C Charging Cable 6ft|Electronics"
  "P-7001|Chicken Breast 2 lb|Meat & Seafood"
  "P-7002|Atlantic Salmon Fillet|Meat & Seafood"
)

STORES=(
  "STORE-001 Downtown"
  "STORE-002 Northside"
  "STORE-003 Riverside"
  "STORE-004 Westfield Mall"
  "STORE-005 Airport Plaza"
)

# --- Helpers ---------------------------------------------------------------
random_price() {
  # Random price between 0.99 and 199.99
  local cents=$(( (RANDOM * 32768 + RANDOM) % 19901 + 99 ))
  printf "%d.%02d" $((cents / 100)) $((cents % 100))
}

random_id() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen | tr '[:upper:]' '[:lower:]'
  else
    printf "%04x%04x-%04x-%04x-%04x-%04x%04x%04x" \
      $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM
  fi
}

generate_event() {
  local product="${PRODUCTS[RANDOM % ${#PRODUCTS[@]}]}"
  local product_id product_name department
  IFS='|' read -r product_id product_name department <<< "$product"

  local store="${STORES[RANDOM % ${#STORES[@]}]}"
  local previous_price new_price
  previous_price="$(random_price)"
  new_price="$(random_price)"

  printf '{"event_id":"%s","event_type":"PRICE_CHANGE","timestamp":"%s","product_id":"%s","product_name":"%s","department":"%s","store":"%s","previous_price":%s,"PRICE":%s,"currency":"USD"}' \
    "$(random_id)" \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "$product_id" \
    "$product_name" \
    "$department" \
    "$store" \
    "$previous_price" \
    "$new_price"
}

# --- Main loop -------------------------------------------------------------
echo "Sending events to Firehose stream: $STREAM_NAME"
sent=0
while [[ "$COUNT" -eq 0 || "$sent" -lt "$COUNT" ]]; do
  event="$(generate_event)"

  # Trailing newline keeps records line-delimited in the destination (e.g. S3).
  # Base64-encode so it works with AWS CLI v2's default binary handling.
  data="$(printf '%s\n' "$event" | base64 | tr -d '\n')"

  record_id="$(aws firehose put-record \
    --delivery-stream-name "$STREAM_NAME" \
    --record "{\"Data\":\"$data\"}" \
    --query 'RecordId' --output text)"

  sent=$((sent + 1))
  echo "[$sent] $event"
  echo "      -> RecordId: ${record_id:0:24}..."

  sleep "$DELAY"
done

echo "Done. Sent $sent event(s)."

# SCRUM-15 — Show a restock date on sold-out products

## Summary
Sold-out products can carry an optional expected restock date (date only). catalog-service stores and returns it on the product list and product detail; wmd-bff passes it through; wmd-app shows "Back on <date>" instead of the sold-out label when the date is set and the product is not available. Additive only; existing clients keep working.

## Why tier 3
The request cannot be built as written without a human decision, so an exact contract cannot be fixed yet:
- It asks the BFF to pass the date through on "both product endpoints" with "no new endpoint", but wmd-bff (src/app.ts) exposes only GET /v1/catalog/products. There is no BFF product-detail route.
- It asks the app to show the date on "the list and the detail screen", but wmd-app (src/screens.tsx) has no product detail screen; ShopScreen is the only product view.
- It says sold-out products show "Sold out" today, but ShopScreen currently renders "Out of stock".

## Repositories and order
1. chfields/wmd-catalog-service: migration, model and both product routes.
2. chfields/wmd-bff: pass-through, plus a route test (and a detail route if the open question allows one).
3. chfields/wmd-app: Product type and rendering.
wmd-order-service, wmd-notification-service and wmd-deploy do not change.

## Contract (implement exactly)
catalog-service (owns the data, schema `catalog`):
- New migration `migrations/003_restock_date.sql`: `alter table products add column if not exists restock_date date;` nullable, no default. Existing rows get NULL. No other change.
- Model `Product` in app/main.py gains `restockDate: str | None` (ISO 8601 calendar date `YYYY-MM-DD`, no time or zone). Always present in the response; `null` when not set. Both SELECTs (list and detail) read `restock_date`.
- GET /v1/products and GET /v1/products/{product_id} return `restockDate` on every product. The stored value is returned as is, whatever the stock; it has no effect on `available`, `lowStock` or reservations.
- There is no API to set the date (out of scope); it is set in the database.
- No new error codes. openapi.json is regenerated.

wmd-bff:
- GET /v1/catalog/products returns the catalog body unchanged, so `restockDate` passes through as is (string or null). Do not add a response schema that strips unknown fields.
- Product detail: see Open question 1. Until it is answered, no new BFF route.

wmd-app:
- `Product` in src/api.ts gains `restockDate?: string | null` (optional, so older BFF responses still type-check).
- Product rendering: when `available` is true → unchanged ("N in stock"). When `available` is false and `restockDate` is a valid `YYYY-MM-DD` → "Back on <Mon D>" (en-US short month and day, e.g. "Back on Oct 20"), built from the date parts with no timezone shift. When `available` is false and `restockDate` is null, missing or invalid → the sold-out label (see Open question 3). The date is ignored whenever `available` is true.
- testIDs: keep the existing ones; the status text gets `stock-status-<id>`.

Core rules: catalog owns `restock_date` (service-data-ownership); the app reaches it only through the BFF (bff-only-public-api); correlation id and error shape are unchanged.

## Migrations and rollback
- Additive nullable column, applied once by the service's migration runner (app/db.py). Existing products unchanged.
- Rollback: deploy the previous images first (they ignore the column), then optionally `alter table products drop column if exists restock_date;`. No data is lost except restock dates.

## Tests
- catalog: tests/test_catalog.py — list and detail with restock_date NULL (returns `null`) and with a date (returns `"YYYY-MM-DD"`); an in-stock product with a date still returns it and stays `available: true`; the migration applies on an existing database.
- bff: test/bff.test.ts — GET /v1/catalog/products passes `restockDate` (a date string and null) through unchanged.
- app: three states — in stock ("N in stock"), sold out without a date (sold-out label), sold out with a date ("Back on Oct 20"); plus an in-stock product with a date shows no "Back on".

## Risks
- Date formatting with `new Date("YYYY-MM-DD")` parses as UTC and can show the previous day in western time zones; format from the string's parts.
- Changing "Out of stock" to "Sold out" would break e2e/journey.spec.ts if it asserts the old text.

## Open questions
1. Product detail in the BFF: add GET /v1/catalog/products/{id} (proxying catalog GET /v1/products/{id}, passing `unknown_product` 404 through), or keep "no new endpoint" and drop the detail requirement for the BFF?
2. Product detail in the app: there is no detail screen today. Build one (and how is it reached?), or limit the app change to the Shop list?
3. Sold-out label: rename the existing "Out of stock" to "Sold out", or keep "Out of stock" when there is no date?
4. Should a restock date in the past be shown, or treated as no date?

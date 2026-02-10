# Jasper API - Margarita Homes

Programmatic API for the Jasper AI assistant to manage property listings.

## Authentication

All endpoints require Bearer token authentication:

```
Authorization: Bearer <JASPER_API_TOKEN>
```

Set the token in Rails credentials:
```bash
EDITOR=nano bin/rails credentials:edit
```

Add:
```yaml
jasper:
  api_token: your-secure-token-here
```

## Endpoints

### Properties

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/jasper/properties` | List properties (with filters) |
| GET | `/api/jasper/properties/:id` | Get property details |
| POST | `/api/jasper/properties` | Create a property |
| PUT | `/api/jasper/properties/:id` | Update a property |
| DELETE | `/api/jasper/properties/:id` | Delete a property |
| POST | `/api/jasper/properties/bulk_create` | Bulk create properties |
| GET | `/api/jasper/properties/stats` | Property statistics |
| POST | `/api/jasper/properties/:id/add_photos` | Add photos to property |
| POST | `/api/jasper/properties/:id/mark_sold` | Mark property as sold |

#### Filters for GET /properties

- `zone_id` - Filter by zone
- `property_type` - house, apartment, condo, townhouse, land, commercial
- `status` - active, pending, sold, withdrawn
- `min_bedrooms` - Minimum bedrooms
- `min_price` / `max_price` - Price range
- `featured` - true/false
- `q` - Search in title, address, description
- `sort_by` - Field to sort by (default: created_at)
- `sort_dir` - asc/desc (default: desc)
- `page` / `per_page` - Pagination

#### Create Property Body

```json
{
  "property": {
    "title": "Beautiful 3BR Home",
    "address": "123 Main St, San Jose, CA",
    "description": "Spacious home with modern amenities...",
    "current_price_usd": 850000,
    "bedrooms": 3,
    "bathrooms": 2.5,
    "sqft": 1800,
    "lot_sqft": 5000,
    "property_type": "house",
    "status": "active",
    "zone_id": 1,
    "latitude": 37.3382,
    "longitude": -121.8863,
    "year_built": 2015,
    "featured": false,
    "listed_at": "2026-02-10"
  },
  "photos": [
    { "url": "https://...", "caption": "Front view", "is_primary": true },
    { "url": "https://...", "caption": "Kitchen" }
  ]
}
```

### Price History

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/jasper/properties/:id/price_histories` | Get price history |
| POST | `/api/jasper/properties/:id/price_histories` | Record price change |
| DELETE | `/api/jasper/properties/:id/price_histories/:history_id` | Delete history entry |

### Zones

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/jasper/zones` | List all zones with property counts |
| GET | `/api/jasper/zones/:id` | Get zone details |
| POST | `/api/jasper/zones` | Create a zone |
| PUT | `/api/jasper/zones/:id` | Update a zone |
| DELETE | `/api/jasper/zones/:id` | Delete a zone (if empty) |
| GET | `/api/jasper/zones/:id/properties` | List properties in zone |

### Market Data

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/jasper/market/summary` | Full market summary |
| GET | `/api/jasper/market/trends` | Historical trends (snapshots) |
| POST | `/api/jasper/market/snapshot` | Create market snapshot |

## Response Format

All responses follow this format:

```json
{
  "success": true,
  "data": { ... }
}
```

Errors:
```json
{
  "success": false,
  "error": "Error message",
  "errors": ["Validation error 1", "Validation error 2"]
}
```

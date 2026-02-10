# Margarita Homes

Zillow-like property price tracking app for Isla de Margarita, Venezuela.

## Tech Stack
- **Backend**: Rails 8 API-only (`api/`), Ruby 3.4.7, PostgreSQL 14
- **Frontend**: Vue 3 + Vite + TypeScript (`frontend/`), Tailwind CSS v4 + DaisyUI 5
- **Charts**: Apache ECharts
- **Maps**: Leaflet.js
- **Auth**: JWT + bcrypt (admin only)

## Commands
- **Rails server**: `cd api && bin/rails server` (port 3000)
- **Vue dev server**: `cd frontend && npm run dev` (port 5173)
- **DB reset**: `cd api && bin/rails db:reset`
- **Rails console**: `cd api && bin/rails console`

## Conventions
- API endpoints namespaced under `/api/v1/`
- Public endpoints: no auth required
- Admin endpoints: `/api/v1/admin/*` require JWT in Authorization header
- All prices in USD
- Use `jsonapi-serializer` for JSON responses
- Use `kaminari` for pagination
- Frontend composables in `src/composables/`
- Reusable components in `src/components/`
- Page components in `src/views/`
- DaisyUI component classes preferred over custom CSS

## Database
- Dev DB: `margarita_homes_development`
- Test DB: `margarita_homes_test`
- Admin login: `admin@margaritahomes.com` / `password123`

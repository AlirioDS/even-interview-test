# Rails API Boilerplate

Rails 8 API with PostgreSQL, Solid Queue, Solid Cache and Solid Cable using Docker.

## Clone and Config

```bash
git clone <repository>
cd rails_api_boiler_plate

# Configure environment variables
cp .env.example .env
```

## Start Services

```bash
# Start all services
docker compose up --build

# Run in background
docker compose up -d

# Stop services
docker compose down
```

API available at http://localhost:3000

## Create Migration

```bash
# Run migrations
docker compose exec rails-api bin/rails db:migrate
```

## Create Seed

```bash
# Run seeds
docker compose exec rails-api bin/rails db:seed

# Reset database and run seeds
docker compose exec rails-api bin/rails db:reset
```

## How to Run Tests

```bash
# Run all tests
docker compose exec rails-api bin/rails test

# Run specific test file
docker compose exec rails-api bin/rails test test/models/user_test.rb

# Run specific test
docker compose exec rails-api bin/rails test test/models/user_test.rb:10
```

## HealthCheck

```bash
# Check services status
docker compose ps

# API health endpoint
curl http://localhost:3000/up
```

## API Testing

### Public Releases (No Auth Required)

```bash
# Get all public releases
curl http://localhost:3000/api/public/releases

# Get public releases with pagination
curl "http://localhost:3000/api/public/releases?page=1&per_page=5"

# Filter by release type
curl "http://localhost:3000/api/public/releases?type=album"

# Filter by label
curl "http://localhost:3000/api/public/releases?label=Columbia"

# Filter past releases
curl "http://localhost:3000/api/public/releases?filter=past"

# Filter upcoming releases
curl "http://localhost:3000/api/public/releases?filter=upcoming"

# Filter by date range
curl "http://localhost:3000/api/public/releases?from=2000-01-01&to=2010-12-31"

# Combine filters
curl "http://localhost:3000/api/public/releases?type=album&label=Parlophone&per_page=5"

# Get single release
curl http://localhost:3000/api/public/releases/1
```

### Get Authorization Token

```bash
# Login to get JWT token
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email_address": "admin@example.com", "password": "password123"}'

# Response contains token:
# {"message": "Login successful", "token": "eyJhbGciOiJIUzI1NiJ9...", "user": {...}}
```

### Authenticated Releases (Full Data)

```bash
# Set token variable
TOKEN="your_jwt_token_here"

# Get releases with full data (includes catalog_number, albums, etc.)
curl http://localhost:3000/api/v1/releases \
  -H "Authorization: Bearer $TOKEN"

# Get releases with filters
curl "http://localhost:3000/api/v1/releases?type=album&per_page=5" \
  -H "Authorization: Bearer $TOKEN"

# Get single release with full data
curl http://localhost:3000/api/v1/releases/1 \
  -H "Authorization: Bearer $TOKEN"

# Public endpoint with auth (returns is_private: true and full data)
curl http://localhost:3000/api/public/releases \
  -H "Authorization: Bearer $TOKEN"
```

### Test Accounts

| Email | Password | Role |
|-------|----------|------|
| admin@example.com | password123 | admin |
| editor@example.com | password123 | editor |
| user@example.com | password123 | user |

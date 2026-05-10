# SmallFoodSpotFinder

Discover and support local, independent food businesses in your area. A location-based app that prioritizes family-owned and independent restaurants over large franchises.

## Vision

When looking for where to eat, big chains dominate thinking. SmallFoodSpotFinder aims to change that by making it effortless to discover hidden gems and support local businesses first.

## Tech Stack

- **Frontend**: SwiftUI (iOS)
- **Backend**: FastAPI (Python)
- **Database**: PostgreSQL (with PostGIS)
- **Maps**: Apple Maps
- **External API**: Yelp
- **Hosting**: Railway
- **CI/CD**: GitHub Actions

## Project Structure

```
SmallFoodSpotFinder/
├── backend/              # FastAPI backend service
│   ├── app/
│   │   ├── models/       # Database models
│   │   ├── routes/       # API endpoints
│   │   ├── services/     # Business logic
│   │   └── schemas/      # Request/response schemas
│   ├── tests/
│   ├── migrations/       # Database migrations
│   └── requirements.txt
├── frontend/             # iOS app
│   └── iOS/              # SwiftUI project
├── database/             # Database setup & migrations
│   ├── migrations/
│   ├── schemas/
│   └── seed_data/
├── .github/              # GitHub Actions CI/CD
│   └── workflows/

```

## MVP Features

- Scroll through independent/family-owned food spots
- Filter by distance from current location
- View essential info (name, address, hours)
- Get directions to restaurant
- Search for specific spots
- Filter by price level and cuisine type

## Future Features

- LLM-powered semantic search
- User reviews and ratings
- Delivery service integration
- Favorite locations
- Social sharing and recommendations

## Getting Started

See individual README files in `backend/` and `frontend/iOS/` for setup instructions.

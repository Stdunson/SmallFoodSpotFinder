# Small Food Spot Finder API Documentation

## Overview
FastAPI backend providing restaurant discovery and search functionality with rate limiting and comprehensive error handling.

---

## Installation & Setup

### Prerequisites
- Python 3.8+
- PostgreSQL database
- Google Places API key

### Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### Required Packages
- `fastapi==0.104.1` - Web framework
- `uvicorn==0.24.0` - ASGI server
- `slowapi==0.1.9` - Rate limiting
- `sqlalchemy==2.0.23` - ORM
- `psycopg2-binary==2.9.9` - PostgreSQL adapter
- `pydantic==2.5.0` - Data validation

### Environment Configuration
Create a `.env` file with:
```
DATABASE_URL=postgresql://user:password@localhost/small_food_spot_finder
GOOGLE_PLACES_API_KEY=your_api_key_here
```

### Running the Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Access API docs at: `http://localhost:8000/docs`

---

## API Endpoints

### 1. Discovery Recommendations
**Endpoint:** `POST /discovery`  
**Rate Limit:** 10 requests/minute  
**Purpose:** Get automatic restaurant recommendations for the discovery view (iOS app handles location only)

#### Request Body
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060
}
```

#### Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| latitude | float | Yes | User's latitude (-90 to 90) |
| longitude | float | Yes | User's longitude (-180 to 180) |

#### Response (200 OK)
```json
{
  "timestamp": "2026-05-10T14:30:00",
  "user_location": {
    "latitude": 40.7128,
    "longitude": -74.0060
  },
  "recommendations": [
    {
      "spot_number": 1,
      "name": "Local Italian Bistro",
      "type_of_food": "italian_restaurant",
      "price_category": "Moderate",
      "distance_miles": 0.5,
      "is_featured": true,
      "restaurant_id": 123
    },
    {
      "spot_number": 2,
      "name": "Thai Kitchen",
      "type_of_food": "thai_restaurant",
      "price_category": "Inexpensive",
      "distance_miles": 1.2,
      "is_featured": false,
      "restaurant_id": 124
    },
    {
      "spot_number": 3,
      "name": "Farm-to-Table Cafe",
      "type_of_food": "cafe",
      "price_category": "Moderate",
      "distance_miles": 1.8,
      "is_featured": false,
      "restaurant_id": 125
    }
  ]
}
```

#### Error Responses
- `400 Bad Request` - Invalid input parameters
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

---

### 2. Map/Search with Filters
**Endpoint:** `POST /search`  
**Rate Limit:** 20 requests/minute  
**Purpose:** Search restaurants with optional multi-select filters for map display

#### Request Body
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "categories": ["italian_restaurant", "pizza"],
  "price_categories": [1, 2],
  "distance_miles": 10,
  "search_query": "pasta"
}
```

#### Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| latitude | float | Yes | User's latitude (-90 to 90) |
| longitude | float | Yes | User's longitude (-180 to 180) |
| categories | array[string] | No | Restaurant categories (multi-select, e.g., ["italian_restaurant", "pizza"]) |
| price_categories | array[int] | No | Price levels (multi-select, 0=Free, 1=$, 2=$$, 3=$$$, 4=$$$$) |
| distance_miles | float | No | Search radius in miles (1-50, default: 10) |
| search_query | string | No | Text search query from search bar |

#### Response (200 OK)
```json
{
  "timestamp": "2026-05-10T14:35:00",
  "user_location": {
    "latitude": 40.7128,
    "longitude": -74.0060
  },
  "search_params": {
    "distance_miles": 10,
    "categories": ["italian_restaurant"],
    "price_categories": [1, 2]
  },
  "results": [
    {
      "restaurant_id": 123,
      "name": "Local Italian Bistro",
      "address": "123 Main St, New York, NY 10001",
      "latitude": 40.7150,
      "longitude": -74.0080,
      "category": "Italian",
      "price_level": 2,
      "price_label": "$$",
      "distance_miles": 0.5,
      "rating": 4.7,
      "is_featured": true,
      "type": "featured_spot"
    },
    {
      "restaurant_id": 126,
      "name": "Maria's Pasta House",
      "address": "456 Park Ave, New York, NY 10002",
      "latitude": 40.7300,
      "longitude": -74.0100,
      "category": "Italian",
      "price_level": 2,
      "price_label": "$$",
      "distance_miles": 2.1,
      "rating": 4.4,
      "is_featured": false,
      "type": "spot"
    }
  ],
  "total_count": 2
}
```

#### Error Responses
- `400 Bad Request` - Invalid input parameters
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

---

### 3. Restaurant Details
**Endpoint:** `POST /restaurant/details`  
**Rate Limit:** 30 requests/minute  
**Purpose:** Get restaurant details for the detail view (restaurant ID only input)

#### Request Body
```json
{
  "restaurant_id": 123
}
```

#### Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| restaurant_id | int | Yes | Database ID of the restaurant (≥1) |

#### Response (200 OK)
```json
{
  "address": {
    "full_address": "123 Main St, New York, NY 10001",
    "latitude": 40.7150,
    "longitude": -74.0080
  },
  "price_category": 2,
  "categories": ["Italian", "Fine Dining"],
  "hours": [
    {
      "day_of_week": "Monday",
      "opening_time": "11:00",
      "closing_time": "22:00",
      "is_open": true,
      "is_overnight": false
    },
    {
      "day_of_week": "Tuesday",
      "opening_time": "11:00",
      "closing_time": "22:00",
      "is_open": true,
      "is_overnight": false
    }
  ],
  "website": "https://www.localitalian.com",
  "phone": "+1-212-555-0123"
}
```

#### Error Responses
- `400 Bad Request` - Invalid restaurant ID
- `404 Not Found` - Restaurant not found
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

---

## Rate Limiting

All endpoints are rate-limited based on IP address using the `slowapi` library.

### Rate Limits by Endpoint
| Endpoint | Limit | Purpose |
|----------|-------|---------|
| `/discovery` | 10/minute | Automatic discovery requests |
| `/search` | 20/minute | User-initiated searches |
| `/restaurant/details` | 30/minute | Detail view requests |

### Rate Limit Headers
```
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 9
X-RateLimit-Reset: 1620000000
```

### Rate Limit Exceeded Response (429)
```json
{
  "detail": "Rate limit exceeded. Please try again later."
}
```

---

## Error Handling

### Standard Error Format
```json
{
  "detail": "Error message describing what went wrong"
}
```

### Status Codes
| Code | Meaning | Example |
|------|---------|---------|
| 200 | OK | Request successful |
| 400 | Bad Request | Invalid parameters |
| 404 | Not Found | Restaurant not found |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Server Error | Internal error |

---

## Response Format Guidelines

All responses include a `timestamp` field in ISO format for tracking.

### Location Object
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060
}
```

### Price Level Mapping
| Level | Label | Description |
|-------|-------|-------------|
| 0 | Free | No cost |
| 1 | $ | Inexpensive |
| 2 | $$ | Moderate |
| 3 | $$$ | Expensive |
| 4 | $$$$ | Very Expensive |
| null | Unknown | Not specified |

---

## Data Flow

1. **Discovery View**: User opens app → Auto-recommended 3 local spots
2. **Search View**: User enters location → Filtered search results on map
3. **Detail View**: User clicks restaurant → Full details displayed

---

## Testing

### Using cURL

```bash
# Discovery recommendations
curl -X POST "http://localhost:8000/discovery" \
  -H "Content-Type: application/json" \
  -d '{"latitude": 40.7128, "longitude": -74.0060, "num_recommendations": 3}'

# Search with filters
curl -X POST "http://localhost:8000/search" \
  -H "Content-Type: application/json" \
  -d '{"latitude": 40.7128, "longitude": -74.0060, "distance_miles": 10}'

# Get restaurant details
curl -X GET "http://localhost:8000/restaurant/123"
```

### Using Python Requests
```python
import requests

# Discovery
response = requests.post(
    "http://localhost:8000/discovery",
    json={
        "latitude": 40.7128,
        "longitude": -74.0060,
        "num_recommendations": 3
    }
)
print(response.json())

# Search
response = requests.post(
    "http://localhost:8000/search",
    json={
        "latitude": 40.7128,
        "longitude": -74.0060,
        "distance_miles": 10,
        "price_level": 2
    }
)
print(response.json())

# Details
response = requests.get("http://localhost:8000/restaurant/123")
print(response.json())
```

---

## Architecture

### Key Components
- **FastAPI App**: Request routing and validation
- **Slowapi Limiter**: Rate limiting
- **Pydantic Models**: Request/response serialization
- **User Flow Functions**: Business logic
- **Database Connection**: PostgreSQL via SQLAlchemy
- **Google Places API**: External data source

### Flow
```
Request → Rate Limiter → Pydantic Validation → Business Logic → DB/API → Response
```

---

## Performance Considerations

- Database queries filtered by distance and cached
- Google API calls only when database insufficient
- Results limited to prevent excessive data transfer
- IP-based rate limiting prevents abuse
- Locality filtering reduces false positives

---

## Future Enhancements

- [ ] Pagination support for large result sets
- [ ] User authentication and personalized recommendations
- [ ] Caching layer (Redis) for frequently accessed data
- [ ] WebSocket support for real-time updates
- [ ] Analytics and usage tracking
- [ ] Custom rate limit tiers based on subscription

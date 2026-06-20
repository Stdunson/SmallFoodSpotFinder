from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import JSONResponse
from starlette.requests import Request
from pydantic import BaseModel, Field
from typing import Optional, List
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import logging

from app.user_flow import (
    get_discovery_recommendations,
    search_restaurants_with_filters,
    get_restaurant_details
)

# Initialize FastAPI app
app = FastAPI(
    title="Small Food Spot Finder API",
    description="API for discovering local restaurants",
    version="1.0.0"
)

# Initialize rate limiter
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Exception handler for rate limiting
@app.exception_handler(RateLimitExceeded)
async def rate_limit_handler(request, exc):
    return JSONResponse(
        status_code=429,
        content={"detail": "Rate limit exceeded. Please try again later."}
    )


# REQUEST/RESPONSE MODELS

class LocationRequest(BaseModel):
    """Base model for location-based requests"""
    latitude: float = Field(..., ge=-90, le=90, description="User's latitude")
    longitude: float = Field(..., ge=-180, le=180, description="User's longitude")


class DiscoveryRequest(LocationRequest):
    """Discovery view request - location only"""
    pass


class RecommendationItem(BaseModel):
    """Single recommendation item"""
    spot_number: int
    name: str
    type_of_food: str
    price_category: str
    distance_miles: float
    is_featured: bool
    restaurant_id: int


class DiscoveryResponse(BaseModel):
    """Discovery view response"""
    timestamp: str
    user_location: dict
    recommendations: List[RecommendationItem]


class SearchRequest(BaseModel):
    """Map/Search view request"""
    latitude: float = Field(..., ge=-90, le=90, description="User's latitude")
    longitude: float = Field(..., ge=-180, le=180, description="User's longitude")
    categories: Optional[List[str]] = Field(
        default=None,
        description="Restaurant category filters (multi-select)"
    )
    price_categories: Optional[List[int]] = Field(
        default=None,
        description="Price level filters (multi-select, 0=Free, 1=$, 2=$$, 3=$$$, 4=$$$$)"
    )
    distance_miles: Optional[float] = Field(
        default=10,
        ge=1,
        le=50,
        description="Search radius in miles (optional)"
    )
    search_query: Optional[str] = Field(
        default=None,
        description="Text search query (search bar input)"
    )


class RestaurantResult(BaseModel):
    """Restaurant result for map/search view"""
    restaurant_id: Optional[int]
    name: str
    address: str
    latitude: float
    longitude: float
    category: str
    price_level: Optional[int]
    price_label: str
    distance_miles: float
    rating: Optional[float]
    is_featured: bool
    type: str


class SearchResponse(BaseModel):
    """Map/Search view response"""
    timestamp: str
    user_location: dict
    search_params: dict
    results: List[RestaurantResult]
    total_count: int


class RestaurantAddress(BaseModel):
    """Restaurant address"""
    full_address: str
    latitude: float
    longitude: float


class RestaurantContact(BaseModel):
    """Restaurant contact information"""
    phone: Optional[str] = None
    website: Optional[str] = None


class RestaurantHours(BaseModel):
    """Restaurant business hours"""
    day_of_week: str
    opening_time: Optional[str]
    closing_time: Optional[str]
    is_open: bool
    is_overnight: bool


class RestaurantDetailResponse(BaseModel):
    """Restaurant details for detail view"""
    address: RestaurantAddress
    price_category: Optional[int]
    categories: List[str]
    hours: Optional[List[RestaurantHours]] = None
    website: Optional[str] = None
    phone: Optional[str] = None


class DetailRequest(BaseModel):
    """Detail view request - restaurant ID only"""
    restaurant_id: int = Field(..., ge=1, description="Restaurant ID")


# ROUTES
@app.get("/", tags=["Health"])
async def root():
    """Health check endpoint"""
    return {"message": "Small Food Spot Finder API is running"}


@app.post(
    "/discovery",
    response_model=DiscoveryResponse,
    summary="Get Discovery Recommendations",
    description="Get automatic restaurant recommendations for the discovery view",
    tags=["Discovery"],
    status_code=200
)
@limiter.limit("10/minute")
async def discovery(request: Request, body: DiscoveryRequest):
    """
    Get automatic restaurant recommendations.
    
    Returns local restaurants nearby for quick preview cards.
    No filters - iOS app handles location only.
    
    Rate limit: 10 requests per minute
    
    Args:
        body: DiscoveryRequest with user location only
        
    Returns:
        DiscoveryResponse with recommendations
        
    Raises:
        HTTPException: 400 for invalid input, 429 for rate limit exceeded
    """
    try:
        logger.info(
            f"Discovery request for location ({body.latitude}, {body.longitude})"
        )
        
        result = get_discovery_recommendations(
            user_latitude=body.latitude,
            user_longitude=body.longitude
        )
        
        return result
        
    except ValueError as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error in discovery endpoint: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")


@app.post(
    "/search",
    response_model=SearchResponse,
    summary="Search Restaurants with Filters",
    description="Search for restaurants on the map view with optional filters",
    tags=["Search"],
    status_code=200
)
@limiter.limit("20/minute")
async def search(request: Request, body: SearchRequest):
    """
    Search for restaurants with optional filters.
    
    Supports filtering by distance, categories (multi-select), 
    price categories (multi-select), and text search.
    Displays results on map view.
    
    Rate limit: 20 requests per minute
    
    Args:
        body: SearchRequest with location and optional filter parameters
        
    Returns:
        SearchResponse with filtered results
        
    Raises:
        HTTPException: 400 for invalid input, 429 for rate limit exceeded
    """
    try:
        logger.info(
            f"Search request for location ({body.latitude}, {body.longitude}) "
            f"distance={body.distance_miles}mi, categories={body.categories}, "
            f"price_categories={body.price_categories}, search_query={body.search_query}"
        )
        
        # Handle multi-select categories - search with first category if provided
        category = body.categories[0] if body.categories else None
        
        # Handle multi-select price categories - search with first price if provided
        price_level = body.price_categories[0] if body.price_categories else None
        
        result = search_restaurants_with_filters(
            user_latitude=body.latitude,
            user_longitude=body.longitude,
            distance_miles=body.distance_miles,
            category=category,
            price_level=price_level,
            search_query=body.search_query
        )
        
        return result
        
    except ValueError as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error in search endpoint: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")


@app.post(
    "/restaurant/details",
    response_model=RestaurantDetailResponse,
    summary="Get Restaurant Details",
    description="Get details for a restaurant in the detail view",
    tags=["Details"],
    status_code=200
)
@limiter.limit("30/minute")
async def get_restaurant_detail(request: Request, body: DetailRequest):
    """
    Get detailed information about a restaurant.
    
    Returns details needed for the detail view:
    - Address with coordinates
    - Price category and restaurant categories
    - Business hours
    - Website and phone number
    
    Rate limit: 30 requests per minute
    
    Args:
        body: DetailRequest with restaurant ID only
        
    Returns:
        RestaurantDetailResponse with required details
        
    Raises:
        HTTPException: 400 for invalid input, 404 if not found, 429 for rate limit exceeded
    """
    try:
        logger.info(f"Detail request for restaurant ID {body.restaurant_id}")
        
        result = get_restaurant_details(body.restaurant_id)
        
        if result.get("error"):
            raise HTTPException(status_code=404, detail=result.get("error"))
        
        return result
        
    except HTTPException:
        raise
    except ValueError as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error in restaurant detail endpoint: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")


# ERROR HANDLERS
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    """Custom HTTP exception handler"""
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail}
    )


@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    """General exception handler"""
    logger.error(f"Unhandled exception: {exc}")
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"}
    )


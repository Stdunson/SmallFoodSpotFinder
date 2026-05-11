"""
User Flow Functions for Small Food Spot Finder

Main Flow:
    * 1. Check database for recent nearby restaurants 
    * 2. If enough results return, else, call Google Maps
    * 3. normalize maps data to what you need
    * 4. Classify and get the ones that are local
    * 5. Update db
    * 6. Return combined results for user
"""

from typing import List, Optional, Tuple
from datetime import datetime, timedelta
from math import radians, cos, sin, asin, sqrt
import logging

from app.database_connection import SessionLocal, Restaurant, RestaurantCategory
from app.api_connection import search_nearby, search_text, _convert_place_response_to_object
from app.data_objects import (
    search_nearby_object, 
    search_text_object, 
    circle, 
    place, 
    restaurant_object,
    language_code,
    region_code,
    rank_preference,
    place_types
)
from app.determine_locality import determine_locality

logger = logging.getLogger(__name__)

# Constants
DEFAULT_DISTANCE_MILES = 10
MIN_RESULTS_THRESHOLD = 20
CACHE_EXPIRY_DAYS = 7


def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Returns Distance in miles
    """
    # Convert decimal degrees to radians
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    
    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(dlon / 2) ** 2
    c = 2 * asin(sqrt(a))
    
    # Radius of earth in miles
    r = 3959
    return c * r


def get_nearby_restaurants_from_db(
    user_latitude: float,
    user_longitude: float,
    distance_miles: float = DEFAULT_DISTANCE_MILES,
    limit: int = MIN_RESULTS_THRESHOLD,
    category: Optional[str] = None,
    price_level: Optional[int] = None,
    recently_updated: bool = True
) -> List[restaurant_object]:
    session = SessionLocal()
    try:
        query = session.query(Restaurant)
        
        # Filter by cache recency if requested
        if recently_updated:
            cache_cutoff = datetime.utcnow() - timedelta(days=CACHE_EXPIRY_DAYS)
            query = query.filter(Restaurant.cache.has(
                Restaurant.cache.nearby_search_cached_at > cache_cutoff
            ))
        
        # Get all restaurants and filter by distance in memory
        restaurants = query.all()
        nearby_restaurants = []
        
        for restaurant in restaurants:
            distance = calculate_distance(
                user_latitude, 
                user_longitude, 
                float(restaurant.latitude), 
                float(restaurant.longitude)
            )
            
            if distance <= distance_miles:
                # Apply filters
                if price_level is not None and restaurant.price_level != price_level:
                    continue
                
                if category is not None:
                    has_category = any(
                        cat.category.lower() == category.lower() 
                        for cat in restaurant.categories
                    )
                    if not has_category:
                        continue
                
                nearby_restaurants.append(restaurant)
        
        # Sort by distance and limit results
        nearby_restaurants.sort(
            key=lambda r: calculate_distance(
                user_latitude,
                user_longitude,
                float(r.latitude),
                float(r.longitude)
            )
        )
        
        # Convert to restaurant_object
        result = []
        for restaurant in nearby_restaurants[:limit]:
            rest_obj = restaurant_object()
            rest_obj.id = restaurant.id
            rest_obj.uuid = restaurant.uuid
            rest_obj.name = restaurant.name
            rest_obj.address = restaurant.address
            rest_obj.longitude = float(restaurant.longitude)
            rest_obj.latitude = float(restaurant.latitude)
            rest_obj.price_level = restaurant.price_level
            rest_obj.is_featured = restaurant.is_featured
            rest_obj.google_place_id = restaurant.google_place_id
            rest_obj.website_url = restaurant.website_url
            rest_obj.image_url = restaurant.image_url
            rest_obj.source = restaurant.source
            result.append(rest_obj)
        
        return result
        
    finally:
        session.close()


def get_restaurants_from_google_api(
    user_latitude: float,
    user_longitude: float,
    distance_miles: float = DEFAULT_DISTANCE_MILES,
    max_results: int = 30,
    category: Optional[str] = None,
    price_level: Optional[int] = None,
    use_text_search: bool = False,
    search_query: Optional[str] = None
) -> List[place]:
    try:
        # Convert miles to meters for Google API
        radius_meters = int(distance_miles * 1609.34)
        
        if use_text_search and search_query:
            # Use text search for natural language queries
            search_request = search_text_object()
            search_request.textQuery = search_query or "restaurants"
            search_request.languageCode = language_code
            search_request.regionCode = region_code
            search_request.rankPreference = rank_preference
            search_request.maxResultCount = max_results
            
            if price_level is not None:
                search_request.priceLevels = [price_level]
            
            # Set location bias
            search_request.locationBias = {
                "circle": {
                    "center": {
                        "latitude": user_latitude,
                        "longitude": user_longitude,
                    },
                    "radius": radius_meters,
                }
            }
            
            response = search_text(search_request)
            
        else:
            # Use nearby search for radius-based search
            search_request = search_nearby_object()
            search_request.languageCode = language_code
            search_request.regionCode = region_code
            search_request.rankPreference = rank_preference
            search_request.maxResultCount = max_results
            search_request.includeFutureOpeningBusinesses = False
            
            # Set restaurant types
            if category and category in place_types:
                search_request.includedTypes = [category]
            else:
                # Default: search for restaurant types
                search_request.includedTypes = ["restaurant"]
            
            # Location restriction
            search_request.locationRestriction = circle(
                user_latitude, 
                user_longitude, 
                radius_meters
            )
            
            response = search_nearby(search_request)
        
        return response.places
        
    except Exception as e:
        logger.error(f"Error fetching from Google API: {e}")
        return []


def normalize_google_place_to_db_object(google_place: place, source: str = "google") -> restaurant_object:
    rest_obj = restaurant_object()
    
    rest_obj.name = google_place.name
    rest_obj.google_place_id = google_place.id
    rest_obj.address = google_place.formattedAddress or google_place.shortFormattedAddress
    rest_obj.website_url = google_place.websiteUri
    rest_obj.source = source
    
    # Extract location
    if google_place.location:
        rest_obj.latitude = google_place.location.get("latitude")
        rest_obj.longitude = google_place.location.get("longitude")
    
    # Price level mapping
    if google_place.priceLevel:
        price_map = {
            "PRICE_LEVEL_FREE": 0,
            "PRICE_LEVEL_INEXPENSIVE": 1,
            "PRICE_LEVEL_MODERATE": 2,
            "PRICE_LEVEL_EXPENSIVE": 3,
            "PRICE_LEVEL_VERY_EXPENSIVE": 4,
        }
        rest_obj.price_level = price_map.get(google_place.priceLevel, None)
    
    # Photo handling (use first photo if available)
    if google_place.photos and len(google_place.photos) > 0:
        rest_obj.image_url = google_place.photos[0].get("name") if isinstance(google_place.photos[0], dict) else None
    
    return rest_obj


def get_local_restaurants(restaurants: List[place]) -> List[place]:
    local_restaurants = []
    
    for restaurant in restaurants:
        try:
            if determine_locality(restaurant):
                local_restaurants.append(restaurant)
        except Exception as e:
            logger.warning(f"Error determining locality for {restaurant.name}: {e}")
            # If we can't determine, include it as potentially local
            local_restaurants.append(restaurant)
    
    return local_restaurants


def update_database_with_new_restaurants(
    restaurants: List[restaurant_object],
    user_id: Optional[int] = None
) -> List[int]:
    session = SessionLocal()
    inserted_ids = []
    
    try:
        for rest_obj in restaurants:
            # Check if restaurant already exists by google_place_id
            existing = session.query(Restaurant).filter(
                Restaurant.google_place_id == rest_obj.google_place_id
            ).first()
            
            if existing:
                # Update existing record
                existing.updated_at = datetime.utcnow()
                session.commit()
                inserted_ids.append(existing.id)
            else:
                # Create new record
                new_restaurant = Restaurant(
                    name=rest_obj.name,
                    address=rest_obj.address,
                    longitude=rest_obj.longitude,
                    latitude=rest_obj.latitude,
                    price_level=rest_obj.price_level,
                    google_place_id=rest_obj.google_place_id,
                    website_url=rest_obj.website_url,
                    image_url=rest_obj.image_url,
                    source=rest_obj.source or "google",
                    is_featured=rest_obj.is_featured,
                )
                session.add(new_restaurant)
                session.commit()
                inserted_ids.append(new_restaurant.id)
        
        return inserted_ids
        
    except Exception as e:
        session.rollback()
        logger.error(f"Error updating database with restaurants: {e}")
        return []
    finally:
        session.close()


def search_restaurants(
    user_latitude: float,
    user_longitude: float,
    distance_miles: float = DEFAULT_DISTANCE_MILES,
    num_results: int = 20,
    category: Optional[str] = None,
    price_level: Optional[int] = None,
    search_query: Optional[str] = None
) -> List[dict]:
    logger.info(
        f"Searching for restaurants at ({user_latitude}, {user_longitude}) "
        f"within {distance_miles} miles"
    )
    
    # Step 1: Check database for recent nearby restaurants
    db_restaurants = get_nearby_restaurants_from_db(
        user_latitude,
        user_longitude,
        distance_miles,
        limit=num_results,
        category=category,
        price_level=price_level
    )
    
    logger.info(f"Found {len(db_restaurants)} restaurants in database")
    
    results = []
    
    # Convert DB restaurants to result format
    for restaurant in db_restaurants:
        results.append({
            "id": restaurant.id,
            "name": restaurant.name,
            "address": restaurant.address,
            "latitude": restaurant.latitude,
            "longitude": restaurant.longitude,
            "price_level": restaurant.price_level,
            "website_url": restaurant.website_url,
            "image_url": restaurant.image_url,
            "rating": None,  # Will be populated from cache if available
            "source": restaurant.source,
            "is_featured": restaurant.is_featured,
            "is_local": True,  # DB restaurants are pre-verified
            "distance_miles": calculate_distance(
                user_latitude,
                user_longitude,
                restaurant.latitude,
                restaurant.longitude
            )
        })
    
    # Step 2: If not enough results, call Google API
    if len(results) < num_results:
        needed = num_results - len(results)
        logger.info(f"Need {needed} more results from Google API")
        
        # Get restaurants from Google API
        google_places = get_restaurants_from_google_api(
            user_latitude,
            user_longitude,
            distance_miles,
            max_results=needed + 10,  # Get extra to account for filtering
            category=category,
            price_level=price_level,
            use_text_search=search_query is not None,
            search_query=search_query
        )
        
        logger.info(f"Got {len(google_places)} results from Google API")
        
        # Step 3: Normalize and filter for local restaurants
        local_google_places = get_local_restaurants(google_places)
        logger.info(f"Filtered to {len(local_google_places)} local restaurants")
        
        # Convert to restaurant objects
        normalized_restaurants = [
            normalize_google_place_to_db_object(place_obj)
            for place_obj in local_google_places
        ]
        
        # Step 4: Update database
        inserted_ids = update_database_with_new_restaurants(normalized_restaurants)
        logger.info(f"Inserted/updated {len(inserted_ids)} restaurants in database")
        
        # Add Google results to response
        for place_obj in local_google_places:
            distance = calculate_distance(
                user_latitude,
                user_longitude,
                place_obj.location.get("latitude"),
                place_obj.location.get("longitude")
            ) if place_obj.location else None
            
            # Skip if already in results (check by name and distance)
            if any(
                r["name"].lower() == place_obj.name.lower() 
                for r in results
            ):
                continue
            
            results.append({
                "id": None,  # Will be assigned after DB insert
                "name": place_obj.name,
                "address": place_obj.formattedAddress or place_obj.shortFormattedAddress,
                "latitude": place_obj.location.get("latitude") if place_obj.location else None,
                "longitude": place_obj.location.get("longitude") if place_obj.location else None,
                "rating": place_obj.rating,
                "user_rating_count": place_obj.userRatingCount,
                "price_level": place_obj.priceLevel,
                "website_url": place_obj.websiteUri,
                "google_place_id": place_obj.id,
                "source": "google",
                "is_featured": False,
                "is_local": True,
                "distance_miles": distance
            })
    
    # Step 5: Combine and order results
    # Order by: featured (first), local (second), rating (third), distance (fourth)
    results.sort(
        key=lambda x: (
            not x.get("is_featured", False),  # Featured first
            not x.get("is_local", False),      # Local second
            -(x.get("user_rating_count", 0) or 0),  # Higher rating count
            x.get("distance_miles", float("inf")) or float("inf")  # Closer distance
        )
    )
    
    # Return only the requested number of results
    return results[:num_results]


def get_discovery_recommendations(
    user_latitude: float,
    user_longitude: float,
    num_recommendations: int = 3
) -> dict:
    """
    Get automatic recommendations for the Discovery View.
    
    Returns minimal information for quick preview cards:
    - Restaurant name
    - Type of food (category)
    - Price category
    - Distance
    - Featured status
    
    Args:
        user_latitude: User's latitude
        user_longitude: User's longitude
        num_recommendations: Number of spots to recommend (default 3)
        
    Returns:
        Dictionary with discovery view format:
        {
            "timestamp": ISO format datetime,
            "user_location": {
                "latitude": float,
                "longitude": float
            },
            "recommendations": [
                {
                    "spot_number": int,
                    "name": str,
                    "type_of_food": str,
                    "price_category": str,
                    "distance_miles": float,
                    "is_featured": bool,
                    "restaurant_id": int
                },
                ...
            ]
        }
    """
    logger.info(
        f"Getting discovery recommendations for ({user_latitude}, {user_longitude})"
    )
    
    # Get restaurants from database, prioritizing featured and local ones
    session = SessionLocal()
    try:
        restaurants = session.query(Restaurant).all()
        nearby_restaurants = []
        
        for restaurant in restaurants:
            distance = calculate_distance(
                user_latitude,
                user_longitude,
                float(restaurant.latitude),
                float(restaurant.longitude)
            )
            
            if distance <= DEFAULT_DISTANCE_MILES * 2.5:  # Broader search for discovery
                nearby_restaurants.append({
                    "db_obj": restaurant,
                    "distance": distance
                })
        
        # Sort by: featured first, then by distance
        nearby_restaurants.sort(
            key=lambda x: (not x["db_obj"].is_featured, x["distance"])
        )
        
        # Format response
        recommendations = []
        for idx, item in enumerate(nearby_restaurants[:num_recommendations], 1):
            restaurant = item["db_obj"]
            
            # Get primary category
            primary_category = "Restaurant"
            if restaurant.categories and len(restaurant.categories) > 0:
                primary_category = restaurant.categories[0].category
            
            # Convert price level to category
            price_categories = {
                0: "Free",
                1: "Inexpensive",
                2: "Moderate",
                3: "Expensive",
                4: "Very Expensive",
                None: "Unknown"
            }
            price_category = price_categories.get(restaurant.price_level, "Unknown")
            
            recommendations.append({
                "spot_number": idx,
                "name": restaurant.name,
                "type_of_food": primary_category,
                "price_category": price_category,
                "distance_miles": round(item["distance"], 1),
                "is_featured": restaurant.is_featured,
                "restaurant_id": restaurant.id
            })
        
        return {
            "timestamp": datetime.utcnow().isoformat(),
            "user_location": {
                "latitude": user_latitude,
                "longitude": user_longitude
            },
            "recommendations": recommendations
        }
        
    finally:
        session.close()


def search_restaurants_with_filters(
    user_latitude: float,
    user_longitude: float,
    distance_miles: float = DEFAULT_DISTANCE_MILES,
    category: Optional[str] = None,
    price_level: Optional[int] = None,
    search_query: Optional[str] = None
) -> dict:
    logger.info(
        f"Searching restaurants with filters: "
        f"category={category}, price_level={price_level}, "
        f"distance={distance_miles}mi"
    )
    
    # Use main search function to get results
    search_results = search_restaurants(
        user_latitude,
        user_longitude,
        distance_miles,
        num_results=50,  # Get more for map view
        category=category,
        price_level=price_level,
        search_query=search_query
    )
    
    price_labels = {
        0: "Free",
        1: "$",
        2: "$$",
        3: "$$$",
        4: "$$$$",
        None: "Unknown"
    }
    
    formatted_results = []
    for result in search_results:
        # Determine restaurant type
        rest_type = "spot"
        if result.get("is_featured"):
            rest_type = "featured_spot"
        
        formatted_results.append({
            "restaurant_id": result.get("id"),
            "name": result.get("name"),
            "address": result.get("address"),
            "latitude": result.get("latitude"),
            "longitude": result.get("longitude"),
            "category": "Restaurant",  # Will be populated from categories
            "price_level": result.get("price_level"),
            "price_label": price_labels.get(result.get("price_level"), "Unknown"),
            "distance_miles": round(result.get("distance_miles", 0), 1),
            "rating": result.get("rating"),
            "is_featured": result.get("is_featured", False),
            "type": rest_type
        })
    
    return {
        "timestamp": datetime.utcnow().isoformat(),
        "user_location": {
            "latitude": user_latitude,
            "longitude": user_longitude
        },
        "search_params": {
            "distance_miles": distance_miles,
            "category": category,
            "price_level": price_level
        },
        "results": formatted_results,
        "total_count": len(formatted_results)
    }


def get_restaurant_details(restaurant_id: int) -> dict:
    session = SessionLocal()
    try:
        restaurant = session.query(Restaurant).filter(
            Restaurant.id == restaurant_id
        ).first()
        
        if not restaurant:
            logger.warning(f"Restaurant with ID {restaurant_id} not found")
            return {
                "timestamp": datetime.utcnow().isoformat(),
                "error": "Restaurant not found",
                "restaurant_id": restaurant_id
            }
        
        # Get categories
        categories = [cat.category for cat in restaurant.categories]
        
        # Get business hours
        hours = None
        if restaurant.business_hours and len(restaurant.business_hours) > 0:
            biz_hour = restaurant.business_hours[0]
            day_names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            hours = {
                "day_of_week": day_names[biz_hour.day_of_week] if biz_hour.day_of_week < 7 else "Unknown",
                "opening_time": f"{biz_hour.opening_time // 100:02d}:{biz_hour.opening_time % 100:02d}" if biz_hour.opening_time else None,
                "closing_time": f"{biz_hour.closing_time // 100:02d}:{biz_hour.closing_time % 100:02d}" if biz_hour.closing_time else None,
                "is_open": biz_hour.is_open,
                "is_overnight": biz_hour.is_overnight
            }
        
        # Price level mapping
        price_labels = {
            0: "Free",
            1: "$",
            2: "$$",
            3: "$$$",
            4: "$$$$",
            None: "Unknown"
        }
        
        # Get cache for additional info (ratings, etc.)
        cache_info = {}
        if restaurant.cache:
            cache_info = {
                "is_local": restaurant.cache.is_local,
                "localness_cached_at": restaurant.cache.localness_cached_at.isoformat() if restaurant.cache.localness_cached_at else None
            }
        
        return {
            "timestamp": datetime.utcnow().isoformat(),
            "restaurant": {
                "restaurant_id": restaurant.id,
                "name": restaurant.name,
                "address": {
                    "full_address": restaurant.address,
                    "latitude": float(restaurant.latitude),
                    "longitude": float(restaurant.longitude)
                },
                "contact": {
                    "phone": restaurant.business_hours[0].restaurant.nationalPhoneNumber if restaurant.business_hours else None,
                    "website": restaurant.website_url
                },
                "details": {
                    "is_featured": restaurant.is_featured,
                    "categories": categories,
                    "price_level": restaurant.price_level,
                    "price_label": price_labels.get(restaurant.price_level, "Unknown"),
                    "rating": None,  # Can be populated from Google API if needed
                    "user_rating_count": None,
                    "is_local": cache_info.get("is_local")
                },
                "hours": hours,
                "services": {
                    "takeout": None,  # Can be populated from Google API
                    "delivery": None,
                    "dine_in": None
                },
                "image_url": restaurant.image_url,
                "source": restaurant.source,
                "created_at": restaurant.created_at.isoformat() if restaurant.created_at else None,
                "updated_at": restaurant.updated_at.isoformat() if restaurant.updated_at else None
            }
        }
        
    except Exception as e:
        logger.error(f"Error getting restaurant details for ID {restaurant_id}: {e}")
        return {
            "timestamp": datetime.utcnow().isoformat(),
            "error": str(e),
            "restaurant_id": restaurant_id
        }
    finally:
        session.close()


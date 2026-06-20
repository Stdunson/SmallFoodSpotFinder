#For Google Places API connection and data retrieval
import requests
import os
import json
import logging
from dotenv import load_dotenv
from app.data_objects import (
    search_nearby_object,
    search_nearby_response_object,
    search_text_object,
    search_text_response_object,
    place,
)

load_dotenv()

logger = logging.getLogger(__name__)

# API Configuration
GOOGLE_PLACES_API_KEY = os.getenv("GOOGLE_PLACES_API_KEY")
GOOGLE_PLACES_BASE_URL = "https://places.googleapis.com/v1"


def _build_request_headers():
    """Build headers for Google Places API requests."""
    return {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": GOOGLE_PLACES_API_KEY,
        "X-Goog-FieldMask": "places.id,places.name,places.formattedAddress,places.shortFormattedAddress,places.location,places.types,places.primaryType,places.displayName,places.websiteUri,places.priceLevel,places.rating,places.userRatingCount,places.photos",
    }


def _convert_place_response_to_object(place_data: dict) -> place:
    p = place()
    
    p.name = place_data.get("displayName")
    p.id = place_data.get("id")
    p.googleMapsUri = place_data.get("googleMapsUri")
    p.websiteUri = place_data.get("websiteUri")
    p.formattedAddress = place_data.get("formattedAddress")
    p.shortFormattedAddress = place_data.get("shortFormattedAddress")
    p.adrFormatAddress = place_data.get("adrFormatAddress")
    
    p.nationalPhoneNumber = place_data.get("nationalPhoneNumber")
    p.internationalPhoneNumber = place_data.get("internationalPhoneNumber")
    
    # Display names
    if "displayName" in place_data:
        p.displayName = place_data["displayName"]
    if "primaryTypeDisplayName" in place_data:
        p.primaryTypeDisplayName = place_data["primaryTypeDisplayName"]
    if "googleMapsTypeLabel" in place_data:
        p.googleMapsTypeLabel = place_data["googleMapsTypeLabel"]
    if "editorialSummary" in place_data:
        p.editorialSummary = place_data["editorialSummary"]
    
    # Types
    p.types = place_data.get("types", [])
    p.primaryType = place_data.get("primaryType")
    
    # Location
    if "location" in place_data:
        p.location = place_data["location"]
    if "viewport" in place_data:
        p.viewport = place_data["viewport"]
    if "plusCode" in place_data:
        p.plusCode = place_data["plusCode"]
    if "postalAddress" in place_data:
        p.postalAddress = place_data["postalAddress"]
    if "addressComponents" in place_data:
        p.addressComponents = place_data["addressComponents"]
    
    # Rating and reviews
    p.rating = place_data.get("rating")
    p.userRatingCount = place_data.get("userRatingCount")
    if "reviews" in place_data:
        p.reviews = place_data["reviews"]
    if "reviewSummary" in place_data:
        p.reviewSummary = place_data["reviewSummary"]
    
    # Business info
    p.businessStatus = place_data.get("businessStatus")
    p.priceLevel = place_data.get("priceLevel")
    if "openingDate" in place_data:
        p.openingDate = place_data["openingDate"]
    
    # Hours
    if "regularOpeningHours" in place_data:
        p.regularOpeningHours = place_data["regularOpeningHours"]
    if "currentOpeningHours" in place_data:
        p.currentOpeningHours = place_data["currentOpeningHours"]
    if "currentSecondaryOpeningHours" in place_data:
        p.currentSecondaryOpeningHours = place_data["currentSecondaryOpeningHours"]
    if "regularSecondaryOpeningHours" in place_data:
        p.regularSecondaryOpeningHours = place_data["regularSecondaryOpeningHours"]
    if "timeZone" in place_data:
        p.timeZone = place_data["timeZone"]
    
    # Photos
    if "photos" in place_data:
        p.photos = place_data["photos"]
    
    # Service options
    p.takeout = place_data.get("takeout")
    p.delivery = place_data.get("delivery")
    p.dineIn = place_data.get("dineIn")
    p.curbsidePickup = place_data.get("curbsidePickup")
    p.reservable = place_data.get("reservable")
    
    # Meal types
    p.servesBreakfast = place_data.get("servesBreakfast")
    p.servesLunch = place_data.get("servesLunch")
    p.servesDinner = place_data.get("servesDinner")
    p.servesBrunch = place_data.get("servesBrunch")
    
    # Drink options
    p.servesBeer = place_data.get("servesBeer")
    p.servesWine = place_data.get("servesWine")
    p.servesCocktails = place_data.get("servesCocktails")
    
    # Food options
    p.servesVegetarianFood = place_data.get("servesVegetarianFood")
    p.servesDessert = place_data.get("servesDessert")
    p.servesCoffee = place_data.get("servesCoffee")
    
    # Features
    p.outdoorSeating = place_data.get("outdoorSeating")
    p.liveMusic = place_data.get("liveMusic")
    p.menuForChildren = place_data.get("menuForChildren")
    p.goodForChildren = place_data.get("goodForChildren")
    p.allowsDogs = place_data.get("allowsDogs")
    p.restroom = place_data.get("restroom")
    p.goodForGroups = place_data.get("goodForGroups")
    p.goodForWatchingSports = place_data.get("goodForWatchingSports")
    
    # Additional details
    p.iconMaskBaseUri = place_data.get("iconMaskBaseUri")
    p.iconBackgroundColor = place_data.get("iconBackgroundColor")
    p.utcOffsetMinutes = place_data.get("utcOffsetMinutes")
    p.pureServiceAreaBusiness = place_data.get("pureServiceAreaBusiness")
    
    # Complex objects
    if "paymentOptions" in place_data:
        p.paymentOptions = place_data["paymentOptions"]
    if "parkingOptions" in place_data:
        p.parkingOptions = place_data["parkingOptions"]
    if "accessibilityOptions" in place_data:
        p.accessibilityOptions = place_data["accessibilityOptions"]
    if "fuelOptions" in place_data:
        p.fuelOptions = place_data["fuelOptions"]
    if "evChargeOptions" in place_data:
        p.evChargeOptions = place_data["evChargeOptions"]
    if "evChargeAmenitySummary" in place_data:
        p.evChargeAmenitySummary = place_data["evChargeAmenitySummary"]
    if "subDestinations" in place_data:
        p.subDestinations = place_data["subDestinations"]
    if "containingPlaces" in place_data:
        p.containingPlaces = place_data["containingPlaces"]
    if "generativeSummary" in place_data:
        p.generativeSummary = place_data["generativeSummary"]
    if "neighborhoodSummary" in place_data:
        p.neighborhoodSummary = place_data["neighborhoodSummary"]
    if "addressDescriptor" in place_data:
        p.addressDescriptor = place_data["addressDescriptor"]
    if "googleMapsLinks" in place_data:
        p.googleMapsLinks = place_data["googleMapsLinks"]
    if "priceRange" in place_data:
        p.priceRange = place_data["priceRange"]
    if "attributions" in place_data:
        p.attributions = place_data["attributions"]
    if "movedPlace" in place_data:
        p.movedPlace = place_data["movedPlace"]
    if "movedPlaceId" in place_data:
        p.movedPlaceId = place_data["movedPlaceId"]
    if "consumerAlert" in place_data:
        p.consumerAlert = place_data["consumerAlert"]
    
    return p


def search_nearby(search_request: search_nearby_object) -> search_nearby_response_object:
    url = f"{GOOGLE_PLACES_BASE_URL}/places:searchNearby"
    headers = _build_request_headers()
    
    # Build request body
    payload = {}
    
    if search_request.languageCode:
        payload["languageCode"] = search_request.languageCode
    if search_request.regionCode:
        payload["regionCode"] = search_request.regionCode
    if search_request.includedTypes:
        payload["includedTypes"] = search_request.includedTypes
    if search_request.excludedTypes:
        payload["excludedTypes"] = search_request.excludedTypes
    if search_request.includedPrimaryTypes:
        payload["includedPrimaryTypes"] = search_request.includedPrimaryTypes
    if search_request.excludedPrimaryTypes:
        payload["excludedPrimaryTypes"] = search_request.excludedPrimaryTypes
    if search_request.maxResultCount:
        payload["maxResultCount"] = search_request.maxResultCount
    if search_request.rankPreference:
        payload["rankPreference"] = search_request.rankPreference
    if search_request.includeFutureOpeningBusinesses:
        payload["includeFutureOpeningBusinesses"] = search_request.includeFutureOpeningBusinesses
    
    # Location restriction
    if search_request.locationRestriction:
        if hasattr(search_request.locationRestriction, "center_latitude"):
            # circle object
            payload["locationRestriction"] = {
                "circle": {
                    "center": {
                        "latitude": search_request.locationRestriction.center_latitude,
                        "longitude": search_request.locationRestriction.center_longitude,
                    },
                    "radius": search_request.locationRestriction.radius,
                }
            }
        else:
            payload["locationRestriction"] = search_request.locationRestriction
    
    # Routing parameters
    if search_request.routingParameters:
        payload["routingParameters"] = search_request.routingParameters
    
    # Log request details
    logger.debug(f"Google API Request URL: {url}")
    logger.debug(f"Google API Request Payload: {json.dumps(payload, indent=2)}")
    
    response = requests.post(url, json=payload, headers=headers)
    
    if response.status_code != 200:
        logger.error(f"Google API Response Status: {response.status_code}")
        logger.error(f"Google API Response Text: {response.text}")
    
    response.raise_for_status()
    
    api_response = response.json()
    
    # Build response object
    result = search_nearby_response_object()
    
    if "places" in api_response:
        for place_data in api_response["places"]:
            result.places.append(_convert_place_response_to_object(place_data))
    
    if "routingSummaries" in api_response:
        result.routingSummaries = api_response["routingSummaries"]
    
    return result


def search_text(search_request: search_text_object) -> search_text_response_object:
    url = f"{GOOGLE_PLACES_BASE_URL}/places:searchText"
    headers = _build_request_headers()
    
    # Build request body
    payload = {}
    
    if search_request.textQuery:
        payload["textQuery"] = search_request.textQuery
    if search_request.languageCode:
        payload["languageCode"] = search_request.languageCode
    if search_request.regionCode:
        payload["regionCode"] = search_request.regionCode
    if search_request.rankPreference:
        payload["rankPreference"] = search_request.rankPreference
    if search_request.includedType:
        payload["includedType"] = search_request.includedType
    if search_request.openNow:
        payload["openNow"] = search_request.openNow
    if search_request.minRating is not None:
        payload["minRating"] = search_request.minRating
    if search_request.maxResultCount:
        payload["maxResultCount"] = search_request.maxResultCount
    if search_request.pageSize:
        payload["pageSize"] = search_request.pageSize
    if search_request.pageToken:
        payload["pageToken"] = search_request.pageToken
    if search_request.priceLevels:
        payload["priceLevels"] = search_request.priceLevels
    if search_request.strictTypeFiltering:
        payload["strictTypeFiltering"] = search_request.strictTypeFiltering
    if search_request.includePureServiceAreaBusinesses:
        payload["includePureServiceAreaBusinesses"] = search_request.includePureServiceAreaBusinesses
    if search_request.includeFutureOpeningBusinesses:
        payload["includeFutureOpeningBusinesses"] = search_request.includeFutureOpeningBusinesses
    
    # Location bias
    if search_request.locationBias:
        payload["locationBias"] = search_request.locationBias
    
    # Location restriction
    if search_request.locationRestriction:
        if hasattr(search_request.locationRestriction, "center_latitude"):
            # circle object
            payload["locationRestriction"] = {
                "circle": {
                    "center": {
                        "latitude": search_request.locationRestriction.center_latitude,
                        "longitude": search_request.locationRestriction.center_longitude,
                    },
                    "radius": search_request.locationRestriction.radius,
                }
            }
        else:
            payload["locationRestriction"] = search_request.locationRestriction
    
    # EV options
    if search_request.evOptions:
        payload["evOptions"] = search_request.evOptions
    
    # Routing parameters
    if search_request.routingParameters:
        payload["routingParameters"] = search_request.routingParameters
    
    # Search along route parameters
    if search_request.searchAlongRouteParameters:
        payload["searchAlongRouteParameters"] = search_request.searchAlongRouteParameters
    
    # Log request details
    logger.debug(f"Google API Request URL: {url}")
    logger.debug(f"Google API Request Payload: {json.dumps(payload, indent=2)}")
    
    response = requests.post(url, json=payload, headers=headers)
    
    if response.status_code != 200:
        logger.error(f"Google API Response Status: {response.status_code}")
        logger.error(f"Google API Response Text: {response.text}")
    
    response.raise_for_status()
    
    api_response = response.json()
    
    # Build response object
    result = search_text_response_object()
    
    if "places" in api_response:
        for place_data in api_response["places"]:
            result.places.append(_convert_place_response_to_object(place_data))
    
    if "routingSummaries" in api_response:
        result.routingSummaries = api_response["routingSummaries"]
    
    if "contextualContents" in api_response:
        result.contextualContents = api_response["contextualContents"]
    
    result.nextPageToken = api_response.get("nextPageToken")
    result.searchUri = api_response.get("searchUri")
    
    return result


def get_place_details(place_id: str) -> place:
    url = f"{GOOGLE_PLACES_BASE_URL}/places/{place_id}" #May need to adjust
    headers = _build_request_headers()
    
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    
    place_data = response.json()
    return _convert_place_response_to_object(place_data)
# Data structures needed + global variables + classes for the app
# Data structures: categores, price levels, place types, location restriction
# Global variables: language code, region code, rank preference, place types
language_code = "en"
region_code = "US"
rank_preference = "DISTANCE"
include_future_restaurants = False
place_types = {
    "acai_shop",
    "afghani_restaurant",
    "african_restaurant",
    "american_restaurant",
    "argentinian_restaurant",
    "asian_fusion_restaurant",
    "asian_restaurant",
    "australian_restaurant",
    "austrian_restaurant",
    "bagel_shop",
    "bakery",
    "bangladeshi_restaurant",
    "bar",
    "bar_and_grill",
    "barbecue_restaurant",
    "basque_restaurant",
    "bavarian_restaurant",
    "beer_garden",
    "belgian_restaurant",
    "bistro",
    "brazilian_restaurant",
    "breakfast_restaurant",
    "brewery",
    "brewpub",
    "british_restaurant",
    "brunch_restaurant",
    "buffet_restaurant",
    "burmese_restaurant",
    "burrito_restaurant",
    "cafe",
    "cafeteria",
    "cajun_restaurant",
    "cake_shop",
    "californian_restaurant",
    "cambodian_restaurant",
    "candy_store",
    "cantonese_restaurant",
    "caribbean_restaurant",
    "cat_cafe",
    "chicken_restaurant",
    "chicken_wings_restaurant",
    "chilean_restaurant",
    "chinese_noodle_restaurant",
    "chinese_restaurant",
    "chocolate_factory",
    "chocolate_shop",
    "cocktail_bar",
    "coffee_roastery",
    "coffee_shop",
    "coffee_stand",
    "colombian_restaurant",
    "confectionery",
    "croatian_restaurant",
    "cuban_restaurant",
    "czech_restaurant",
    "danish_restaurant",
    "deli",
    "dessert_restaurant",
    "dessert_shop",
    "dim_sum_restaurant",
    "diner",
    "dog_cafe",
    "donut_shop",
    "dumpling_restaurant",
    "dutch_restaurant",
    "eastern_european_restaurant",
    "ethiopian_restaurant",
    "european_restaurant",
    "falafel_restaurant",
    "family_restaurant",
    "fast_food_restaurant",
    "filipino_restaurant",
    "fine_dining_restaurant",
    "fish_and_chips_restaurant",
    "fondue_restaurant",
    "food_court",
    "french_restaurant",
    "fusion_restaurant",
    "gastropub",
    "german_restaurant",
    "greek_restaurant",
    "gyro_restaurant",
    "halal_restaurant",
    "hamburger_restaurant",
    "hawaiian_restaurant",
    "hookah_bar",
    "hot_dog_restaurant",
    "hot_dog_stand",
    "hot_pot_restaurant",
    "hungarian_restaurant",
    "ice_cream_shop",
    "indian_restaurant",
    "indonesian_restaurant",
    "irish_pub",
    "irish_restaurant",
    "israeli_restaurant",
    "italian_restaurant",
    "japanese_curry_restaurant",
    "japanese_izakaya_restaurant",
    "japanese_restaurant",
    "juice_shop",
    "kebab_shop",
    "korean_barbecue_restaurant",
    "korean_restaurant",
    "latin_american_restaurant",
    "lebanese_restaurant",
    "lounge_bar",
    "malaysian_restaurant",
    "meal_delivery",
    "meal_takeaway",
    "mediterranean_restaurant",
    "mexican_restaurant",
    "middle_eastern_restaurant",
    "mongolian_barbecue_restaurant",
    "moroccan_restaurant",
    "noodle_shop",
    "north_indian_restaurant",
    "oyster_bar_restaurant",
    "pakistani_restaurant",
    "pastry_shop",
    "persian_restaurant",
    "peruvian_restaurant",
    "pizza_delivery",
    "pizza_restaurant",
    "polish_restaurant",
    "portuguese_restaurant",
    "pub",
    "ramen_restaurant",
    "restaurant",
    "romanian_restaurant",
    "russian_restaurant",
    "salad_shop",
    "sandwich_shop",
    "scandinavian_restaurant",
    "seafood_restaurant",
    "shawarma_restaurant",
    "snack_bar",
    "soul_food_restaurant",
    "soup_restaurant",
    "south_american_restaurant",
    "south_indian_restaurant",
    "southwestern_us_restaurant",
    "spanish_restaurant",
    "sports_bar",
    "sri_lankan_restaurant",
    "steak_house",
    "sushi_restaurant",
    "swiss_restaurant",
    "taco_restaurant",
    "taiwanese_restaurant",
    "tapas_restaurant",
    "tea_house",
    "tex_mex_restaurant",
    "thai_restaurant",
    "tibetan_restaurant",
    "tonkatsu_restaurant",
    "turkish_restaurant",
    "ukrainian_restaurant",
    "vegan_restaurant",
    "vegetarian_restaurant",
    "vietnamese_restaurant",
    "western_restaurant",
    "wine_bar",
    "winery",
    "yakiniku_restaurant",
    "yakitori_restaurant",
}

price_levels = {
    0: "PRICE_LEVEL_UNSPECIFIED",
    1: "PRICE_LEVEL_FREE",
    2: "PRICE_LEVEL_INEXPENSIVE",
    3: "PRICE_LEVEL_MODERATE",
    4: "PRICE_LEVEL_EXPENSIVE",
    5: "PRICE_LEVEL_VERY_EXPENSIVE",
}

class circle: #For location restriction field
    def __init__(self, center_latitude, center_longitude, radius):
        self.center_latitude = center_latitude
        self.center_longitude = center_longitude
        self.radius = radius

class search_nearby_object:
    def __init__(self):
        self.languageCode = None
        self.regionCode = None
        self.includedTypes = []
        self.excludedTypes = []
        self.includedPrimaryTypes = []
        self.excludedPrimaryTypes = []
        self.maxResultCount = None
        self.locationRestriction = None  # circle object
        self.rankPreference = None
        self.routingParameters = None
        self.includeFutureOpeningBusinesses = False

class search_nearby_response_object:
    def __init__(self):
        self.places = []  # List of place objects
        self.routingSummaries = []

class place:
    def __init__(self):
        self.name = None
        self.id = None
        self.displayName = None  # LocalizedText
        self.types = []
        self.primaryType = None
        self.primaryTypeDisplayName = None  # LocalizedText
        self.googleMapsTypeLabel = None  # LocalizedText
        self.nationalPhoneNumber = None
        self.internationalPhoneNumber = None
        self.formattedAddress = None
        self.shortFormattedAddress = None
        self.postalAddress = None  # PostalAddress
        self.addressComponents = []
        self.plusCode = None  # PlusCode
        self.location = None  # LatLng
        self.viewport = None  # Viewport
        self.rating = None
        self.googleMapsUri = None
        self.websiteUri = None
        self.reviews = []
        self.regularOpeningHours = None  # OpeningHours
        self.timeZone = None  # TimeZone
        self.photos = []
        self.adrFormatAddress = None
        self.businessStatus = None
        self.openingDate = None  # Date
        self.priceLevel = None
        self.attributions = []
        self.iconMaskBaseUri = None
        self.iconBackgroundColor = None
        self.currentOpeningHours = None  # OpeningHours
        self.currentSecondaryOpeningHours = []
        self.regularSecondaryOpeningHours = []
        self.editorialSummary = None  # LocalizedText
        self.paymentOptions = None
        self.parkingOptions = None
        self.subDestinations = []
        self.fuelOptions = None
        self.evChargeOptions = None
        self.generativeSummary = None
        self.containingPlaces = []
        self.addressDescriptor = None
        self.googleMapsLinks = None
        self.priceRange = None
        self.reviewSummary = None
        self.evChargeAmenitySummary = None
        self.neighborhoodSummary = None
        self.consumerAlert = None
        self.movedPlace = None
        self.movedPlaceId = None
        self.utcOffsetMinutes = None
        self.userRatingCount = None
        self.takeout = None
        self.delivery = None
        self.dineIn = None
        self.curbsidePickup = None
        self.reservable = None
        self.servesBreakfast = None
        self.servesLunch = None
        self.servesDinner = None
        self.servesBeer = None
        self.servesWine = None
        self.servesBrunch = None
        self.servesVegetarianFood = None
        self.outdoorSeating = None
        self.liveMusic = None
        self.menuForChildren = None
        self.servesCocktails = None
        self.servesDessert = None
        self.servesCoffee = None
        self.goodForChildren = None
        self.allowsDogs = None
        self.restroom = None
        self.goodForGroups = None
        self.goodForWatchingSports = None
        self.accessibilityOptions = None
        self.pureServiceAreaBusiness = None

class search_text_object:
    def __init__(self):
        self.textQuery = None
        self.languageCode = None
        self.regionCode = None
        self.rankPreference = None
        self.includedType = None
        self.openNow = False
        self.minRating = None
        self.maxResultCount = None
        self.pageSize = None
        self.pageToken = None
        self.priceLevels = []
        self.strictTypeFiltering = False
        self.locationBias = None
        self.locationRestriction = None  # LocationRestriction
        self.evOptions = None
        self.routingParameters = None
        self.searchAlongRouteParameters = None
        self.includePureServiceAreaBusinesses = False
        self.includeFutureOpeningBusinesses = False

class search_text_response_object:
    def __init__(self):
        self.places = []  # List of place objects
        self.routingSummaries = []
        self.contextualContents = []
        self.nextPageToken = None
        self.searchUri = None

class restaurant_object:
    def __init__(self):
        self.id = None
        self.uuid = None
        self.name = None
        self.address = None
        self.longitude = None
        self.latitude = None
        self.price_level = None
        self.is_featured = False
        self.google_place_id = None
        self.website_url = None
        self.image_url = None
        self.source = None  # 'google', 'curated', 'user_recommendation', 'partner'
        self.categories = []  # List of category strings
        self.created_at = None
        self.updated_at = None

class restaurant_category_object:
    def __init__(self):
        self.id = None
        self.restaurant_id = None
        self.uuid = None
        self.category = None
        self.created_at = None

class restaurant_business_hours_object:
    def __init__(self):
        self.id = None
        self.restaurant_id = None
        self.uuid = None
        self.day_of_week = None  # 0-6, Monday-Sunday
        self.opening_time = None
        self.closing_time = None
        self.is_open = True
        self.is_overnight = False
        self.created_at = None
        self.updated_at = None

class restaurant_cache_object:
    def __init__(self):
        self.id = None
        self.restaurant_id = None
        self.uuid = None
        self.nearby_search_cached_at = None
        self.details_cached_at = None
        self.localness_cached_at = None
        self.is_local = None
        self.created_at = None
        self.updated_at = None
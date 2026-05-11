-- Create schema for Small Food Spot Finder application
-- This file defines all tables and relationships

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Restaurant table
CREATE TABLE IF NOT EXISTS restaurant (
    id SERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    address VARCHAR(500) NOT NULL,
    longitude DECIMAL(15, 13) NOT NULL,
    latitude DECIMAL(15, 13) NOT NULL,
    price_level SMALLINT, --1 to 4
    is_featured BOOLEAN DEFAULT FALSE,
    google_place_id VARCHAR(255) UNIQUE,
    website_url VARCHAR(500),
    image_url VARCHAR(500),
    source VARCHAR(50) NOT NULL CHECK (source IN ('google', 'curated', 'user_recommendation', 'partner')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Restaurant Category junction table
CREATE TABLE IF NOT EXISTS restaurant_category (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER NOT NULL,
    uuid UUID NOT NULL UNIQUE DEFAULT uuid_generate_v4(),
    category VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON DELETE CASCADE,
    UNIQUE(restaurant_id, category)
);

-- Restaurant Business Hours table
CREATE TABLE IF NOT EXISTS restaurant_business_hours (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER NOT NULL,
    uuid UUID NOT NULL UNIQUE DEFAULT uuid_generate_v4(),
    day_of_week SMALLINT NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    opening_time SMALLINT NOT NULL,
    closing_time SMALLINT NOT NULL,
    is_open BOOLEAN DEFAULT TRUE,
    is_overnight BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON DELETE CASCADE,
    UNIQUE(restaurant_id, day_of_week)
);

-- Restaurant Cache table for tracking data freshness
CREATE TABLE IF NOT EXISTS restaurant_cache (
    id SERIAL PRIMARY KEY,
    restaurant_id INTEGER NOT NULL UNIQUE,
    uuid UUID NOT NULL UNIQUE DEFAULT uuid_generate_v4(),
    nearby_search_cached_at TIMESTAMP,
    details_cached_at TIMESTAMP,
    localness_cached_at TIMESTAMP,
    is_local BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(id) ON DELETE CASCADE
);

-- Create indexes for performance optimization
CREATE INDEX IF NOT EXISTS idx_restaurant_uuid ON restaurant(uuid);
CREATE INDEX IF NOT EXISTS idx_restaurant_google_place_id ON restaurant(google_place_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_location ON restaurant(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_restaurant_featured ON restaurant(is_featured);
CREATE INDEX IF NOT EXISTS idx_restaurant_category_restaurant_id ON restaurant_category(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_category_category ON restaurant_category(category);
CREATE INDEX IF NOT EXISTS idx_restaurant_hours_restaurant_id ON restaurant_business_hours(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_hours_day ON restaurant_business_hours(day_of_week);
CREATE INDEX IF NOT EXISTS idx_restaurant_cache_restaurant_id ON restaurant_cache(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_cache_is_local ON restaurant_cache(is_local);

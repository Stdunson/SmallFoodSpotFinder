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
    price_level SMALLINT,
    is_featured BOOLEAN DEFAULT FALSE,
    yelp_business_id VARCHAR(255) UNIQUE,
    image_url VARCHAR(500),
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

-- Create indexes for performance optimization
CREATE INDEX IF NOT EXISTS idx_restaurant_uuid ON restaurant(uuid);
CREATE INDEX IF NOT EXISTS idx_restaurant_yelp_id ON restaurant(yelp_business_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_location ON restaurant(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_restaurant_featured ON restaurant(is_featured);
CREATE INDEX IF NOT EXISTS idx_restaurant_category_restaurant_id ON restaurant_category(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_category_category ON restaurant_category(category);
CREATE INDEX IF NOT EXISTS idx_restaurant_hours_restaurant_id ON restaurant_business_hours(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_hours_day ON restaurant_business_hours(day_of_week);

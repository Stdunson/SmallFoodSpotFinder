-- Drop all tables in the correct order (respecting foreign key constraints)
-- WARNING: This will delete all data in the database

DROP TABLE IF EXISTS restaurant_business_hours CASCADE;
DROP TABLE IF EXISTS restaurant_category CASCADE;
DROP TABLE IF EXISTS restaurant CASCADE;

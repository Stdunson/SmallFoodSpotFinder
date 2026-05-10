# Database Setup Guide

This directory contains scripts to initialize the PostgreSQL database for the Small Food Spot Finder application.

## Directory Structure

```
database/
├── schemas/              # SQL schema definition files
│   ├── 00_drop_tables.sql       # Drop existing tables (for cleanup)
│   └── 01_create_tables.sql     # Create all tables with indexes
├── migrations/          # Additional migration files (if needed)
├── seed_data/           # Seed data files (currently empty per requirements)
├── init_db.sh           # Bash script to initialize the database
└── init_db.py           # Python script to initialize the database
```

## Database Schema

The schema consists of three main tables:

### 1. Restaurant
Stores information about restaurants
- `id` - Primary key (auto-incrementing)
- `uuid` - Unique identifier (UUID)
- `name` - Restaurant name
- `address` - Physical address
- `longitude` - Longitude coordinate
- `latitude` - Latitude coordinate
- `price_level` - Price tier (nullable)
- `is_featured` - Featured status
- `yelp_business_id` - Yelp business ID (unique, nullable)
- `image_url` - Image URL (nullable)
- `created_at` - Timestamp of creation
- `updated_at` - Timestamp of last update

### 2. Restaurant Category
Junction table for categorizing restaurants (one restaurant can have multiple categories)
- `id` - Primary key
- `restaurant_id` - Foreign key to restaurant
- `uuid` - Unique identifier
- `category` - Category name
- `created_at` - Timestamp of creation

### 3. Restaurant Business Hours
Stores operating hours for each day of the week
- `id` - Primary key
- `restaurant_id` - Foreign key to restaurant
- `uuid` - Unique identifier
- `day_of_week` - Day of week (0-6)
- `opening_time` - Opening time (24-hour format as integer)
- `closing_time` - Closing time (24-hour format as integer)
- `is_open` - Whether open on this day
- `is_overnight` - Whether hours span midnight
- `created_at` - Timestamp of creation
- `updated_at` - Timestamp of last update

## Usage

### Option 1: Using Bash Script (Recommended for Linux/macOS)

```bash
cd database
chmod +x init_db.sh
./init_db.sh
```

Environment variables:
```bash
DB_HOST=localhost \
DB_PORT=5432 \
DB_USER=postgres \
DB_NAME=small_food_spot_finder \
./init_db.sh
```

### Option 2: Using Python Script (Cross-platform)

```bash
cd database
python init_db.py
```

Environment variables:
```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=postgres
export DB_PASSWORD=your_password
export DB_NAME=small_food_spot_finder
python init_db.py
```

### Option 3: Direct SQL Execution

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE small_food_spot_finder;

# Connect to the new database
\c small_food_spot_finder

# Run migrations
\i database/schemas/01_create_tables.sql
```

## Database Cleanup

To drop all tables and start fresh:

```sql
\i database/schemas/00_drop_tables.sql
```

Or using Python:
```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    user="postgres",
    password="your_password",
    database="small_food_spot_finder"
)
cursor = conn.cursor()

with open("database/schemas/00_drop_tables.sql", "r") as f:
    cursor.execute(f.read())
conn.commit()
cursor.close()
conn.close()
```

## Notes

- All tables use UUIDs as additional unique identifiers alongside numeric primary keys
- Foreign key constraints ensure referential integrity
- Indexes are created for performance optimization on commonly queried columns
- Timestamps are automatically managed (created_at, updated_at)
- The `restaurant_business_hours` table uses `day_of_week` (0=Sunday to 6=Saturday)
- No seed data is included; populate tables as needed for your application

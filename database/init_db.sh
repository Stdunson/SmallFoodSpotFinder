#!/bin/bash
# Database initialization script for Small Food Spot Finder
# This script sets up the PostgreSQL database with the required schema

set -e

# Configuration
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-postgres}
DB_NAME=${DB_NAME:-small_food_spot_finder}

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Small Food Spot Finder - Database Initialization${NC}"
echo "=================================================="
echo "Host: $DB_HOST"
echo "Port: $DB_PORT"
echo "User: $DB_USER"
echo "Database: $DB_NAME"
echo "=================================================="

# Check if psql is installed
if ! command -v psql &> /dev/null; then
    echo -e "${RED}Error: psql is not installed${NC}"
    exit 1
fi

# Create database if it doesn't exist
echo -e "${YELLOW}Creating database...${NC}"
createdb -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" 2>/dev/null || echo "Database already exists"

# Run migrations in order
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_DIR="$SCRIPT_DIR/schemas"

if [ ! -d "$SCHEMA_DIR" ]; then
    echo -e "${RED}Error: Schema directory not found at $SCHEMA_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}Running migrations...${NC}"

# Execute SQL files in sorted order
for sql_file in $(find "$SCHEMA_DIR" -name "*.sql" -type f | sort); do
    filename=$(basename "$sql_file")
    echo -e "${YELLOW}  Running: $filename${NC}"
    
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$sql_file" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ $filename completed${NC}"
    else
        echo -e "${RED}  ✗ Error running $filename${NC}"
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$sql_file"
        exit 1
    fi
done

echo -e "${GREEN}=================================================="
echo "✓ Database initialized successfully!"
echo "==================================================${NC}"

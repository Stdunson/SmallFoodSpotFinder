#!/usr/bin/env python3
"""
Database initialization script for Small Food Spot Finder
Runs migrations to set up the PostgreSQL database schema
"""

import psycopg2
import os
import sys
from pathlib import Path
from dotenv import load_dotenv

def get_db_connection(host, user, password, port=5432):
    """Create a connection to PostgreSQL"""
    try:
        conn = psycopg2.connect(
            host=host,
            user=user,
            password=password,
            port=port
        )
        return conn
    except psycopg2.Error as e:
        print(f"Unable to connect to the database: {e}")
        sys.exit(1)

def create_database(host, user, password, db_name, port=5432):
    """Create the database if it doesn't exist"""
    conn = get_db_connection(host, user, password, port)
    conn.autocommit = True
    cursor = conn.cursor()
    
    try:
        cursor.execute(f"CREATE DATABASE {db_name}")
        print(f"Database '{db_name}' created successfully")
    except psycopg2.Error as e:
        if "already exists" in str(e):
            print(f"Database '{db_name}' already exists")
        else:
            print(f"Error creating database: {e}")
    finally:
        cursor.close()
        conn.close()

def get_db_connection_with_db(host, user, password, db_name, port=5432):
    """Create a connection to a specific database"""
    try:
        conn = psycopg2.connect(
            host=host,
            user=user,
            password=password,
            database=db_name,
            port=port
        )
        return conn
    except psycopg2.Error as e:
        print(f"Unable to connect to database '{db_name}': {e}")
        sys.exit(1)

def run_migrations(host, user, password, db_name, port=5432):
    """Run all SQL migration files in order"""
    schema_dir = Path(__file__).parent / "schemas"
    
    if not schema_dir.exists():
        print(f"Schema directory not found: {schema_dir}")
        sys.exit(1)
    
    sql_files = sorted(schema_dir.glob("*.sql"))
    
    if not sql_files:
        print("No SQL migration files found in schemas directory")
        sys.exit(1)
    
    conn = get_db_connection_with_db(host, user, password, db_name, port)
    cursor = conn.cursor()
    
    try:
        for sql_file in sql_files:
            print(f"Running migration: {sql_file.name}...")
            with open(sql_file, 'r') as f:
                sql_script = f.read()
            
            cursor.execute(sql_script)
            conn.commit()
            print(f"✓ {sql_file.name} completed successfully")
        
        print("\n✓ All migrations completed successfully!")
        
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error running migrations: {e}")
        sys.exit(1)
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    env_path = Path(__file__).parent / ".env"
    load_dotenv(env_path)
    
    host = os.getenv("DB_HOST", "localhost")
    user = os.getenv("DB_USER", "postgres")
    password = os.getenv("DB_PASSWORD", "")
    db_name = os.getenv("DB_NAME", "small_food_spot_finder")
    port = int(os.getenv("DB_PORT", 5432))
    
    print("Small Food Spot Finder - Database Initialization")
    print("=" * 50)
    print(f"Host: {host}")
    print(f"User: {user}")
    print(f"Database: {db_name}")
    print(f"Port: {port}")
    print("=" * 50)
    
    create_database(host, user, password, db_name, port)

    run_migrations(host, user, password, db_name, port)

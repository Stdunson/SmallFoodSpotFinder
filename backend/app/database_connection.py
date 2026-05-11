#For postgres database connection and data retrieval
from sqlalchemy import create_engine, Column, Integer, String, Boolean, DECIMAL, SmallInteger, DateTime, ForeignKey, CheckConstraint, UniqueConstraint, func
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.postgresql import UUID
import os
from dotenv import load_dotenv
from datetime import datetime
import uuid as uuid_lib

# Load environment variables from .env file
load_dotenv()

# Database connection setup
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@localhost/small_food_spot_finder")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# SQLAlchemy ORM Models
class Restaurant(Base):
    __tablename__ = "restaurant"
    
    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), unique=True, nullable=False, default=uuid_lib.uuid4)
    name = Column(String(255), nullable=False)
    address = Column(String(500), nullable=False)
    longitude = Column(DECIMAL(15, 13), nullable=False)
    latitude = Column(DECIMAL(15, 13), nullable=False)
    price_level = Column(SmallInteger)
    is_featured = Column(Boolean, default=False)
    google_place_id = Column(String(255), unique=True)
    website_url = Column(String(500))
    image_url = Column(String(500))
    source = Column(String(50), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    categories = relationship("RestaurantCategory", back_populates="restaurant", cascade="all, delete-orphan")
    business_hours = relationship("RestaurantBusinessHours", back_populates="restaurant", cascade="all, delete-orphan")
    cache = relationship("RestaurantCache", back_populates="restaurant", cascade="all, delete-orphan", uselist=False)
    
    __table_args__ = (
        CheckConstraint("source IN ('google', 'curated', 'user_recommendation', 'partner')"),
    )


class RestaurantCategory(Base):
    __tablename__ = "restaurant_category"
    
    id = Column(Integer, primary_key=True, index=True)
    restaurant_id = Column(Integer, ForeignKey("restaurant.id", ondelete="CASCADE"), nullable=False)
    uuid = Column(UUID(as_uuid=True), unique=True, nullable=False, default=uuid_lib.uuid4)
    category = Column(String(100), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    restaurant = relationship("Restaurant", back_populates="categories")
    
    __table_args__ = (
        UniqueConstraint("restaurant_id", "category", name="uq_restaurant_category"),
    )


class RestaurantBusinessHours(Base):
    __tablename__ = "restaurant_business_hours"
    
    id = Column(Integer, primary_key=True, index=True)
    restaurant_id = Column(Integer, ForeignKey("restaurant.id", ondelete="CASCADE"), nullable=False)
    uuid = Column(UUID(as_uuid=True), unique=True, nullable=False, default=uuid_lib.uuid4)
    day_of_week = Column(SmallInteger, nullable=False)
    opening_time = Column(SmallInteger, nullable=False)
    closing_time = Column(SmallInteger, nullable=False)
    is_open = Column(Boolean, default=True)
    is_overnight = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    restaurant = relationship("Restaurant", back_populates="business_hours")
    
    __table_args__ = (
        CheckConstraint("day_of_week >= 0 AND day_of_week <= 6"),
        UniqueConstraint("restaurant_id", "day_of_week", name="uq_restaurant_day"),
    )


class RestaurantCache(Base):
    __tablename__ = "restaurant_cache"
    
    id = Column(Integer, primary_key=True, index=True)
    restaurant_id = Column(Integer, ForeignKey("restaurant.id", ondelete="CASCADE"), unique=True, nullable=False)
    uuid = Column(UUID(as_uuid=True), unique=True, nullable=False, default=uuid_lib.uuid4)
    nearby_search_cached_at = Column(DateTime)
    details_cached_at = Column(DateTime)
    localness_cached_at = Column(DateTime)
    is_local = Column(Boolean)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    restaurant = relationship("Restaurant", back_populates="cache")


def read_restaurant(restaurant_id: int):
    db = SessionLocal()
    try:
        restaurant = db.query(Restaurant).filter(Restaurant.id == restaurant_id).first()
        return restaurant
    finally:
        db.close()


def read_restaurant_by_uuid(restaurant_uuid: str):
    db = SessionLocal()
    try:
        restaurant = db.query(Restaurant).filter(Restaurant.uuid == restaurant_uuid).first()
        return restaurant
    finally:
        db.close()


def read_all_restaurants(limit: int = None, offset: int = 0):
    db = SessionLocal()
    try:
        query = db.query(Restaurant).offset(offset)
        if limit:
            query = query.limit(limit)
        return query.all()
    finally:
        db.close()


def write_restaurant(restaurant: Restaurant):
    db = SessionLocal()
    try:
        db.add(restaurant)
        db.commit()
        db.refresh(restaurant)
        return restaurant
    except Exception as e:
        db.rollback()
        raise e
    finally:
        db.close()


def update_restaurant(restaurant: Restaurant):
    db = SessionLocal()
    try:
        db.merge(restaurant)
        db.commit()
        return restaurant
    except Exception as e:
        db.rollback()
        raise e
    finally:
        db.close()


def delete_restaurant(restaurant_id: int):
    db = SessionLocal()
    try:
        restaurant = db.query(Restaurant).filter(Restaurant.id == restaurant_id).first()
        if restaurant:
            db.delete(restaurant)
            db.commit()
            return True
        return False
    except Exception as e:
        db.rollback()
        raise e
    finally:
        db.close()
from sqlalchemy import Column, Integer, String, DateTime, Float, Boolean, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

class ProductionOrder(Base):
    __tablename__ = "production_orders"
    
    id = Column(Integer, primary_key=True, index=True)
    order_number = Column(String, unique=True, index=True)
    product_code = Column(String, index=True)
    quantity = Column(Integer)
    status = Column(String, default="pending")
    created_at = Column(DateTime, default=datetime.utcnow)
    due_date = Column(DateTime)

class WorkStation(Base):
    __tablename__ = "workstations"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)
    location = Column(String)
    status = Column(String, default="idle")
    current_order_id = Column(Integer, ForeignKey("production_orders.id"))

class QualityCheck(Base):
    __tablename__ = "quality_checks"
    
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("production_orders.id"))
    parameter = Column(String)
    value = Column(Float)
    specification_min = Column(Float)
    specification_max = Column(Float)
    passed = Column(Boolean)
    checked_at = Column(DateTime, default=datetime.utcnow)
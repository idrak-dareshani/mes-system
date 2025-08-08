from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class ProductionOrderCreate(BaseModel):
    order_number: str
    product_code: str
    quantity: int
    due_date: datetime

class ProductionOrderUpdate(BaseModel):
    order_number: Optional[str] = None
    product_code: Optional[str] = None
    quantity: Optional[int] = None
    status: Optional[str] = None
    due_date: Optional[datetime] = None

class WorkStationCreate(BaseModel):
    name: str
    location: str

class WorkStationUpdate(BaseModel):
    name: Optional[str] = None
    location: Optional[str] = None
    status: Optional[str] = None
    current_order_id: Optional[int] = None

class QualityCheckCreate(BaseModel):
    order_id: int
    parameter: str
    value: float
    specification_min: float
    specification_max: float
    passed: bool

class QualityCheckUpdate(BaseModel):
    order_id: Optional[int] = None
    parameter: Optional[str] = None
    value: Optional[float] = None
    specification_min: Optional[float] = None
    specification_max: Optional[float] = None
    passed: Optional[bool] = None
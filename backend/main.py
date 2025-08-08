from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from database import get_db, engine
from models import ProductionOrder, WorkStation, QualityCheck, Base
from schemas import ProductionOrderCreate, ProductionOrderUpdate, WorkStationCreate, WorkStationUpdate, QualityCheckCreate, QualityCheckUpdate
import redis

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="MES System API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

try:
    redis_client = redis.Redis(host='redis', port=6379, decode_responses=True)
    redis_client.ping()  # Test connection
except Exception as e:
    print(f"Redis connection failed: {e}")
    redis_client = None

@app.get("/")
def read_root():
    return {"message": "MES System API"}

# Production Orders CRUD
@app.post("/production-orders/")
def create_production_order(order: ProductionOrderCreate, db: Session = Depends(get_db)):
    db_order = ProductionOrder(**order.dict())
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    if redis_client:
        try:
            redis_client.publish("production_updates", f"New order created: {db_order.id}")
        except Exception as e:
            print(f"Redis publish failed: {e}")
    return db_order

@app.get("/production-orders/")
def get_production_orders(db: Session = Depends(get_db)):
    return db.query(ProductionOrder).all()

@app.get("/production-orders/{order_id}")
def get_production_order(order_id: int, db: Session = Depends(get_db)):
    order = db.query(ProductionOrder).filter(ProductionOrder.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Production order not found")
    return order

@app.put("/production-orders/{order_id}")
def update_production_order(order_id: int, order_update: ProductionOrderUpdate, db: Session = Depends(get_db)):
    order = db.query(ProductionOrder).filter(ProductionOrder.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Production order not found")
    
    for field, value in order_update.dict(exclude_unset=True).items():
        setattr(order, field, value)
    
    db.commit()
    db.refresh(order)
    return order

@app.delete("/production-orders/{order_id}")
def delete_production_order(order_id: int, db: Session = Depends(get_db)):
    order = db.query(ProductionOrder).filter(ProductionOrder.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Production order not found")
    
    db.delete(order)
    db.commit()
    return {"message": "Production order deleted"}

# WorkStations CRUD
@app.post("/workstations/")
def create_workstation(station: WorkStationCreate, db: Session = Depends(get_db)):
    db_station = WorkStation(**station.dict())
    db.add(db_station)
    db.commit()
    db.refresh(db_station)
    return db_station

@app.get("/workstations/")
def get_workstations(db: Session = Depends(get_db)):
    return db.query(WorkStation).all()

@app.get("/workstations/{station_id}")
def get_workstation(station_id: int, db: Session = Depends(get_db)):
    station = db.query(WorkStation).filter(WorkStation.id == station_id).first()
    if not station:
        raise HTTPException(status_code=404, detail="Workstation not found")
    return station

@app.put("/workstations/{station_id}")
def update_workstation(station_id: int, station_update: WorkStationUpdate, db: Session = Depends(get_db)):
    station = db.query(WorkStation).filter(WorkStation.id == station_id).first()
    if not station:
        raise HTTPException(status_code=404, detail="Workstation not found")
    
    for field, value in station_update.dict(exclude_unset=True).items():
        setattr(station, field, value)
    
    db.commit()
    db.refresh(station)
    return station

@app.delete("/workstations/{station_id}")
def delete_workstation(station_id: int, db: Session = Depends(get_db)):
    station = db.query(WorkStation).filter(WorkStation.id == station_id).first()
    if not station:
        raise HTTPException(status_code=404, detail="Workstation not found")
    
    db.delete(station)
    db.commit()
    return {"message": "Workstation deleted"}

# Quality Checks CRUD
@app.post("/quality-checks/")
def create_quality_check(check: QualityCheckCreate, db: Session = Depends(get_db)):
    # Automatically calculate passed status
    passed = check.specification_min <= check.value <= check.specification_max
    
    check_data = check.dict()
    check_data['passed'] = passed
    
    db_check = QualityCheck(**check_data)
    db.add(db_check)
    db.commit()
    db.refresh(db_check)
    return db_check

@app.get("/quality-checks/")
def get_quality_checks(db: Session = Depends(get_db)):
    return db.query(QualityCheck).all()

@app.get("/quality-checks/{check_id}")
def get_quality_check(check_id: int, db: Session = Depends(get_db)):
    check = db.query(QualityCheck).filter(QualityCheck.id == check_id).first()
    if not check:
        raise HTTPException(status_code=404, detail="Quality check not found")
    return check

@app.put("/quality-checks/{check_id}")
def update_quality_check(check_id: int, check_update: QualityCheckUpdate, db: Session = Depends(get_db)):
    check = db.query(QualityCheck).filter(QualityCheck.id == check_id).first()
    if not check:
        raise HTTPException(status_code=404, detail="Quality check not found")
    
    update_data = check_update.dict(exclude_unset=True)
    
    # Recalculate passed status if relevant fields are updated
    if any(field in update_data for field in ['value', 'specification_min', 'specification_max']):
        value = update_data.get('value', check.value)
        min_spec = update_data.get('specification_min', check.specification_min)
        max_spec = update_data.get('specification_max', check.specification_max)
        update_data['passed'] = min_spec <= value <= max_spec
    
    for field, value in update_data.items():
        setattr(check, field, value)
    
    db.commit()
    db.refresh(check)
    return check

@app.delete("/quality-checks/{check_id}")
def delete_quality_check(check_id: int, db: Session = Depends(get_db)):
    check = db.query(QualityCheck).filter(QualityCheck.id == check_id).first()
    if not check:
        raise HTTPException(status_code=404, detail="Quality check not found")
    
    db.delete(check)
    db.commit()
    return {"message": "Quality check deleted"}
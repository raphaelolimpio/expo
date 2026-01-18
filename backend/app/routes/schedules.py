from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.schedule import Schedule
from app.schemas.schedule import ScheduleCreate

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/")
def create_schedule(data: ScheduleCreate, db: Session = Depends(get_db)):
    s = Schedule(**data.dict())
    db.add(s)
    db.commit()
    db.refresh(s)
    return s

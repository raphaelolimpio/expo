from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.exhibitor import Exhibitor
from app.schemas.exhibitor import ExhibitorCreate

router = APIRouter(prefix="/exhibitors", tags=["exhibitors"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/")
def create_exhibitor(data: ExhibitorCreate, db: Session = Depends(get_db)):
    e = Exhibitor(**data.dict())
    db.add(e)
    db.commit()
    db.refresh(e)
    return e

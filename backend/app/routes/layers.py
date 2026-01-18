from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.layer import MapLayer
from app.schemas.layer import LayerCreate

router = APIRouter(prefix="/layers", tags=["Layers"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/")
def create_layer(data: LayerCreate, db: Session = Depends(get_db)):
    layer = MapLayer(**data.dict())
    db.add(layer)
    db.commit()
    db.refresh(layer)
    return layer

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.block import MapBlock
from app.schemas.block import BlockCreate
from app.utils.geometry import normalize_geometry

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/")
def create_block(data: BlockCreate, db: Session = Depends(get_db)):
    geometry = normalize_geometry(data.geometry)

    block = MapBlock(
        map_id=data.map_id,
        layer_id=data.layer_id,
        code=data.code,
        type=data.type,
        geometry=geometry
    )

    db.add(block)
    db.commit()
    db.refresh(block)
    return block


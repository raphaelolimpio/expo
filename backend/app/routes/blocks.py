import json
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.block import MapBlock
from app.schemas.block import BlockCreate
from app.utils.geometry import normalize_geometry
from geoalchemy2.functions import ST_SetSRID, ST_GeomFromGeoJSON

router = APIRouter(prefix="/blocks", tags=["blocks"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/")
def create_block(data: BlockCreate, db: Session = Depends(get_db)):

    geo_dict = normalize_geometry(data.geometry)
    geo_json_str = json.dumps(geo_dict)

    block = MapBlock(
        map_id=data.map_id,
        layer_id=data.layer_id,
        code=data.code,
        type=data.type,
        status="livre", 
        geometry=ST_SetSRID(ST_GeomFromGeoJSON(geo_json_str), 4326)
    )

    db.add(block)
    db.commit()
    db.refresh(block)


    return {
        "id": str(block.id),
        "map_id": str(block.map_id),
        "layer_id": str(block.layer_id),
        "code": block.code,
        "type": block.type,
        "status": block.status,
        "geometry": geo_dict 
    }
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload
from uuid import UUID
from app.db.session import SessionLocal
from app.models.map import Map
from app.schemas.map import MapCreate
from app.models.layer import MapLayer
from app.models.block import MapBlock
from app.utils.geometry import simplify_tolerance
from geoalchemy2.functions import ST_AsGeoJSON, ST_Simplify, ST_Intersects, ST_MakeEnvelope, ST_Contains, ST_SetSRID, ST_Point
import json
from app.core.redis import redis_client
from app.services.map_service_cache import build_cache_key, serialize, deserialize

router = APIRouter(prefix="/maps", tags=["maps"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/")
def create_map(data: MapCreate, db: Session = Depends(get_db)):
    m = Map(**data.dict())
    db.add(m)
    db.commit()
    db.refresh(m)
    return m


@router.get("/active")
def get_active_maps(db: Session = Depends(get_db)):
    return db.query(Map).filter(Map.active == True).all()


@router.get("/{map_id}/full")
def get_full_map(map_id: UUID, db: Session = Depends(get_db)):
    map_obj = (
        db.query(Map)
        .options(
            joinedload(Map.layers)
            .joinedload(MapLayer.blocks)
        )
        .filter(Map.id == map_id)
        .first()
    )

    if not map_obj:
        raise HTTPException(status_code=404, detail="Mapa não encontrado")

    return {
        "map": {
            "id": map_obj.id,
            "name": map_obj.name,
            "type": map_obj.type,
            "description": map_obj.description,
        },
        "layers": [
            {
                "id": layer.id,
                "name": layer.name,
                "type": layer.type,
                "blocks": [
                    {
                        "id": block.id,
                        "code": block.code,
                        "type": block.type,
                        "status": block.status,
                        "geometry": block.geometry,
                    }
                    for block in layer.blocks
                ],
            }
            for layer in map_obj.layers
        ],
    }

@router.get("/{map_id}/render")
def render_map(
    map_id: UUID,
    zoom: int = Query(..., ge=0, le=22),

    min_lng: float = Query(...),
    min_lat: float = Query(...),
    max_lng: float = Query(...),
    max_lat: float = Query(...),

    status: Optional[str] = Query(default=None),
    db: Session = Depends(get_db)
):
    tolerance = simplify_tolerance(zoom)
    bbox = ST_MakeEnvelope(min_lng, min_lat, max_lng, max_lat, 4326)
    bbox_str = f"{min_lng},{min_lat},{max_lng},{max_lat}"
    cache_key = build_cache_key(
        map_id=map_id,
        zoom=zoom,
        bbox=bbox_str,
        status=status or "all"
    )

    cached = redis_client.get(cache_key)
    if cached:
        return deserialize(cached)
    geom = MapBlock.geometry
    if tolerance > 0:
        geom = ST_Simplify(MapBlock.geometry, tolerance)
    rows = (
        db.query(
            MapLayer.id.label("layer_id"),
            MapLayer.name.label("layer_name"),
            MapLayer.type.label("layer_type"),

            MapBlock.id.label("block_id"),
            MapBlock.code,
            MapBlock.status,
            MapBlock.type.label("block_type"),

            ST_AsGeoJSON(geom).label("geometry")
        )
        .select_from(Map)
        .join(MapLayer, MapLayer.map_id == Map.id)
        .join(MapBlock, MapBlock.layer_id == MapLayer.id)
        .filter(
            Map.id == map_id,
            Map.active == True,
            ST_Intersects(MapBlock.geometry, bbox)
        )
    )

    if status:
        rows = rows.filter(MapBlock.status == status)

    rows = rows.all()
    layers: dict = {}

    for r in rows:
        layer = layers.setdefault(
            r.layer_id,
            {
                "id": str(r.layer_id),
                "name": r.layer_name,
                "type": r.layer_type,
                "featureCollection": {
                    "type": "FeatureCollection",
                    "features": []
                }
            }
        )

        layer["featureCollection"]["features"].append({
            "type": "Feature",
            "id": str(r.block_id),
            "properties": {
                "code": r.code,
                "status": r.status,
                "type": r.block_type
            },
            "geometry": json.loads(r.geometry)
        })

    response = {
        "map_id": str(map_id),
        "layers": list(layers.values())
    }
    redis_client.set(
        cache_key,
        serialize(response),
        ex=30  
    )

    return response


@router.post("/{map_id}/hit")
def hit_test(
    map_id: UUID,
    lng: float = Query(...),
    lat: float = Query(...),
    db: Session = Depends(get_db)
):

    point = ST_SetSRID(ST_Point(lng, lat), 4326)

    row = (
        db.query(
            MapBlock.id,
            MapBlock.code,
            MapBlock.status,
            MapBlock.type,
            MapLayer.id.label("layer_id"),
            MapLayer.name.label("layer_name"),
            MapLayer.type.label("layer_type"),
            MapBlock.geometry
        )
        .join(MapLayer, MapBlock.layer_id == MapLayer.id)
        .join(Map, MapLayer.map_id == Map.id)
        .filter(
            Map.id == map_id,
            Map.active == True,
            ST_Contains(MapBlock.geometry, point)
        )
        .first()
    )

    if not row:
        return {"hit": False}

    return {
        "hit": True,
        "block": {
            "id": str(row.id),
            "code": row.code,
            "status": row.status,
            "type": row.type,
            "layer": {
                "id": str(row.layer_id),
                "name": row.layer_name,
                "type": row.layer_type
            }
        }
    }


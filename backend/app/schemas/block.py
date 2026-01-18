from pydantic import BaseModel, field_validator


class BlockCreate(BaseModel):
    map_id: str
    layer_id: str
    code: str
    type: str
    geometry: dict

    @field_validator("geometry")
    @classmethod
    def validate_geometry(cls, value):
        if "type" not in value or "coordinates" not in value:
            raise ValueError("Geometry deve estar em formato GeoJSON")

        if value["type"] not in ["Polygon", "Point"]:
            raise ValueError("Geometry type não suportado")

        return value
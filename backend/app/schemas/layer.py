from pydantic import BaseModel, UUID4

class LayerCreate(BaseModel):
    map_id: UUID4
    name: str
    order: int = 0

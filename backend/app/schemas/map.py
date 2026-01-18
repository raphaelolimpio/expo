from pydantic import BaseModel

class MapCreate(BaseModel):
    name: str
    type: str 
    description: str | None = None

class MapResponse(BaseModel):
    id: int
    name: str
    type: str
    description: str | None
    active: bool

    class Config:
        from_attributes = True

from pydantic import BaseModel
from typing import Any, Optional, Dict
from uuid import UUID
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

class MapProjectUpdate(BaseModel):
    project_version: int = 1
    project_json: Dict[str, Any]

class MapProjectResponse(BaseModel):
    map_id: UUID
    project_version: int
    project_json: Dict[str, Any]

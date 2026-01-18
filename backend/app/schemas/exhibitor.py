from pydantic import BaseModel

class ExhibitorCreate(BaseModel):
    name: str
    description: str
    category: str
    block_id: str

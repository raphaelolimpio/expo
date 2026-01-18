from sqlalchemy import Column, String, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.db.base import Base

class Exhibitor(Base):
    __tablename__ = "exhibitors"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String)
    description = Column(String)
    category = Column(String)
    block_id = Column(UUID(as_uuid=True), ForeignKey("map_blocks.id"))

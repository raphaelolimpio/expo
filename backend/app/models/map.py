from sqlalchemy import Column, String, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID, JSONB
import uuid
from app.db.base import Base
from sqlalchemy.orm import relationship

class Map(Base):
    __tablename__ = "maps"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False)
    type = Column(String, nullable=False)
    description = Column(String)
    active = Column(Boolean, default=True)
    project_version = Column(Integer, nullable=False, default=1)
    project_json = Column(JSONB, nullable=True)


    layers = relationship("MapLayer", back_populates="map")

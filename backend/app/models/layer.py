from sqlalchemy import Column, String, Integer, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
import uuid
from app.db.base import Base
from sqlalchemy.orm import relationship

class MapLayer(Base):
    __tablename__ = "map_layers"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    map_id = Column(UUID(as_uuid=True), ForeignKey("maps.id"), nullable=False)

    name = Column(String, nullable=False)
    order = Column(Integer, default=0)
    map = relationship("Map", back_populates="layers")
    blocks = relationship("MapBlock", back_populates="layer")

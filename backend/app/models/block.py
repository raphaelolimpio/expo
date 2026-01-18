from sqlalchemy import Column, String, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
import uuid
from app.db.base import Base
from sqlalchemy.orm import relationship
from geoalchemy2 import Geometry

class MapBlock(Base):
    __tablename__ = "map_blocks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    map_id = Column(UUID(as_uuid=True), ForeignKey("maps.id"), nullable=False)
    layer_id = Column(UUID(as_uuid=True), ForeignKey("map_layers.id"), nullable=False)

    code = Column(String, nullable=False)
    type = Column(String, nullable=False)
    geometry = Column(Geometry(geometry_type="GEOMETRY", srid=4326))
    status = Column(String, default="livre")
    layer = relationship("MapLayer", back_populates="blocks")

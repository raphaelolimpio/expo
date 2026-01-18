from app.db.session import engine
from app.db.base import Base
from app.models import map, layer, block, exhibitor, schedule, user

def init_db():
    Base.metadata.create_all(bind=engine)

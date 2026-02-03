from fastapi import FastAPI
from app.routes import maps, blocks, exhibitors, schedules, layers
from app.db.init_db import init_db

app = FastAPI(title="Event Map API")

@app.on_event("startup")
def startup():
    init_db()

app.include_router(maps.router)
app.include_router(layers.router)
app.include_router(blocks.router)
app.include_router(exhibitors.router)
app.include_router(schedules.router)

from pydantic import BaseModel
from datetime import datetime

class ScheduleCreate(BaseModel):
    block_id: str
    title: str
    start_time: datetime
    end_time: datetime

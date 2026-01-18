import json
from uuid import UUID

def build_cache_key(
    map_id: UUID,
    zoom: int,
    bbox: str,
    status: str
) -> str:
    return f"map_render:{map_id}:{zoom}:{bbox}:{status}"


def serialize(data: dict) -> str:
    return json.dumps(data)


def deserialize(data: str) -> dict:
    return json.loads(data)

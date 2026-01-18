def normalize_geometry(geometry: dict) -> dict:
    geo_type = geometry.get("type")

    if geo_type == "Polygon":
        coords = geometry["coordinates"]

        if coords[0][0] != coords[0][-1]:
            coords[0].append(coords[0][0])

        return {
            "type": "Polygon",
            "coordinates": coords
        }

    if geo_type == "Point":
        return geometry

    raise ValueError("Geometry não suportada")
def simplify_tolerance(zoom: int) -> float:
    if zoom <= 12:
        return 0.001
    elif zoom <= 15:
        return 0.0005
    elif zoom <= 18:
        return 0.0001
    return 0

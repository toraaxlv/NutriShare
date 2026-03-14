import httpx
from app.config import settings

USDA_BASE_URL = "https://api.nal.usda.gov/fdc/v1"

async def search_usda(query: str, max_results: int = 10) -> list:
    """Search makanan dari USDA FoodData Central."""
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(
                f"{USDA_BASE_URL}/foods/search",
                params={
                    "query": query,
                    "api_key": settings.USDA_API_KEY,
                    "pageSize": max_results,
                }
            )
            response.raise_for_status()
            data = response.json()

            results = []
            for food in data.get("foods", []):
                nutrients = {n["nutrientName"]: n["value"] for n in food.get("foodNutrients", [])}
                calories = nutrients.get("Energy", nutrients.get("Energy (Atwater General Factors)", 0))
                if calories == 0:
                    continue
                results.append({
                    "name": food.get("description", "").title(),
                    "calories_per_100g":  calories,
                    "protein_per_100g":   nutrients.get("Protein", 0),
                    "carbs_per_100g":     nutrients.get("Carbohydrate, by difference", 0),
                    "fat_per_100g":       nutrients.get("Total lipid (fat)", 0),
                    "fiber_per_100g":     nutrients.get("Fiber, total dietary", 0),
                    "source": "usda"
                })
            return results

    except Exception as e:
        print(f"USDA API error: {e}")
        return []

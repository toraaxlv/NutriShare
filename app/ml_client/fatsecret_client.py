import httpx
import base64
from app.config import settings

FATSECRET_TOKEN_URL = "https://oauth.fatsecret.com/connect/token"
FATSECRET_API_URL   = "https://platform.fatsecret.com/rest/server.api"

async def get_fatsecret_token() -> str:
    """Ambil OAuth2 token dari FatSecret."""
    credentials = f"{settings.FATSECRET_CLIENT_ID}:{settings.FATSECRET_CLIENT_SECRET}"
    encoded = base64.b64encode(credentials.encode()).decode()

    async with httpx.AsyncClient(timeout=10.0) as client:
        response = await client.post(
            FATSECRET_TOKEN_URL,
            headers={
                "Authorization": f"Basic {encoded}",
                "Content-Type": "application/x-www-form-urlencoded"
            },
            data={"grant_type": "client_credentials", "scope": "basic"}
        )
        response.raise_for_status()
        return response.json().get("access_token", "")

async def search_fatsecret(query: str, max_results: int = 10) -> list:
    """Search makanan dari FatSecret API."""
    try:
        token = await get_fatsecret_token()

        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(
                FATSECRET_API_URL,
                headers={"Authorization": f"Bearer {token}"},
                params={
                    "method":          "foods.search",
                    "search_expression": query,
                    "format":          "json",
                    "max_results":     max_results,
                }
            )
            response.raise_for_status()
            data = response.json()

            foods = data.get("foods", {}).get("food", [])
            if isinstance(foods, dict):
                foods = [foods]  # kalau cuma 1 hasil, FatSecret return dict bukan list

            results = []
            for food in foods:
                desc = food.get("food_description", "")
                nutrients = parse_fatsecret_description(desc)
                results.append({
                    "name":             food.get("food_name", "").title(),
                    "calories_per_100g":  nutrients.get("calories", 0),
                    "protein_per_100g":   nutrients.get("protein", 0),
                    "carbs_per_100g":     nutrients.get("carbs", 0),
                    "fat_per_100g":       nutrients.get("fat", 0),
                    "fiber_per_100g":     0,
                    "source":           "fatsecret"
                })
            return results

    except Exception as e:
        print(f"FatSecret API error: {e}")
        return []

def parse_fatsecret_description(desc: str) -> dict:
    """
    Parse string seperti:
    'Per 100g - Calories: 89kcal | Fat: 0.33g | Carbs: 23.00g | Protein: 1.09g'
    """
    result = {"calories": 0, "fat": 0, "carbs": 0, "protein": 0}
    try:
        parts = desc.split("|")
        for part in parts:
            part = part.strip().lower()
            if "calories" in part:
                result["calories"] = float(part.split(":")[1].replace("kcal", "").strip())
            elif "fat" in part:
                result["fat"] = float(part.split(":")[1].replace("g", "").strip())
            elif "carbs" in part:
                result["carbs"] = float(part.split(":")[1].replace("g", "").strip())
            elif "protein" in part:
                result["protein"] = float(part.split(":")[1].replace("g", "").strip())
    except Exception:
        pass
    return result

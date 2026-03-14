import asyncio
import httpx
import base64
from app.config import settings

async def test_fatsecret_search():
    # Get token
    credentials = f"{settings.FATSECRET_CLIENT_ID}:{settings.FATSECRET_CLIENT_SECRET}"
    encoded = base64.b64encode(credentials.encode()).decode()

    async with httpx.AsyncClient(timeout=10.0) as client:
        # Get token
        token_res = await client.post(
            "https://oauth.fatsecret.com/connect/token",
            headers={
                "Authorization": f"Basic {encoded}",
                "Content-Type": "application/x-www-form-urlencoded"
            },
            data={"grant_type": "client_credentials", "scope": "basic"}
        )
        token = token_res.json()["access_token"]
        print(f"Token OK: {token[:30]}...")

        # Search
        search_res = await client.get(
            "https://platform.fatsecret.com/rest/server.api",
            headers={"Authorization": f"Bearer {token}"},
            params={
                "method": "foods.search",
                "search_expression": "nasi goreng",
                "format": "json",
                "max_results": 5,
            }
        )
        print(f"Search status: {search_res.status_code}")
        print(f"Response: {search_res.text[:500]}")

asyncio.run(test_fatsecret_search())

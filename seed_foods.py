# seed_foods.py — jalankan sekali untuk isi data makanan awal
from app.database import SessionLocal, engine
from app import models
from app.models.food_item import FoodItem

models.Base.metadata.create_all(bind=engine)

foods = [
    {"name": "Nasi Putih",        "calories_per_100g": 130, "protein_per_100g": 2.7,  "carbs_per_100g": 28.2, "fat_per_100g": 0.3},
    {"name": "Ayam Goreng",       "calories_per_100g": 246, "protein_per_100g": 22.0, "carbs_per_100g": 7.0,  "fat_per_100g": 14.0},
    {"name": "Telur Rebus",       "calories_per_100g": 155, "protein_per_100g": 13.0, "carbs_per_100g": 1.1,  "fat_per_100g": 11.0},
    {"name": "Tahu Goreng",       "calories_per_100g": 175, "protein_per_100g": 11.0, "carbs_per_100g": 4.0,  "fat_per_100g": 13.0},
    {"name": "Tempe Goreng",      "calories_per_100g": 195, "protein_per_100g": 14.0, "carbs_per_100g": 12.0, "fat_per_100g": 11.0},
    {"name": "Pisang",            "calories_per_100g": 89,  "protein_per_100g": 1.1,  "carbs_per_100g": 23.0, "fat_per_100g": 0.3},
    {"name": "Roti Gandum",       "calories_per_100g": 247, "protein_per_100g": 9.0,  "carbs_per_100g": 48.0, "fat_per_100g": 3.4},
    {"name": "Susu Full Cream",   "calories_per_100g": 61,  "protein_per_100g": 3.2,  "carbs_per_100g": 4.8,  "fat_per_100g": 3.3},
    {"name": "Dada Ayam Rebus",   "calories_per_100g": 165, "protein_per_100g": 31.0, "carbs_per_100g": 0.0,  "fat_per_100g": 3.6},
    {"name": "Kentang Rebus",     "calories_per_100g": 87,  "protein_per_100g": 1.9,  "carbs_per_100g": 20.0, "fat_per_100g": 0.1},
    {"name": "Kangkung Tumis",    "calories_per_100g": 45,  "protein_per_100g": 2.5,  "carbs_per_100g": 5.0,  "fat_per_100g": 2.0},
    {"name": "Ikan Salmon",       "calories_per_100g": 208, "protein_per_100g": 20.0, "carbs_per_100g": 0.0,  "fat_per_100g": 13.0},
    {"name": "Mie Goreng",        "calories_per_100g": 337, "protein_per_100g": 8.0,  "carbs_per_100g": 47.0, "fat_per_100g": 14.0},
    {"name": "Yogurt Plain",      "calories_per_100g": 59,  "protein_per_100g": 3.5,  "carbs_per_100g": 3.6,  "fat_per_100g": 3.3},
    {"name": "Oatmeal",           "calories_per_100g": 389, "protein_per_100g": 17.0, "carbs_per_100g": 66.0, "fat_per_100g": 7.0},
]

db = SessionLocal()
for f in foods:
    exists = db.query(FoodItem).filter(FoodItem.name == f["name"]).first()
    if not exists:
        db.add(FoodItem(**f, source="seeded"))
db.commit()
db.close()
print(f"✅ {len(foods)} food items berhasil di-seed!")
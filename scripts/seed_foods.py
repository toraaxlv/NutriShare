# seed_foods.py — jalankan sekali untuk isi data makanan awal
from app.database import SessionLocal, engine
from app import models
from app.models.food_item import FoodItem

models.Base.metadata.create_all(bind=engine)

foods = [
    # ── Karbohidrat pokok ────────────────────────────────────────────────────
    {"name": "Nasi Putih",          "calories_per_100g": 130, "protein_per_100g": 2.7,  "carbs_per_100g": 28.2, "fat_per_100g": 0.3,  "fiber_per_100g": 0.4},
    {"name": "Nasi Merah",          "calories_per_100g": 111, "protein_per_100g": 2.6,  "carbs_per_100g": 23.5, "fat_per_100g": 0.9,  "fiber_per_100g": 1.8},
    {"name": "Nasi Goreng",         "calories_per_100g": 170, "protein_per_100g": 5.0,  "carbs_per_100g": 30.0, "fat_per_100g": 4.5,  "fiber_per_100g": 0.5},
    {"name": "Nasi Uduk",           "calories_per_100g": 148, "protein_per_100g": 3.0,  "carbs_per_100g": 25.0, "fat_per_100g": 4.0,  "fiber_per_100g": 0.4},
    {"name": "Lontong",             "calories_per_100g": 81,  "protein_per_100g": 1.5,  "carbs_per_100g": 18.0, "fat_per_100g": 0.1,  "fiber_per_100g": 0.3},
    {"name": "Roti Tawar",          "calories_per_100g": 265, "protein_per_100g": 9.0,  "carbs_per_100g": 49.0, "fat_per_100g": 3.2,  "fiber_per_100g": 2.7},
    {"name": "Roti Gandum",         "calories_per_100g": 247, "protein_per_100g": 9.0,  "carbs_per_100g": 48.0, "fat_per_100g": 3.4,  "fiber_per_100g": 6.0},
    {"name": "Mie Goreng",          "calories_per_100g": 337, "protein_per_100g": 8.0,  "carbs_per_100g": 47.0, "fat_per_100g": 14.0, "fiber_per_100g": 1.5},
    {"name": "Mie Rebus",           "calories_per_100g": 138, "protein_per_100g": 5.0,  "carbs_per_100g": 28.0, "fat_per_100g": 0.5,  "fiber_per_100g": 0.8},
    {"name": "Ubi Jalar Rebus",     "calories_per_100g": 86,  "protein_per_100g": 1.6,  "carbs_per_100g": 20.0, "fat_per_100g": 0.1,  "fiber_per_100g": 3.0},
    {"name": "Singkong Rebus",      "calories_per_100g": 160, "protein_per_100g": 1.4,  "carbs_per_100g": 38.0, "fat_per_100g": 0.3,  "fiber_per_100g": 1.8},
    {"name": "Kentang Rebus",       "calories_per_100g": 87,  "protein_per_100g": 1.9,  "carbs_per_100g": 20.0, "fat_per_100g": 0.1,  "fiber_per_100g": 1.8},
    {"name": "Jagung Rebus",        "calories_per_100g": 96,  "protein_per_100g": 3.4,  "carbs_per_100g": 21.0, "fat_per_100g": 1.5,  "fiber_per_100g": 2.4},
    {"name": "Oatmeal",             "calories_per_100g": 389, "protein_per_100g": 17.0, "carbs_per_100g": 66.0, "fat_per_100g": 7.0,  "fiber_per_100g": 10.0},

    # ── Protein hewani ───────────────────────────────────────────────────────
    {"name": "Dada Ayam Rebus",     "calories_per_100g": 165, "protein_per_100g": 31.0, "carbs_per_100g": 0.0,  "fat_per_100g": 3.6,  "fiber_per_100g": 0.0},
    {"name": "Ayam Goreng",         "calories_per_100g": 246, "protein_per_100g": 22.0, "carbs_per_100g": 7.0,  "fat_per_100g": 14.0, "fiber_per_100g": 0.0},
    {"name": "Ayam Bakar",          "calories_per_100g": 187, "protein_per_100g": 25.0, "carbs_per_100g": 3.0,  "fat_per_100g": 8.0,  "fiber_per_100g": 0.0},
    {"name": "Sate Ayam",           "calories_per_100g": 200, "protein_per_100g": 20.0, "carbs_per_100g": 5.0,  "fat_per_100g": 11.0, "fiber_per_100g": 0.0},
    {"name": "Opor Ayam",           "calories_per_100g": 180, "protein_per_100g": 15.0, "carbs_per_100g": 4.0,  "fat_per_100g": 12.0, "fiber_per_100g": 0.0},
    {"name": "Rendang Sapi",        "calories_per_100g": 195, "protein_per_100g": 17.0, "carbs_per_100g": 5.0,  "fat_per_100g": 11.0, "fiber_per_100g": 0.5},
    {"name": "Daging Sapi Suwir",   "calories_per_100g": 250, "protein_per_100g": 26.0, "carbs_per_100g": 0.0,  "fat_per_100g": 15.0, "fiber_per_100g": 0.0},
    {"name": "Telur Rebus",         "calories_per_100g": 155, "protein_per_100g": 13.0, "carbs_per_100g": 1.1,  "fat_per_100g": 11.0, "fiber_per_100g": 0.0},
    {"name": "Telur Dadar",         "calories_per_100g": 185, "protein_per_100g": 11.0, "carbs_per_100g": 1.0,  "fat_per_100g": 15.0, "fiber_per_100g": 0.0},
    {"name": "Telur Ceplok",        "calories_per_100g": 196, "protein_per_100g": 13.6, "carbs_per_100g": 0.4,  "fat_per_100g": 15.4, "fiber_per_100g": 0.0},
    {"name": "Ikan Salmon",         "calories_per_100g": 208, "protein_per_100g": 20.0, "carbs_per_100g": 0.0,  "fat_per_100g": 13.0, "fiber_per_100g": 0.0},
    {"name": "Ikan Tuna",           "calories_per_100g": 132, "protein_per_100g": 28.0, "carbs_per_100g": 0.0,  "fat_per_100g": 1.0,  "fiber_per_100g": 0.0},
    {"name": "Ikan Kembung Goreng", "calories_per_100g": 177, "protein_per_100g": 20.0, "carbs_per_100g": 0.0,  "fat_per_100g": 10.0, "fiber_per_100g": 0.0},
    {"name": "Udang Rebus",         "calories_per_100g": 99,  "protein_per_100g": 24.0, "carbs_per_100g": 0.2,  "fat_per_100g": 0.3,  "fiber_per_100g": 0.0},
    {"name": "Bakso Sapi",          "calories_per_100g": 175, "protein_per_100g": 10.0, "carbs_per_100g": 18.0, "fat_per_100g": 7.0,  "fiber_per_100g": 0.5},

    # ── Protein nabati ───────────────────────────────────────────────────────
    {"name": "Tahu Goreng",         "calories_per_100g": 175, "protein_per_100g": 11.0, "carbs_per_100g": 4.0,  "fat_per_100g": 13.0, "fiber_per_100g": 0.3},
    {"name": "Tahu Rebus",          "calories_per_100g": 76,  "protein_per_100g": 8.1,  "carbs_per_100g": 1.9,  "fat_per_100g": 4.2,  "fiber_per_100g": 0.3},
    {"name": "Tempe Goreng",        "calories_per_100g": 195, "protein_per_100g": 14.0, "carbs_per_100g": 12.0, "fat_per_100g": 11.0, "fiber_per_100g": 1.4},
    {"name": "Tempe Bacem",         "calories_per_100g": 201, "protein_per_100g": 13.0, "carbs_per_100g": 15.0, "fat_per_100g": 10.0, "fiber_per_100g": 1.4},
    {"name": "Edamame",             "calories_per_100g": 121, "protein_per_100g": 11.0, "carbs_per_100g": 8.9,  "fat_per_100g": 5.2,  "fiber_per_100g": 5.2},
    {"name": "Kacang Tanah Goreng", "calories_per_100g": 567, "protein_per_100g": 25.0, "carbs_per_100g": 20.0, "fat_per_100g": 49.0, "fiber_per_100g": 8.0},
    {"name": "Kacang Almond",       "calories_per_100g": 579, "protein_per_100g": 21.0, "carbs_per_100g": 22.0, "fat_per_100g": 50.0, "fiber_per_100g": 12.5},

    # ── Sayuran ──────────────────────────────────────────────────────────────
    {"name": "Kangkung Tumis",      "calories_per_100g": 45,  "protein_per_100g": 2.5,  "carbs_per_100g": 5.0,  "fat_per_100g": 2.0,  "fiber_per_100g": 2.0},
    {"name": "Bayam Rebus",         "calories_per_100g": 23,  "protein_per_100g": 2.9,  "carbs_per_100g": 3.6,  "fat_per_100g": 0.4,  "fiber_per_100g": 2.2},
    {"name": "Brokoli Rebus",       "calories_per_100g": 35,  "protein_per_100g": 2.4,  "carbs_per_100g": 7.0,  "fat_per_100g": 0.4,  "fiber_per_100g": 2.6},
    {"name": "Wortel",              "calories_per_100g": 41,  "protein_per_100g": 0.9,  "carbs_per_100g": 10.0, "fat_per_100g": 0.2,  "fiber_per_100g": 2.8},
    {"name": "Tomat",               "calories_per_100g": 18,  "protein_per_100g": 0.9,  "carbs_per_100g": 3.9,  "fat_per_100g": 0.2,  "fiber_per_100g": 1.2},
    {"name": "Mentimun",            "calories_per_100g": 16,  "protein_per_100g": 0.7,  "carbs_per_100g": 3.6,  "fat_per_100g": 0.1,  "fiber_per_100g": 0.5},
    {"name": "Toge",                "calories_per_100g": 30,  "protein_per_100g": 3.0,  "carbs_per_100g": 5.9,  "fat_per_100g": 0.2,  "fiber_per_100g": 1.8},
    {"name": "Buncis Rebus",        "calories_per_100g": 35,  "protein_per_100g": 2.0,  "carbs_per_100g": 7.9,  "fat_per_100g": 0.3,  "fiber_per_100g": 3.4},
    {"name": "Cap Cay",             "calories_per_100g": 65,  "protein_per_100g": 4.0,  "carbs_per_100g": 8.0,  "fat_per_100g": 2.5,  "fiber_per_100g": 2.0},
    {"name": "Gado-Gado",           "calories_per_100g": 120, "protein_per_100g": 6.0,  "carbs_per_100g": 12.0, "fat_per_100g": 6.0,  "fiber_per_100g": 2.5},

    # ── Buah ─────────────────────────────────────────────────────────────────
    {"name": "Pisang",              "calories_per_100g": 89,  "protein_per_100g": 1.1,  "carbs_per_100g": 23.0, "fat_per_100g": 0.3,  "fiber_per_100g": 2.6},
    {"name": "Apel",                "calories_per_100g": 52,  "protein_per_100g": 0.3,  "carbs_per_100g": 14.0, "fat_per_100g": 0.2,  "fiber_per_100g": 2.4},
    {"name": "Jeruk",               "calories_per_100g": 47,  "protein_per_100g": 0.9,  "carbs_per_100g": 12.0, "fat_per_100g": 0.1,  "fiber_per_100g": 2.4},
    {"name": "Mangga",              "calories_per_100g": 60,  "protein_per_100g": 0.8,  "carbs_per_100g": 15.0, "fat_per_100g": 0.4,  "fiber_per_100g": 1.6},
    {"name": "Semangka",            "calories_per_100g": 30,  "protein_per_100g": 0.6,  "carbs_per_100g": 7.5,  "fat_per_100g": 0.2,  "fiber_per_100g": 0.4},
    {"name": "Pepaya",              "calories_per_100g": 43,  "protein_per_100g": 0.5,  "carbs_per_100g": 11.0, "fat_per_100g": 0.3,  "fiber_per_100g": 1.7},
    {"name": "Alpukat",             "calories_per_100g": 160, "protein_per_100g": 2.0,  "carbs_per_100g": 9.0,  "fat_per_100g": 15.0, "fiber_per_100g": 6.7},
    {"name": "Nanas",               "calories_per_100g": 50,  "protein_per_100g": 0.5,  "carbs_per_100g": 13.0, "fat_per_100g": 0.1,  "fiber_per_100g": 1.4},
    {"name": "Stroberi",            "calories_per_100g": 32,  "protein_per_100g": 0.7,  "carbs_per_100g": 7.7,  "fat_per_100g": 0.3,  "fiber_per_100g": 2.0},

    # ── Susu & produk susu ───────────────────────────────────────────────────
    {"name": "Susu Full Cream",     "calories_per_100g": 61,  "protein_per_100g": 3.2,  "carbs_per_100g": 4.8,  "fat_per_100g": 3.3,  "fiber_per_100g": 0.0},
    {"name": "Susu Skim",           "calories_per_100g": 34,  "protein_per_100g": 3.4,  "carbs_per_100g": 5.0,  "fat_per_100g": 0.1,  "fiber_per_100g": 0.0},
    {"name": "Yogurt Plain",        "calories_per_100g": 59,  "protein_per_100g": 3.5,  "carbs_per_100g": 3.6,  "fat_per_100g": 3.3,  "fiber_per_100g": 0.0},
    {"name": "Keju Cheddar",        "calories_per_100g": 403, "protein_per_100g": 25.0, "carbs_per_100g": 1.3,  "fat_per_100g": 33.0, "fiber_per_100g": 0.0},

    # ── Nasi spesial ─────────────────────────────────────────────────────────
    {"name": "Nasi Kuning",         "calories_per_100g": 150, "protein_per_100g": 3.0,  "carbs_per_100g": 29.0, "fat_per_100g": 2.5,  "fiber_per_100g": 0.4},
    {"name": "Nasi Goreng Spesial", "calories_per_100g": 185, "protein_per_100g": 7.0,  "carbs_per_100g": 28.0, "fat_per_100g": 6.0,  "fiber_per_100g": 0.6},
    {"name": "Nasi Padang",         "calories_per_100g": 175, "protein_per_100g": 5.0,  "carbs_per_100g": 32.0, "fat_per_100g": 4.0,  "fiber_per_100g": 0.5},
    {"name": "Nasi Bakar",          "calories_per_100g": 160, "protein_per_100g": 4.5,  "carbs_per_100g": 28.0, "fat_per_100g": 3.5,  "fiber_per_100g": 0.5},
    {"name": "Nasi Pecel",          "calories_per_100g": 145, "protein_per_100g": 5.0,  "carbs_per_100g": 25.0, "fat_per_100g": 3.5,  "fiber_per_100g": 1.5},
    {"name": "Nasi Campur Bali",    "calories_per_100g": 168, "protein_per_100g": 6.0,  "carbs_per_100g": 27.0, "fat_per_100g": 5.0,  "fiber_per_100g": 0.8},

    # ── Ayam berbagai olahan ─────────────────────────────────────────────────
    {"name": "Bubur Ayam",          "calories_per_100g": 95,  "protein_per_100g": 5.0,  "carbs_per_100g": 15.0, "fat_per_100g": 2.0,  "fiber_per_100g": 0.3},
    {"name": "Soto Ayam",           "calories_per_100g": 85,  "protein_per_100g": 8.0,  "carbs_per_100g": 8.0,  "fat_per_100g": 3.0,  "fiber_per_100g": 0.5},
    {"name": "Pecel Lele",          "calories_per_100g": 200, "protein_per_100g": 18.0, "carbs_per_100g": 5.0,  "fat_per_100g": 13.0, "fiber_per_100g": 0.5},
    {"name": "Ayam Geprek",         "calories_per_100g": 260, "protein_per_100g": 22.0, "carbs_per_100g": 8.0,  "fat_per_100g": 16.0, "fiber_per_100g": 0.5},
    {"name": "Ayam Penyet",         "calories_per_100g": 245, "protein_per_100g": 21.0, "carbs_per_100g": 7.0,  "fat_per_100g": 15.0, "fiber_per_100g": 0.5},
    {"name": "Ayam Rica-Rica",      "calories_per_100g": 210, "protein_per_100g": 20.0, "carbs_per_100g": 5.0,  "fat_per_100g": 13.0, "fiber_per_100g": 0.8},
    {"name": "Ayam Betutu",         "calories_per_100g": 225, "protein_per_100g": 19.0, "carbs_per_100g": 6.0,  "fat_per_100g": 14.0, "fiber_per_100g": 0.6},
    {"name": "Ayam Woku",           "calories_per_100g": 195, "protein_per_100g": 19.0, "carbs_per_100g": 4.0,  "fat_per_100g": 12.0, "fiber_per_100g": 0.6},
    {"name": "Chicken Katsu",       "calories_per_100g": 236, "protein_per_100g": 18.0, "carbs_per_100g": 14.0, "fat_per_100g": 12.0, "fiber_per_100g": 0.5},
    {"name": "Nugget Ayam",         "calories_per_100g": 297, "protein_per_100g": 14.0, "carbs_per_100g": 18.0, "fat_per_100g": 19.0, "fiber_per_100g": 0.5},
    {"name": "Sosis Ayam",          "calories_per_100g": 268, "protein_per_100g": 12.0, "carbs_per_100g": 10.0, "fat_per_100g": 21.0, "fiber_per_100g": 0.0},

    # ── Daging sapi & kambing ────────────────────────────────────────────────
    {"name": "Sate Sapi",           "calories_per_100g": 215, "protein_per_100g": 19.0, "carbs_per_100g": 5.0,  "fat_per_100g": 13.0, "fiber_per_100g": 0.0},
    {"name": "Sate Kambing",        "calories_per_100g": 220, "protein_per_100g": 17.0, "carbs_per_100g": 5.0,  "fat_per_100g": 14.0, "fiber_per_100g": 0.0},
    {"name": "Gulai Kambing",       "calories_per_100g": 190, "protein_per_100g": 14.0, "carbs_per_100g": 5.0,  "fat_per_100g": 13.0, "fiber_per_100g": 0.5},
    {"name": "Sop Buntut",          "calories_per_100g": 155, "protein_per_100g": 12.0, "carbs_per_100g": 5.0,  "fat_per_100g": 10.0, "fiber_per_100g": 0.5},
    {"name": "Tongseng Sapi",       "calories_per_100g": 180, "protein_per_100g": 14.0, "carbs_per_100g": 7.0,  "fat_per_100g": 11.0, "fiber_per_100g": 0.8},
    {"name": "Bakso Urat",          "calories_per_100g": 180, "protein_per_100g": 9.0,  "carbs_per_100g": 19.0, "fat_per_100g": 7.5,  "fiber_per_100g": 0.5},
    {"name": "Burger Sapi",         "calories_per_100g": 295, "protein_per_100g": 15.0, "carbs_per_100g": 24.0, "fat_per_100g": 15.0, "fiber_per_100g": 1.0},

    # ── Ikan & seafood ───────────────────────────────────────────────────────
    {"name": "Ikan Bakar",          "calories_per_100g": 155, "protein_per_100g": 22.0, "carbs_per_100g": 2.0,  "fat_per_100g": 6.5,  "fiber_per_100g": 0.0},
    {"name": "Ikan Goreng Tepung",  "calories_per_100g": 210, "protein_per_100g": 16.0, "carbs_per_100g": 12.0, "fat_per_100g": 11.0, "fiber_per_100g": 0.3},
    {"name": "Cumi Goreng",         "calories_per_100g": 185, "protein_per_100g": 17.0, "carbs_per_100g": 8.0,  "fat_per_100g": 10.0, "fiber_per_100g": 0.0},
    {"name": "Udang Goreng Tepung", "calories_per_100g": 240, "protein_per_100g": 18.0, "carbs_per_100g": 15.0, "fat_per_100g": 12.0, "fiber_per_100g": 0.3},
    {"name": "Kepiting Rebus",      "calories_per_100g": 97,  "protein_per_100g": 19.0, "carbs_per_100g": 0.0,  "fat_per_100g": 1.5,  "fiber_per_100g": 0.0},
    {"name": "Ikan Sardine Kaleng", "calories_per_100g": 208, "protein_per_100g": 24.0, "carbs_per_100g": 0.0,  "fat_per_100g": 12.0, "fiber_per_100g": 0.0},
    {"name": "Tuna Kalengan",       "calories_per_100g": 116, "protein_per_100g": 25.0, "carbs_per_100g": 0.0,  "fat_per_100g": 1.0,  "fiber_per_100g": 0.0},

    # ── Mie & pasta ──────────────────────────────────────────────────────────
    {"name": "Mie Ayam",            "calories_per_100g": 155, "protein_per_100g": 7.0,  "carbs_per_100g": 24.0, "fat_per_100g": 3.5,  "fiber_per_100g": 0.8},
    {"name": "Mie Bakso",           "calories_per_100g": 165, "protein_per_100g": 8.0,  "carbs_per_100g": 25.0, "fat_per_100g": 4.0,  "fiber_per_100g": 0.8},
    {"name": "Kwetiau Goreng",      "calories_per_100g": 180, "protein_per_100g": 6.0,  "carbs_per_100g": 30.0, "fat_per_100g": 5.0,  "fiber_per_100g": 0.5},
    {"name": "Bihun Goreng",        "calories_per_100g": 175, "protein_per_100g": 4.5,  "carbs_per_100g": 32.0, "fat_per_100g": 4.0,  "fiber_per_100g": 0.3},
    {"name": "Pasta Bolognese",     "calories_per_100g": 180, "protein_per_100g": 9.0,  "carbs_per_100g": 24.0, "fat_per_100g": 5.5,  "fiber_per_100g": 1.5},
    {"name": "Pasta Carbonara",     "calories_per_100g": 220, "protein_per_100g": 9.0,  "carbs_per_100g": 25.0, "fat_per_100g": 10.0, "fiber_per_100g": 1.0},
    {"name": "Mie Instan Rebus",    "calories_per_100g": 138, "protein_per_100g": 4.0,  "carbs_per_100g": 26.0, "fat_per_100g": 2.5,  "fiber_per_100g": 0.5},

    # ── Makanan tradisional & jajanan ────────────────────────────────────────
    {"name": "Martabak Telur",      "calories_per_100g": 280, "protein_per_100g": 14.0, "carbs_per_100g": 25.0, "fat_per_100g": 13.0, "fiber_per_100g": 0.5},
    {"name": "Martabak Manis",      "calories_per_100g": 310, "protein_per_100g": 6.0,  "carbs_per_100g": 48.0, "fat_per_100g": 11.0, "fiber_per_100g": 0.8},
    {"name": "Siomay",              "calories_per_100g": 130, "protein_per_100g": 9.0,  "carbs_per_100g": 14.0, "fat_per_100g": 4.0,  "fiber_per_100g": 0.5},
    {"name": "Batagor",             "calories_per_100g": 175, "protein_per_100g": 10.0, "carbs_per_100g": 18.0, "fat_per_100g": 7.0,  "fiber_per_100g": 0.5},
    {"name": "Pempek",              "calories_per_100g": 193, "protein_per_100g": 12.0, "carbs_per_100g": 24.0, "fat_per_100g": 5.5,  "fiber_per_100g": 0.5},
    {"name": "Lumpia Goreng",       "calories_per_100g": 220, "protein_per_100g": 7.0,  "carbs_per_100g": 24.0, "fat_per_100g": 11.0, "fiber_per_100g": 1.0},
    {"name": "Risoles",             "calories_per_100g": 215, "protein_per_100g": 7.0,  "carbs_per_100g": 22.0, "fat_per_100g": 11.0, "fiber_per_100g": 0.8},
    {"name": "Pastel",              "calories_per_100g": 240, "protein_per_100g": 6.0,  "carbs_per_100g": 25.0, "fat_per_100g": 13.0, "fiber_per_100g": 0.8},
    {"name": "Tahu Bulat Goreng",   "calories_per_100g": 190, "protein_per_100g": 10.0, "carbs_per_100g": 8.0,  "fat_per_100g": 14.0, "fiber_per_100g": 0.3},
    {"name": "Kerupuk Udang",       "calories_per_100g": 440, "protein_per_100g": 8.0,  "carbs_per_100g": 75.0, "fat_per_100g": 13.0, "fiber_per_100g": 0.5},
    {"name": "Kerupuk Aci",         "calories_per_100g": 400, "protein_per_100g": 1.0,  "carbs_per_100g": 90.0, "fat_per_100g": 4.0,  "fiber_per_100g": 0.5},
    {"name": "Cireng",              "calories_per_100g": 280, "protein_per_100g": 2.0,  "carbs_per_100g": 60.0, "fat_per_100g": 5.0,  "fiber_per_100g": 0.3},
    {"name": "Cilok",               "calories_per_100g": 170, "protein_per_100g": 5.0,  "carbs_per_100g": 30.0, "fat_per_100g": 3.5,  "fiber_per_100g": 0.3},
    {"name": "Lontong Sayur",       "calories_per_100g": 95,  "protein_per_100g": 3.0,  "carbs_per_100g": 16.0, "fat_per_100g": 2.5,  "fiber_per_100g": 1.0},
    {"name": "Ketoprak",            "calories_per_100g": 120, "protein_per_100g": 5.0,  "carbs_per_100g": 16.0, "fat_per_100g": 4.5,  "fiber_per_100g": 1.0},
    {"name": "Pecel",               "calories_per_100g": 95,  "protein_per_100g": 4.5,  "carbs_per_100g": 10.0, "fat_per_100g": 4.5,  "fiber_per_100g": 2.0},
    {"name": "Rujak Buah",          "calories_per_100g": 65,  "protein_per_100g": 1.0,  "carbs_per_100g": 15.0, "fat_per_100g": 0.5,  "fiber_per_100g": 1.5},
    {"name": "Es Campur",           "calories_per_100g": 95,  "protein_per_100g": 1.0,  "carbs_per_100g": 22.0, "fat_per_100g": 1.0,  "fiber_per_100g": 0.5},

    # ── Soto, sup & berkuah ──────────────────────────────────────────────────
    {"name": "Soto Betawi",         "calories_per_100g": 110, "protein_per_100g": 8.0,  "carbs_per_100g": 6.0,  "fat_per_100g": 6.5,  "fiber_per_100g": 0.5},
    {"name": "Soto Mie",            "calories_per_100g": 100, "protein_per_100g": 6.0,  "carbs_per_100g": 12.0, "fat_per_100g": 3.0,  "fiber_per_100g": 0.5},
    {"name": "Rawon",               "calories_per_100g": 115, "protein_per_100g": 9.0,  "carbs_per_100g": 5.0,  "fat_per_100g": 7.0,  "fiber_per_100g": 0.8},
    {"name": "Sup Ayam",            "calories_per_100g": 70,  "protein_per_100g": 7.0,  "carbs_per_100g": 5.0,  "fat_per_100g": 2.0,  "fiber_per_100g": 0.5},
    {"name": "Sup Bening Bayam",    "calories_per_100g": 30,  "protein_per_100g": 2.0,  "carbs_per_100g": 3.5,  "fat_per_100g": 0.5,  "fiber_per_100g": 1.0},
    {"name": "Sayur Asem",          "calories_per_100g": 35,  "protein_per_100g": 1.5,  "carbs_per_100g": 6.5,  "fat_per_100g": 0.5,  "fiber_per_100g": 1.5},
    {"name": "Sayur Lodeh",         "calories_per_100g": 65,  "protein_per_100g": 2.5,  "carbs_per_100g": 7.0,  "fat_per_100g": 3.5,  "fiber_per_100g": 1.5},
    {"name": "Gulai Sayur",         "calories_per_100g": 80,  "protein_per_100g": 3.0,  "carbs_per_100g": 7.0,  "fat_per_100g": 4.5,  "fiber_per_100g": 1.5},

    # ── Fast food & western ──────────────────────────────────────────────────
    {"name": "Pizza Keju",          "calories_per_100g": 266, "protein_per_100g": 11.0, "carbs_per_100g": 33.0, "fat_per_100g": 10.0, "fiber_per_100g": 2.0},
    {"name": "Kentang Goreng",      "calories_per_100g": 312, "protein_per_100g": 3.4,  "carbs_per_100g": 41.0, "fat_per_100g": 15.0, "fiber_per_100g": 3.8},
    {"name": "Hotdog",              "calories_per_100g": 290, "protein_per_100g": 11.0, "carbs_per_100g": 22.0, "fat_per_100g": 18.0, "fiber_per_100g": 0.9},
    {"name": "Sandwich Tuna",       "calories_per_100g": 190, "protein_per_100g": 12.0, "carbs_per_100g": 22.0, "fat_per_100g": 6.0,  "fiber_per_100g": 1.5},
    {"name": "Omelet Keju",         "calories_per_100g": 210, "protein_per_100g": 13.0, "carbs_per_100g": 2.0,  "fat_per_100g": 17.0, "fiber_per_100g": 0.0},

    # ── Sarapan & sereal ─────────────────────────────────────────────────────
    {"name": "Pancake",             "calories_per_100g": 227, "protein_per_100g": 6.0,  "carbs_per_100g": 37.0, "fat_per_100g": 7.0,  "fiber_per_100g": 1.0},
    {"name": "Granola",             "calories_per_100g": 471, "protein_per_100g": 10.0, "carbs_per_100g": 64.0, "fat_per_100g": 20.0, "fiber_per_100g": 6.0},
    {"name": "Cornflakes",          "calories_per_100g": 357, "protein_per_100g": 7.5,  "carbs_per_100g": 84.0, "fat_per_100g": 0.9,  "fiber_per_100g": 3.0},
    {"name": "Roti Bakar Selai",    "calories_per_100g": 285, "protein_per_100g": 7.0,  "carbs_per_100g": 50.0, "fat_per_100g": 6.5,  "fiber_per_100g": 2.0},

    # ── Minuman (per 100 ml) ─────────────────────────────────────────────────
    {"name": "Teh Manis",           "calories_per_100g": 35,  "protein_per_100g": 0.0,  "carbs_per_100g": 9.0,  "fat_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Kopi Susu Manis",     "calories_per_100g": 55,  "protein_per_100g": 1.5,  "carbs_per_100g": 9.0,  "fat_per_100g": 1.5,  "fiber_per_100g": 0.0},
    {"name": "Jus Jeruk",           "calories_per_100g": 45,  "protein_per_100g": 0.7,  "carbs_per_100g": 10.0, "fat_per_100g": 0.2,  "fiber_per_100g": 0.2},
    {"name": "Jus Alpukat",         "calories_per_100g": 110, "protein_per_100g": 1.5,  "carbs_per_100g": 12.0, "fat_per_100g": 6.5,  "fiber_per_100g": 2.0},
    {"name": "Susu Kedelai",        "calories_per_100g": 54,  "protein_per_100g": 3.3,  "carbs_per_100g": 6.3,  "fat_per_100g": 1.8,  "fiber_per_100g": 0.6},
    {"name": "Es Kopi Susu",        "calories_per_100g": 65,  "protein_per_100g": 1.5,  "carbs_per_100g": 10.0, "fat_per_100g": 2.0,  "fiber_per_100g": 0.0},

    # ── Snack & camilan ──────────────────────────────────────────────────────
    {"name": "Pisang Goreng",       "calories_per_100g": 197, "protein_per_100g": 1.5,  "carbs_per_100g": 35.0, "fat_per_100g": 6.5,  "fiber_per_100g": 2.0},
    {"name": "Ubi Goreng",          "calories_per_100g": 185, "protein_per_100g": 1.5,  "carbs_per_100g": 32.0, "fat_per_100g": 6.0,  "fiber_per_100g": 2.5},
    {"name": "Tempe Mendoan",       "calories_per_100g": 215, "protein_per_100g": 12.0, "carbs_per_100g": 14.0, "fat_per_100g": 13.0, "fiber_per_100g": 1.0},
    {"name": "Onde-Onde",           "calories_per_100g": 245, "protein_per_100g": 4.0,  "carbs_per_100g": 38.0, "fat_per_100g": 9.0,  "fiber_per_100g": 1.0},
    {"name": "Klepon",              "calories_per_100g": 175, "protein_per_100g": 2.5,  "carbs_per_100g": 35.0, "fat_per_100g": 3.0,  "fiber_per_100g": 0.5},
    {"name": "Getuk",               "calories_per_100g": 168, "protein_per_100g": 1.2,  "carbs_per_100g": 38.0, "fat_per_100g": 1.5,  "fiber_per_100g": 1.5},
    {"name": "Donat",               "calories_per_100g": 452, "protein_per_100g": 7.0,  "carbs_per_100g": 51.0, "fat_per_100g": 25.0, "fiber_per_100g": 1.5},
    {"name": "Biskuit Marie",       "calories_per_100g": 428, "protein_per_100g": 7.0,  "carbs_per_100g": 75.0, "fat_per_100g": 11.0, "fiber_per_100g": 1.5},
    {"name": "Cokelat Batang",      "calories_per_100g": 546, "protein_per_100g": 5.0,  "carbs_per_100g": 60.0, "fat_per_100g": 31.0, "fiber_per_100g": 3.4},

    # ── Bebek & unggas lain ──────────────────────────────────────────────────
    {"name": "Bebek Goreng",        "calories_per_100g": 337, "protein_per_100g": 19.0, "carbs_per_100g": 4.0,  "fat_per_100g": 28.0, "fiber_per_100g": 0.0},
    {"name": "Bebek Bakar",         "calories_per_100g": 255, "protein_per_100g": 21.0, "carbs_per_100g": 3.0,  "fat_per_100g": 17.0, "fiber_per_100g": 0.0},
    {"name": "Bebek Betutu",        "calories_per_100g": 270, "protein_per_100g": 20.0, "carbs_per_100g": 5.0,  "fat_per_100g": 19.0, "fiber_per_100g": 0.5},
    {"name": "Daging Babi Panggang","calories_per_100g": 297, "protein_per_100g": 24.0, "carbs_per_100g": 0.0,  "fat_per_100g": 21.0, "fiber_per_100g": 0.0},

    # ── Ikan air tawar ───────────────────────────────────────────────────────
    {"name": "Ikan Gurame Goreng",  "calories_per_100g": 190, "protein_per_100g": 19.0, "carbs_per_100g": 3.0,  "fat_per_100g": 11.0, "fiber_per_100g": 0.0},
    {"name": "Ikan Nila Goreng",    "calories_per_100g": 175, "protein_per_100g": 20.0, "carbs_per_100g": 2.0,  "fat_per_100g": 10.0, "fiber_per_100g": 0.0},
    {"name": "Ikan Lele Goreng",    "calories_per_100g": 200, "protein_per_100g": 18.0, "carbs_per_100g": 5.0,  "fat_per_100g": 12.0, "fiber_per_100g": 0.0},
    {"name": "Ikan Bawal Bakar",    "calories_per_100g": 160, "protein_per_100g": 21.0, "carbs_per_100g": 2.0,  "fat_per_100g": 8.0,  "fiber_per_100g": 0.0},
    {"name": "Ikan Patin Goreng",   "calories_per_100g": 185, "protein_per_100g": 17.0, "carbs_per_100g": 4.0,  "fat_per_100g": 11.0, "fiber_per_100g": 0.0},
    {"name": "Cumi Bakar",          "calories_per_100g": 110, "protein_per_100g": 18.0, "carbs_per_100g": 3.0,  "fat_per_100g": 2.5,  "fiber_per_100g": 0.0},

    # ── Nasi & lauk khas daerah ──────────────────────────────────────────────
    {"name": "Nasi Liwet",          "calories_per_100g": 162, "protein_per_100g": 3.5,  "carbs_per_100g": 28.0, "fat_per_100g": 4.0,  "fiber_per_100g": 0.5},
    {"name": "Nasi Kebuli",         "calories_per_100g": 190, "protein_per_100g": 5.0,  "carbs_per_100g": 30.0, "fat_per_100g": 6.0,  "fiber_per_100g": 0.5},
    {"name": "Nasi Tim Ayam",       "calories_per_100g": 140, "protein_per_100g": 7.0,  "carbs_per_100g": 22.0, "fat_per_100g": 2.5,  "fiber_per_100g": 0.4},
    {"name": "Nasi Kucing",         "calories_per_100g": 145, "protein_per_100g": 4.0,  "carbs_per_100g": 26.0, "fat_per_100g": 3.0,  "fiber_per_100g": 0.5},
    {"name": "Ketupat",             "calories_per_100g": 84,  "protein_per_100g": 1.5,  "carbs_per_100g": 19.0, "fat_per_100g": 0.1,  "fiber_per_100g": 0.3},

    # ── Sate khas daerah ─────────────────────────────────────────────────────
    {"name": "Sate Padang",         "calories_per_100g": 210, "protein_per_100g": 16.0, "carbs_per_100g": 8.0,  "fat_per_100g": 13.0, "fiber_per_100g": 0.5},
    {"name": "Sate Lilit",          "calories_per_100g": 205, "protein_per_100g": 15.0, "carbs_per_100g": 7.0,  "fat_per_100g": 13.0, "fiber_per_100g": 0.5},
    {"name": "Sate Taichan",        "calories_per_100g": 175, "protein_per_100g": 19.0, "carbs_per_100g": 2.0,  "fat_per_100g": 10.0, "fiber_per_100g": 0.0},
    {"name": "Sate Maranggi",       "calories_per_100g": 220, "protein_per_100g": 18.0, "carbs_per_100g": 6.0,  "fat_per_100g": 14.0, "fiber_per_100g": 0.0},

    # ── Sup & soto khas daerah ───────────────────────────────────────────────
    {"name": "Soto Lamongan",       "calories_per_100g": 90,  "protein_per_100g": 8.0,  "carbs_per_100g": 7.0,  "fat_per_100g": 3.5,  "fiber_per_100g": 0.5},
    {"name": "Coto Makassar",       "calories_per_100g": 125, "protein_per_100g": 10.0, "carbs_per_100g": 6.0,  "fat_per_100g": 7.0,  "fiber_per_100g": 0.5},
    {"name": "Sup Iga Sapi",        "calories_per_100g": 130, "protein_per_100g": 11.0, "carbs_per_100g": 5.0,  "fat_per_100g": 8.0,  "fiber_per_100g": 0.5},
    {"name": "Konro Bakar",         "calories_per_100g": 250, "protein_per_100g": 18.0, "carbs_per_100g": 5.0,  "fat_per_100g": 18.0, "fiber_per_100g": 0.3},
    {"name": "Sop Kaki Sapi",       "calories_per_100g": 105, "protein_per_100g": 9.0,  "carbs_per_100g": 4.0,  "fat_per_100g": 6.5,  "fiber_per_100g": 0.3},

    # ── Tumisan & oseng ──────────────────────────────────────────────────────
    {"name": "Oseng Tempe Kecap",   "calories_per_100g": 210, "protein_per_100g": 12.0, "carbs_per_100g": 16.0, "fat_per_100g": 11.0, "fiber_per_100g": 1.5},
    {"name": "Oseng Buncis Wortel", "calories_per_100g": 55,  "protein_per_100g": 2.0,  "carbs_per_100g": 8.0,  "fat_per_100g": 2.0,  "fiber_per_100g": 2.5},
    {"name": "Tumis Tahu Tempe",    "calories_per_100g": 160, "protein_per_100g": 11.0, "carbs_per_100g": 8.0,  "fat_per_100g": 10.0, "fiber_per_100g": 1.0},
    {"name": "Tumis Kangkung Udang","calories_per_100g": 80,  "protein_per_100g": 7.0,  "carbs_per_100g": 5.0,  "fat_per_100g": 4.0,  "fiber_per_100g": 1.5},
    {"name": "Sambal Goreng Ati",   "calories_per_100g": 175, "protein_per_100g": 14.0, "carbs_per_100g": 6.0,  "fat_per_100g": 11.0, "fiber_per_100g": 0.5},
    {"name": "Terong Balado",       "calories_per_100g": 70,  "protein_per_100g": 2.0,  "carbs_per_100g": 8.0,  "fat_per_100g": 4.0,  "fiber_per_100g": 2.5},
    {"name": "Kacang Panjang Tumis","calories_per_100g": 50,  "protein_per_100g": 2.5,  "carbs_per_100g": 7.0,  "fat_per_100g": 2.0,  "fiber_per_100g": 2.0},

    # ── Sayuran tambahan ─────────────────────────────────────────────────────
    {"name": "Terong",              "calories_per_100g": 25,  "protein_per_100g": 1.0,  "carbs_per_100g": 6.0,  "fat_per_100g": 0.2,  "fiber_per_100g": 3.0},
    {"name": "Labu Siam",           "calories_per_100g": 19,  "protein_per_100g": 0.8,  "carbs_per_100g": 4.5,  "fat_per_100g": 0.1,  "fiber_per_100g": 1.7},
    {"name": "Pare",                "calories_per_100g": 17,  "protein_per_100g": 1.0,  "carbs_per_100g": 3.7,  "fat_per_100g": 0.2,  "fiber_per_100g": 2.8},
    {"name": "Daun Singkong Rebus", "calories_per_100g": 38,  "protein_per_100g": 4.0,  "carbs_per_100g": 5.0,  "fat_per_100g": 0.5,  "fiber_per_100g": 2.0},
    {"name": "Nangka Muda Rebus",   "calories_per_100g": 65,  "protein_per_100g": 2.0,  "carbs_per_100g": 14.0, "fat_per_100g": 0.3,  "fiber_per_100g": 1.5},
    {"name": "Rebung Rebus",        "calories_per_100g": 27,  "protein_per_100g": 2.6,  "carbs_per_100g": 5.2,  "fat_per_100g": 0.3,  "fiber_per_100g": 2.2},
    {"name": "Jamur Tiram Tumis",   "calories_per_100g": 45,  "protein_per_100g": 3.3,  "carbs_per_100g": 6.0,  "fat_per_100g": 1.5,  "fiber_per_100g": 2.3},
    {"name": "Daun Pepaya Rebus",   "calories_per_100g": 32,  "protein_per_100g": 3.5,  "carbs_per_100g": 4.0,  "fat_per_100g": 0.4,  "fiber_per_100g": 2.5},

    # ── Buah tropis tambahan ─────────────────────────────────────────────────
    {"name": "Durian",              "calories_per_100g": 147, "protein_per_100g": 1.5,  "carbs_per_100g": 27.0, "fat_per_100g": 5.3,  "fiber_per_100g": 3.8},
    {"name": "Rambutan",            "calories_per_100g": 68,  "protein_per_100g": 0.9,  "carbs_per_100g": 16.0, "fat_per_100g": 0.2,  "fiber_per_100g": 0.9},
    {"name": "Jambu Air",           "calories_per_100g": 25,  "protein_per_100g": 0.6,  "carbs_per_100g": 5.7,  "fat_per_100g": 0.3,  "fiber_per_100g": 0.5},
    {"name": "Jambu Biji",          "calories_per_100g": 68,  "protein_per_100g": 2.6,  "carbs_per_100g": 14.0, "fat_per_100g": 1.0,  "fiber_per_100g": 5.4},
    {"name": "Salak",               "calories_per_100g": 77,  "protein_per_100g": 0.8,  "carbs_per_100g": 20.0, "fat_per_100g": 0.1,  "fiber_per_100g": 2.8},
    {"name": "Manggis",             "calories_per_100g": 73,  "protein_per_100g": 0.4,  "carbs_per_100g": 18.0, "fat_per_100g": 0.6,  "fiber_per_100g": 1.8},
    {"name": "Sirsak",              "calories_per_100g": 66,  "protein_per_100g": 1.0,  "carbs_per_100g": 16.0, "fat_per_100g": 0.3,  "fiber_per_100g": 3.3},
    {"name": "Leci",                "calories_per_100g": 66,  "protein_per_100g": 0.8,  "carbs_per_100g": 17.0, "fat_per_100g": 0.4,  "fiber_per_100g": 1.3},
    {"name": "Melon",               "calories_per_100g": 34,  "protein_per_100g": 0.8,  "carbs_per_100g": 8.2,  "fat_per_100g": 0.2,  "fiber_per_100g": 0.9},
    {"name": "Anggur",              "calories_per_100g": 69,  "protein_per_100g": 0.7,  "carbs_per_100g": 18.0, "fat_per_100g": 0.2,  "fiber_per_100g": 0.9},
    {"name": "Kiwi",                "calories_per_100g": 61,  "protein_per_100g": 1.1,  "carbs_per_100g": 15.0, "fat_per_100g": 0.5,  "fiber_per_100g": 3.0},
    {"name": "Blueberry",           "calories_per_100g": 57,  "protein_per_100g": 0.7,  "carbs_per_100g": 14.0, "fat_per_100g": 0.3,  "fiber_per_100g": 2.4},

    # ── Kue & jajan pasar ────────────────────────────────────────────────────
    {"name": "Serabi",              "calories_per_100g": 185, "protein_per_100g": 3.5,  "carbs_per_100g": 33.0, "fat_per_100g": 5.0,  "fiber_per_100g": 0.5},
    {"name": "Dadar Gulung",        "calories_per_100g": 170, "protein_per_100g": 3.0,  "carbs_per_100g": 28.0, "fat_per_100g": 5.5,  "fiber_per_100g": 1.0},
    {"name": "Kue Lapis",           "calories_per_100g": 195, "protein_per_100g": 2.5,  "carbs_per_100g": 38.0, "fat_per_100g": 4.5,  "fiber_per_100g": 0.3},
    {"name": "Wajik",               "calories_per_100g": 210, "protein_per_100g": 2.0,  "carbs_per_100g": 46.0, "fat_per_100g": 3.0,  "fiber_per_100g": 0.5},
    {"name": "Kue Putu",            "calories_per_100g": 165, "protein_per_100g": 2.5,  "carbs_per_100g": 33.0, "fat_per_100g": 3.0,  "fiber_per_100g": 1.0},
    {"name": "Wingko Babat",        "calories_per_100g": 295, "protein_per_100g": 3.5,  "carbs_per_100g": 50.0, "fat_per_100g": 9.0,  "fiber_per_100g": 2.0},
    {"name": "Bika Ambon",          "calories_per_100g": 285, "protein_per_100g": 4.5,  "carbs_per_100g": 47.0, "fat_per_100g": 9.0,  "fiber_per_100g": 0.3},
    {"name": "Kue Bolu",            "calories_per_100g": 340, "protein_per_100g": 6.0,  "carbs_per_100g": 52.0, "fat_per_100g": 12.0, "fiber_per_100g": 0.5},
    {"name": "Lapis Legit",         "calories_per_100g": 410, "protein_per_100g": 6.0,  "carbs_per_100g": 48.0, "fat_per_100g": 22.0, "fiber_per_100g": 0.3},
    {"name": "Brownies",            "calories_per_100g": 415, "protein_per_100g": 5.0,  "carbs_per_100g": 55.0, "fat_per_100g": 20.0, "fiber_per_100g": 2.0},
    {"name": "Cheesecake",          "calories_per_100g": 321, "protein_per_100g": 5.5,  "carbs_per_100g": 26.0, "fat_per_100g": 22.0, "fiber_per_100g": 0.3},
    {"name": "Pudding Susu",        "calories_per_100g": 110, "protein_per_100g": 3.0,  "carbs_per_100g": 18.0, "fat_per_100g": 3.0,  "fiber_per_100g": 0.0},
    {"name": "Es Krim Vanila",      "calories_per_100g": 207, "protein_per_100g": 3.5,  "carbs_per_100g": 24.0, "fat_per_100g": 11.0, "fiber_per_100g": 0.0},

    # ── Minuman tambahan ─────────────────────────────────────────────────────
    {"name": "Air Kelapa",          "calories_per_100g": 19,  "protein_per_100g": 0.7,  "carbs_per_100g": 3.7,  "fat_per_100g": 0.2,  "fiber_per_100g": 1.1},
    {"name": "Jus Mangga",          "calories_per_100g": 60,  "protein_per_100g": 0.4,  "carbs_per_100g": 15.0, "fat_per_100g": 0.1,  "fiber_per_100g": 0.3},
    {"name": "Jus Semangka",        "calories_per_100g": 30,  "protein_per_100g": 0.5,  "carbs_per_100g": 7.5,  "fat_per_100g": 0.1,  "fiber_per_100g": 0.2},
    {"name": "Susu Cokelat",        "calories_per_100g": 83,  "protein_per_100g": 3.4,  "carbs_per_100g": 11.0, "fat_per_100g": 2.5,  "fiber_per_100g": 0.3},
    {"name": "Teh Tarik",           "calories_per_100g": 60,  "protein_per_100g": 1.5,  "carbs_per_100g": 10.0, "fat_per_100g": 1.5,  "fiber_per_100g": 0.0},
    {"name": "Kopi Hitam",          "calories_per_100g": 2,   "protein_per_100g": 0.3,  "carbs_per_100g": 0.0,  "fat_per_100g": 0.0,  "fiber_per_100g": 0.0},
    {"name": "Es Jeruk",            "calories_per_100g": 40,  "protein_per_100g": 0.5,  "carbs_per_100g": 10.0, "fat_per_100g": 0.1,  "fiber_per_100g": 0.2},
    {"name": "Wedang Jahe",         "calories_per_100g": 25,  "protein_per_100g": 0.1,  "carbs_per_100g": 6.0,  "fat_per_100g": 0.1,  "fiber_per_100g": 0.0},

    # ── Makanan diet & sehat ─────────────────────────────────────────────────
    {"name": "Greek Yogurt",        "calories_per_100g": 97,  "protein_per_100g": 9.0,  "carbs_per_100g": 3.6,  "fat_per_100g": 5.0,  "fiber_per_100g": 0.0},
    {"name": "Quinoa Rebus",        "calories_per_100g": 120, "protein_per_100g": 4.4,  "carbs_per_100g": 21.0, "fat_per_100g": 1.9,  "fiber_per_100g": 2.8},
    {"name": "Chia Seed",           "calories_per_100g": 486, "protein_per_100g": 17.0, "carbs_per_100g": 42.0, "fat_per_100g": 31.0, "fiber_per_100g": 34.0},
    {"name": "Protein Shake",       "calories_per_100g": 120, "protein_per_100g": 24.0, "carbs_per_100g": 5.0,  "fat_per_100g": 2.0,  "fiber_per_100g": 1.0},
    {"name": "Whey Protein",        "calories_per_100g": 370, "protein_per_100g": 78.0, "carbs_per_100g": 9.0,  "fat_per_100g": 4.0,  "fiber_per_100g": 0.5},
    {"name": "Telur Putih Rebus",   "calories_per_100g": 52,  "protein_per_100g": 11.0, "carbs_per_100g": 0.7,  "fat_per_100g": 0.2,  "fiber_per_100g": 0.0},
    {"name": "Smoothie Alpukat",    "calories_per_100g": 130, "protein_per_100g": 2.0,  "carbs_per_100g": 14.0, "fat_per_100g": 8.0,  "fiber_per_100g": 3.5},
    {"name": "Salad Sayur",         "calories_per_100g": 35,  "protein_per_100g": 2.0,  "carbs_per_100g": 5.0,  "fat_per_100g": 1.0,  "fiber_per_100g": 2.0},
    {"name": "Salad Buah",          "calories_per_100g": 55,  "protein_per_100g": 0.8,  "carbs_per_100g": 13.0, "fat_per_100g": 0.3,  "fiber_per_100g": 1.5},

    # ── Condiment & pelengkap ────────────────────────────────────────────────
    {"name": "Sambal Terasi",       "calories_per_100g": 65,  "protein_per_100g": 2.0,  "carbs_per_100g": 8.0,  "fat_per_100g": 3.5,  "fiber_per_100g": 1.5},
    {"name": "Kecap Manis",         "calories_per_100g": 257, "protein_per_100g": 5.0,  "carbs_per_100g": 57.0, "fat_per_100g": 0.5,  "fiber_per_100g": 0.5},
    {"name": "Saus Tomat",          "calories_per_100g": 97,  "protein_per_100g": 1.0,  "carbs_per_100g": 24.0, "fat_per_100g": 0.1,  "fiber_per_100g": 0.5},
    {"name": "Mayonaise",           "calories_per_100g": 680, "protein_per_100g": 1.0,  "carbs_per_100g": 1.0,  "fat_per_100g": 75.0, "fiber_per_100g": 0.0},
    {"name": "Saus Kacang",         "calories_per_100g": 280, "protein_per_100g": 8.0,  "carbs_per_100g": 22.0, "fat_per_100g": 19.0, "fiber_per_100g": 2.5},
    {"name": "Minyak Zaitun",       "calories_per_100g": 884, "protein_per_100g": 0.0,  "carbs_per_100g": 0.0,  "fat_per_100g": 100.0,"fiber_per_100g": 0.0},
    {"name": "Mentega",             "calories_per_100g": 717, "protein_per_100g": 0.9,  "carbs_per_100g": 0.1,  "fat_per_100g": 81.0, "fiber_per_100g": 0.0},
]

db = SessionLocal()
for f in foods:
    exists = db.query(FoodItem).filter(FoodItem.name == f["name"]).first()
    if not exists:
        db.add(FoodItem(**f, source="seeded"))
db.commit()
db.close()
print(f"✅ {len(foods)} food items berhasil di-seed!")
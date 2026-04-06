# 🥗 NutriShare — Pengembangan Piranti Lunak

Repository ini merupakan repository bersama untuk project dari matakuliah **PENGEMBANGAN PIRANTI LUNAK**, **INTERAKSI MANUSIA & KOMPUTER**, dan **PEMODELAN BERORIENTASI OBJEK**

---

## Identitas Tim

| Nama | NIM | Email |
|------|-----|-------|
| Tora Alvaro | 01082240007 | [tora.alvaro@gmail.com](mailto:tora.alvaro@gmail.com) |
| Evan Laluan | 01082240015 | [Laluanevan2508@gmail.com](mailto:Laluanevan2508@gmail.com) |
| Jeremy Ivanka Nursalim | 01082240003 | [ivanka.jeremy18@gmail.com](mailto:ivanka.jeremy18@gmail.com) |
| Daniel Gilberth Octavianus Latupeirissa | 01082240027 | [daniellatupeirissa64@gmail.com](mailto:daniellatupeirissa64@gmail.com) |
| Josh | 01082240033 | [joshethanw@gmail.com](mailto:joshethanw@gmail.com) |

---

## Tentang Aplikasi

**NutriShare** adalah aplikasi mobile tracking nutrisi yang membantu pengguna memantau asupan kalori dan makronutrien harian, serta mendapatkan feedback berbasis machine learning tentang pola makan mereka.

## Tech Stack
- **FastAPI** — Python backend API
- **PostgreSQL** — Database
- **SQLAlchemy** — ORM
- **JWT** — Authentication
- **USDA FoodData Central API** — Food nutrition database (English)
- **FatSecret API** — Additional food database (Bahasa Indonesia)

---

## Setup Development (Backend)

### 1. Clone repo
```bash
git clone https://github.com/toraaxlv/NutriShare.git
cd NutriShare
```

### 2. Buat virtual environment
```bash
python3 -m venv venv
source venv/bin/activate        # macOS/Linux
venv\Scripts\activate           # Windows
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

### 4. Setup database PostgreSQL
```bash
psql postgres
```
```sql
CREATE USER nutrishare_user WITH PASSWORD 'nutrishare123';
CREATE DATABASE nutrishare_db OWNER nutrishare_user;
GRANT ALL PRIVILEGES ON DATABASE nutrishare_db TO nutrishare_user;
\q
```

### 5. Setup environment variables
```bash
cp .env.example .env
```
Edit `.env` dan isi semua nilai yang diperlukan:
```env
DATABASE_URL=postgresql://nutrishare_user:YOUR_PASSWORD@localhost:5432/nutrishare_db
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
ML_SERVICE_URL=http://localhost:8001
USDA_API_KEY=your-usda-api-key
FATSECRET_CLIENT_ID=your-fatsecret-client-id
FATSECRET_CLIENT_SECRET=your-fatsecret-client-secret
```

> ⚠️ Jangan pernah commit file `.env` ke GitHub

### 6. Seed data makanan
```bash
python seed_foods.py
```

### 7. Jalankan server
```bash
uvicorn app.main:app --reload --port 8000
```

### 8. Buka API docs
```
http://localhost:8000/docs
```

---

## API Endpoints

### 🔐 Auth
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | /api/v1/auth/register | Daftar akun baru |
| POST | /api/v1/auth/login | Login & dapat JWT token |

### 👤 Profile
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | /api/v1/profile | Lihat profile |
| PUT | /api/v1/profile | Update profile |
| GET | /api/v1/profile/targets | Lihat kalori & makro target harian |

### 🍎 Foods
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | /api/v1/foods/search?q= | Cari makanan (lokal + USDA) |
| GET | /api/v1/foods | List semua makanan di database |

### 📋 Logs
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | /api/v1/logs | Log makanan |
| GET | /api/v1/logs?log_date= | Lihat log harian |
| DELETE | /api/v1/logs/{id} | Hapus log |
| GET | /api/v1/logs/summary?log_date= | Summary nutrisi harian vs target |

---

## Project Structure
```
nutrishare-backend/
├── app/
│   ├── models/          # SQLAlchemy ORM models
│   ├── schemas/         # Pydantic request/response schemas
│   ├── routers/         # HTTP route handlers
│   ├── services/        # Business logic
│   ├── repositories/    # Database queries
│   ├── ml_client/       # USDA & FatSecret API clients
│   ├── main.py          # FastAPI app entry point
│   ├── database.py      # DB connection
│   └── config.py        # Environment settings
├── seed_foods.py        # Seed data makanan Indonesia
├── .env.example         # Template environment variables
└── requirements.txt
```

---

## External APIs
- **USDA FoodData Central** — Daftar API key gratis di https://fdc.nal.usda.gov/api-key-signup.html
- **FatSecret** — Daftar developer account di https://platform.fatsecret.com

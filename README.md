# NutriShare

Aplikasi mobile tracking nutrisi harian dengan backend FastAPI dan Flutter. Dikembangkan sebagai project matakuliah **Pengembangan Piranti Lunak**, **Interaksi Manusia & Komputer**, dan **Pemodelan Berorientasi Objek**.

---

## Tim
**Tora Alvaro** — 01082240007  |  [tora.alvaro@gmail.com](mailto:tora.alvaro@gmail.com) <br/>
**Evan Laluan** — 01082240015  |   [Laluanevan2508@gmail.com](mailto:Laluanevan2508@gmail.com) <br/>
**Jeremy Ivanka Nursalim** — 01082240003 |   [ivanka.jeremy18@gmail.com](mailto:ivanka.jeremy18@gmail.com) <br/>
**Daniel Gilberth Octavianus Latupeirissa** — 01082240027 |   [daniellatupeirissa64@gmail.com](mailto:daniellatupeirissa64@gmail.com) <br/>
**Josh** — 01082240033 |   [joshethanw@gmail.com](mailto:joshethanw@gmail.com) <br/>
---

## Fitur

- Pencatatan makanan harian (breakfast, lunch, dinner, snack)
- Kalkulasi kalori & makronutrien otomatis (protein, karbohidrat, lemak)
- Target nutrisi personal berdasarkan profil (gender, usia, berat, tinggi, aktivitas, goal)
- Pencarian makanan dari database lokal + USDA FoodData Central + FatSecret
- Custom food — buat dan simpan makanan sendiri
- Log berat badan dengan grafik perkembangan
- Pelacakan air minum dan tidur harian
- Insight harian berbasis pola makan (ML)
- Goal forecast — estimasi tanggal target berat tercapai
- Streak logging harian

---

## Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Mobile | Flutter (Dart) |
| Backend | FastAPI (Python) |
| Database | PostgreSQL |
| ORM | SQLAlchemy |
| Auth | JWT (HTTPBearer) |
| External API | USDA FoodData Central, FatSecret OAuth2 |
| Config | pydantic-settings, .env |
| Password | bcrypt |

---

## Setup Backend

### 1. Clone repo

```bash
git clone https://github.com/toraaxlv/NutriShare.git
cd NutriShare
```

### 2. Virtual environment

```bash
python3 -m venv venv
source venv/bin/activate      # macOS/Linux
venv\Scripts\activate         # Windows
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Setup PostgreSQL

```bash
psql postgres
```

```sql
CREATE USER nutrishare_user WITH PASSWORD 'nutrishare123';
CREATE DATABASE nutrishare_db OWNER nutrishare_user;
GRANT ALL PRIVILEGES ON DATABASE nutrishare_db TO nutrishare_user;
\q
```

### 5. Environment variables

Buat file `.env` di root folder:

```env
DATABASE_URL=postgresql://nutrishare_user:nutrishare123@localhost:5432/nutrishare_db
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=43200
ML_SERVICE_URL=http://localhost:8001
USDA_API_KEY=your-usda-api-key
FATSECRET_CLIENT_ID=your-fatsecret-client-id
FATSECRET_CLIENT_SECRET=your-fatsecret-client-secret
```

> Jangan commit `.env` ke GitHub.

### 6. Seed data makanan Indonesia

```bash
python seed_foods.py
```

### 7. Jalankan server

```bash
uvicorn app.main:app --reload --port 8000
```

API docs tersedia di `http://localhost:8000/docs`

---

## Setup Flutter

### 1. Install dependencies

```bash
cd nutrishare_flutter
flutter pub get
```

### 2. Jalankan app (simulator/emulator)

```bash
flutter run
```

Untuk mengarahkan ke backend selain localhost (misal di HP fisik), set environment variable:

```bash
flutter run --dart-define=BASE_URL=http://192.168.x.x:8000/api/v1
```

---

## Struktur Project

```
NutriShare/
├── app/                         # Backend FastAPI
│   ├── models/                  # SQLAlchemy ORM models
│   │   ├── user.py
│   │   ├── food_item.py
│   │   ├── food_log.py
│   │   ├── weight_log.py
│   │   ├── water_log.py
│   │   ├── sleep_log.py
│   │   └── insight.py
│   ├── schemas/                 # Pydantic request/response schemas
│   ├── routers/                 # HTTP route handlers
│   │   ├── auth.py
│   │   ├── profile.py
│   │   ├── foods.py
│   │   ├── logs.py
│   │   ├── weight_logs.py
│   │   ├── water.py
│   │   ├── sleep.py
│   │   └── insights.py
│   ├── services/                # Business logic
│   ├── ml_client/               # USDA & FatSecret API clients
│   ├── main.py
│   ├── database.py
│   └── config.py
├── nutrishare_flutter/          # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   └── pubspec.yaml
├── seed_foods.py
├── requirements.txt
└── .env                         # tidak di-commit
```

---

## API Endpoints

### Auth
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/v1/auth/register` | Daftar akun baru |
| POST | `/api/v1/auth/login` | Login, dapat JWT token |

### Profile
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/profile/` | Lihat profil |
| PUT | `/api/v1/profile/` | Update profil & preferensi |
| GET | `/api/v1/profile/targets` | Target kalori & makro harian |
| GET | `/api/v1/profile/forecast` | Estimasi tanggal target berat tercapai |

### Foods
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/foods/search?q=` | Cari makanan (lokal + USDA + FatSecret) |
| GET | `/api/v1/foods/custom` | Daftar custom food milik user |
| POST | `/api/v1/foods/` | Buat custom food baru |

### Food Logs
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/v1/logs/` | Log makanan |
| GET | `/api/v1/logs/?log_date=` | Daftar log harian |
| PATCH | `/api/v1/logs/{id}` | Edit jumlah gram log |
| DELETE | `/api/v1/logs/{id}` | Hapus log |
| GET | `/api/v1/logs/summary?log_date=` | Ringkasan nutrisi harian vs target |
| GET | `/api/v1/logs/streak` | Streak hari logging berturut-turut |

### Weight
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/v1/weight-logs/` | Log berat badan (upsert per hari) |
| GET | `/api/v1/weight-logs/` | Riwayat berat badan |

### Water
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/water/?log_date=` | Data air minum hari itu |
| PUT | `/api/v1/water/` | Update jumlah air minum (upsert) |

### Sleep
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/sleep/?log_date=` | Data tidur hari itu |
| PUT | `/api/v1/sleep/` | Simpan/update data tidur (upsert) |

### Insights
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/insights/daily` | Insight harian berbasis pola makan (di-cache per hari) |

---

## External APIs

- **USDA FoodData Central** — API key gratis di https://fdc.nal.usda.gov/api-key-signup.html
- **FatSecret** — Developer account di https://platform.fatsecret.com

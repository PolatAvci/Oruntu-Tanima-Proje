from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.routes import router as api_router

# Uygulamayı Başlat
app = FastAPI(
    title="Signature Verification API",
    description="Signature Verification API",
    version="1.0.0"
)

# CORS Ayarları (Herkesin erişebilmesi için)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Rotaları (Controller) Uygulamaya Ekle
app.include_router(api_router)

# uvicorn main:app --host 0.0.0.0 --port 8000 komutu ile çalıştırılacak
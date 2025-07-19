# Classroom - Eğitim Platformu

Öğrenciler ve öğretmenlerin buluştuğu sınıf kültürünün olduğu eğitim platformu.

## Proje Yapısı

```
classroom/
├── backend/          # FastAPI backend
├── frontend/         # Flutter mobile app
└── docs/            # Dokümantasyon
```

## Özellikler

### Öğretmenler için:
- Sınıf oluşturma ve yönetimi
- Ödev verme ve takip
- Öğrenci performans takibi
- Sınıf içi etkileşim araçları

### Öğrenciler için:
- Sınıf katılımı
- Ödev takibi ve teslim
- Öğretmenlerle iletişim
- Sınıf arkadaşlarıyla etkileşim

## Teknolojiler

- **Backend**: FastAPI, PostgreSQL, SQLAlchemy
- **Frontend**: Flutter, Dart
- **Authentication**: JWT
- **Real-time**: WebSocket

## Kurulum

### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
``` 
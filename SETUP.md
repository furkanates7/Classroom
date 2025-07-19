# Classroom Projesi Kurulum Rehberi

Bu rehber, Classroom eğitim platformunu yerel ortamınızda çalıştırmanız için gerekli adımları içerir.

## Gereksinimler

### Backend için:
- Python 3.8+
- pip (Python paket yöneticisi)

### Frontend için:
- Flutter SDK 3.0+
- Android Studio / VS Code
- Android Emulator veya fiziksel cihaz

## Kurulum Adımları

### 1. Backend Kurulumu

```bash
# Backend klasörüne git
cd backend

# Sanal ortam oluştur (isteğe bağlı ama önerilen)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Gerekli paketleri yükle
pip install -r requirements.txt

# Veritabanını başlat
python main.py
```

Backend http://localhost:8000 adresinde çalışacak.

### 2. Frontend Kurulumu

```bash
# Frontend klasörüne git
cd frontend

# Flutter bağımlılıklarını yükle
flutter pub get

# Android emulator'ü başlat (veya fiziksel cihaz bağla)
flutter run
```

## API Dokümantasyonu

Backend çalıştıktan sonra http://localhost:8000/docs adresinden Swagger UI ile API dokümantasyonunu görüntüleyebilirsiniz.

## Özellikler

### Öğretmenler için:
- ✅ Kullanıcı kaydı ve girişi
- ✅ Sınıf oluşturma
- ✅ Sınıf listesi görüntüleme
- ✅ Ödev oluşturma (API hazır)
- 🔄 Ödev takibi (geliştirilecek)
- 🔄 Öğrenci performans takibi (geliştirilecek)

### Öğrenciler için:
- ✅ Kullanıcı kaydı ve girişi
- ✅ Sınıfa katılma (API hazır)
- ✅ Sınıf listesi görüntüleme
- 🔄 Ödev görüntüleme (geliştirilecek)
- 🔄 Ödev teslim etme (geliştirilecek)

## Test Kullanıcıları

### Öğretmen Hesabı:
- Email: teacher@example.com
- Şifre: password123
- Rol: teacher

### Öğrenci Hesabı:
- Email: student@example.com
- Şifre: password123
- Rol: student

## Geliştirme Notları

### Backend:
- FastAPI ile RESTful API
- SQLite veritabanı (production'da PostgreSQL önerilir)
- JWT authentication
- SQLAlchemy ORM

### Frontend:
- Flutter ile cross-platform mobil uygulama
- Provider state management
- HTTP client ile API entegrasyonu
- Material Design UI

## Sonraki Adımlar

1. **Real-time özellikler**: WebSocket ile anlık mesajlaşma
2. **Dosya yükleme**: Ödev dosyaları için
3. **Push notifications**: Ödev hatırlatmaları
4. **Offline desteği**: Çevrimdışı çalışma
5. **Gelişmiş UI**: Animasyonlar ve geçişler
6. **Test coverage**: Unit ve integration testleri

## Sorun Giderme

### Backend sorunları:
- Port 8000 kullanımdaysa: `uvicorn main:app --port 8001`
- Veritabanı hatası: `classroom.db` dosyasını silip yeniden başlatın

### Frontend sorunları:
- `flutter clean` ve `flutter pub get` çalıştırın
- Android emulator'ün çalıştığından emin olun
- API URL'ini kontrol edin (Android emulator için 10.0.2.2:8000)

## Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun 
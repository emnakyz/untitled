# IoT Sensör ve Kontrol Uygulaması
Bu Flutter projesi, MQTT protokolü üzerinden IoT cihazlarıyla (Arduino/ESP) iletişim kurmak için geliştirilmiştir. Uzaktan sensör verilerini izlemenizi ve bağlı cihazları kontrol etmenizi sağlar.
## Özellikler
- **Gerçek Zamanlı Veri İzleme:** MQTT üzerinden sensörlerden gelen anlık verileri görüntüler.
- **Uzaktan Kontrol:** Uygulama üzerinden cihazları açıp kapatabilirsiniz (Su ve Işık kontrolü).
- **Bağlantı Durumu:** MQTT sunucusuna olan bağlantı durumu anlık olarak gösterilir.
- **Otomatik Yeniden Bağlanma:** Bağlantı koptuğunda otomatik olarak tekrar bağlanmaya çalışır.
- **Güvenli Yapılandırma:** MQTT kimlik bilgileri `.env` dosyasında saklanır, repoya dahil edilmez.
## Proje Yapısı
```
lib/
├── main.dart                  # Ana uygulama ve UI
├── services/
│   └── mqtt_service.dart      # MQTT bağlantı ve iletişim mantığı
├── utils/
│   └── app_constants.dart     # Sabitler ve yapılandırma (.env okuma)
└── widgets/
    └── control_card.dart      # Tekrar kullanılabilir kontrol kartı bileşeni
arduino/
└── arduino_side.ino           # Arduino/ESP tarafı kaynak kodu
```
## Gereksinimler
- Flutter SDK >= 3.2.3
- Dart SDK >= 3.2.3
- Android SDK (Android build için)
- Çalışan bir MQTT broker (test için: `test.mosquitto.org`)
## Kurulum ve Çalıştırma
1. Bu repoyu klonlayın:
   ```bash
   git clone <repo-url>
   cd untitled
   ```
2. Proje kök dizininde `.env` dosyası oluşturun:
   ```env
   MQTT_SERVER=test.mosquitto.org
   MQTT_USERNAME=
   MQTT_PASSWORD=
   MQTT_CLIENT_ID=Flutter_Client
   MQTT_PORT=1883
   ```
3. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
4. Cihazınızı bağlayın veya emulatörü başlatın.
5. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```
## MQTT Konuları (Topics)
| Konu            | Yön              | Açıklama                        |
|-----------------|------------------|---------------------------------|
| `sensor_data`   | Arduino → Uygulama | Sensör verilerini taşır         |
| `control`       | Uygulama → Arduino | Kontrol komutlarını taşır       |
## Kontrol Komutları
| Komut      | Açıklama            |
|------------|----------------------|
| `suac`     | Su vanasını aç       |
| `sukapa`   | Su vanasını kapat    |
| `isikac`   | Işığı aç             |
| `isikkapat`| Işığı kapat          |
## Kullanılan Teknolojiler
- [Flutter](https://flutter.dev/) - UI framework
- [mqtt_client](https://pub.dev/packages/mqtt_client) - MQTT iletişim
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) - Ortam değişkenleri yönetimi
## Notlar
- Bu proje bir demo/prototip niteliğindedir.
- `.env` dosyası `.gitignore` içinde tanımlıdır ve repoya dahil edilmez.
- Canlı ortamda kullanmadan önce MQTT kimlik bilgilerinizi güvenli şekilde saklayın.
- Arduino tarafı kodu `arduino/arduino_side.ino` dosyasında bulunmaktadır.
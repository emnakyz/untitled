# IoT Sensor ve Kontrol Uygulamasi
MQTT protokolu uzerinden Arduino/ESP8266 ile iletisim kuran Flutter uygulamasi. Uzaktan sensor verilerini izlemenizi ve bagli cihazlari kontrol etmenizi saglar.
## Ozellikler
- **Gercek Zamanli Veri Izleme:** Sicaklik, nem, isik siddeti gibi sensor verileri Apple tarzi kartlarda goruntulenir
- **Uzaktan Kontrol:** iOS switch toggle ile cihazlari acip kapatabilirsiniz (Su ve Isik kontrolu)
- **Baglanti Durumu:** MQTT sunucusuna olan baglanti durumu anlik olarak gosterilir
- **Otomatik Yeniden Baglanma:** Baglanti koptugunda otomatik olarak tekrar baglanir
- **Guvenli Yapilandirma:** MQTT kimlik bilgileri `.env` dosyasinda saklanir, repoya dahil edilmez
- **Akilli Veri Parse:** Arduino CSV ve SEN5x key=value formatlarini otomatik tanir
- **TLS Destegi:** MQTT baglantisi sifreleme ile guvenli hale getirilebilir
## Proje Yapisi
```
lib/
+-- main.dart                  # Ana uygulama ve Apple tarzi UI
+-- models/
|   +-- sensor_data.dart       # Sensor verisi parse modeli
+-- services/
|   +-- mqtt_service.dart      # MQTT baglanti ve iletisim mantigi
+-- utils/
|   +-- app_constants.dart     # Sabitler ve yapilandirma (.env okuma)
+-- widgets/
    +-- control_card.dart      # iOS tarzi toggle kontrol karti
arduino/
+-- arduino_side.ino           # ESP8266 sensor okuma ve MQTT iletisim
```
## Gereksinimler
- Flutter SDK >= 3.2.3
- Dart SDK >= 3.2.3
- Android SDK (Android build icin)
- Calisan bir MQTT broker (test icin: `test.mosquitto.org`)
- ESP8266 + DHT11 + LDR (donanim tarafi icin)
## Kurulum
1. Repoyu klonlayin:
   ```bash
   git clone <repo-url>
   cd untitled
   ```
2. `.env` dosyasi olusturun:
   ```env
   MQTT_SERVER=test.mosquitto.org
   MQTT_USERNAME=
   MQTT_PASSWORD=
   MQTT_CLIENT_ID=Flutter_Client
   MQTT_PORT=1883
   MQTT_USE_TLS=false
   ```
3. Bagimliliklari yukleyin ve calistirin:
   ```bash
   flutter pub get
   flutter run
   ```
## MQTT Protokolu
| Konu          | Yon                | Aciklama                                |
|---------------|--------------------|-----------------------------------------|
| sensor_data   | Arduino -> Uygulama | `nem,sicaklik,isik` CSV formati        |
| control       | Uygulama -> Arduino | Kontrol komutlari                        |
### Kontrol Komutlari
| Komut      | Aciklama         |
|------------|------------------|
| suac       | Su vanasini ac   |
| sukapa     | Su vanasini kapat|
| isikac     | Isigi ac         |
| isikkapat  | Isigi kapat      |
## Guvenlik Notlari
- `.env` dosyasi `.gitignore` ile repoya dahil edilmez
- Arduino kodundaki WiFi/MQTT bilgilerini kendi ortaminiza gore degistirin
- Uretim ortaminda `MQTT_USE_TLS=true` ve port `8883` kullanin
- Arduino tarafinda EEPROM veya ayri config dosyasi onerilir
## Kullanilan Teknolojiler
- [Flutter](https://flutter.dev/) - Cross-platform UI
- [mqtt_client](https://pub.dev/packages/mqtt_client) - MQTT iletisim
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) - Ortam degiskenleri
- [ESP8266WiFi](https://github.com/esp8266/Arduino) - WiFi baglantisi
- [PubSubClient](https://pubsubclient.knolleary.net/) - Arduino MQTT
- [DHT](https://github.com/adafruit/DHT-sensor-library) - Sicaklik/nem sensoru
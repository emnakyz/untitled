# IoT Sensör ve Kontrol Uygulamasý
Bu Flutter projesi, MQTT protokolü üzerinden IoT cihazlarýyla iletiþim kurmak için geliþtirilmiþtir. Uzaktan sensör verilerini izlemenizi ve baðlý cihazlarý (örneðin su vanasý, ýþýklar) kontrol etmenizi saðlar.
## Özellikler
*   **Gerçek Zamanlý Veri Ýzleme:** MQTT üzerinden sensörlerden gelen anlýk verileri görüntüler.
*   **Uzaktan Kontrol:** Uygulama üzerinden cihazlarý açýp kapatabilirsiniz (Su ve Iþýk kontrolü).
*   **Baðlantý Durumu:** MQTT sunucusuna olan baðlantý durumu anlýk olarak gösterilir.
*   **Otomatik Yeniden Baðlanma:** Baðlantý koptuðunda otomatik olarak tekrar baðlanmaya çalýþýr.
## Proje Yapýsý
```
lib/
+¦¦ services/
-   L¦¦ mqtt_service.dart      # MQTT baðlantý ve iletiþim mantýðý
+¦¦ utils/
-   L¦¦ app_constants.dart     # Sabitler ve yapýlandýrma bilgileri
+¦¦ widgets/
-   L¦¦ control_card.dart      # Tekrar kullanýlabilir kontrol kartý bileþeni
L¦¦ main.dart                  # Ana uygulama ve UI
```
## Kurulum ve Çalýþtýrma
1.  Bu repoyu klonlayýn.
2.  `flutter pub get` komutu ile baðýmlýlýklarý yükleyin.
3.  `lib/utils/app_constants.dart` dosyasýndaki MQTT sunucu bilglerini kendi sunucunuza göre düzenleyin.
4.  Cihazýnýzý baðlayýn veya emülatörü baþlatýn.
5.  `flutter run` komutu ile uygulamayý çalýþtýrýn.
## Kullanýlan Teknolojiler
*   [Flutter](https://flutter.dev/)
*   [mqtt_client](https://pub.dev/packages/mqtt_client) paketi
## Notlar
*   Bu proje bir demo niteliðindedir. Canlý ortamda kullanmadan önce `app_constants.dart` içindeki kimlik bilgilerini güvenli bir þekilde sakladýðýnýzdan emin olun.

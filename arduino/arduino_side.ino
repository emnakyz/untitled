/*
 * IoT Sensör ve Kontrol - Arduino/ESP8266 Tarafı
 *
 * Bu kod ESP8266 üzerinde çalışır ve şu işleri yapar:
 * - DHT11 ile sıcaklık ve nem ölçümü
 * - LDR ile ışık şiddeti ölçümü
 * - MQTT üzerinden sensör verilerini yayınlama
 * - MQTT üzerinden kontrol komutlarını alma (su/ışık açma-kapama)
 *
 * MQTT Topics:
 *   sensor_data (publish) - "humidity,temperature,lightIntensity" formatında
 *   control     (subscribe) - "suac", "sukapa", "isikac", "isikkapat" komutları
 *
 * ÖNEMLİ: WiFi ve MQTT kimlik bilgilerini kendi ortamınıza göre düzenleyin.
 */

#include <ESP8266WiFi.h>
#include <DHT.h>
#include <PubSubClient.h>

// ─── Pin Tanımları ───────────────────────────────────────
#define DHTPIN      2       // DHT11 sensörünün bağlı olduğu pin (D4)
#define DHTTYPE     DHT11   // Kullanılan DHT sensör tipi
#define LDRPIN      A0      // LDR'nin bağlı olduğu analog pin
#define SUAC_PIN    5       // Su açma rölesinin bağlı olduğu pin (D1)
#define ISIKAC_PIN  14      // Işık açma rölesinin bağlı olduğu pin (D5)

// ─── Ağ Yapılandırması ───────────────────────────────────
// GÜVENLİK NOTU: Gerçek projede bu bilgileri EEPROM veya
// ayrı bir config dosyasında saklayın.
const char* ssid          = "WIFI_SSID";        // WiFi ağ adı
const char* password      = "WIFI_PASSWORD";    // WiFi şifresi

// ─── MQTT Yapılandırması ─────────────────────────────────
const char* mqtt_server   = "test.mosquitto.org"; // Flutter .env ile aynı olmalı
const int   mqtt_port     = 1883;
const char* mqtt_user     = "";                   // Boş ise anonim bağlantı
const char* mqtt_password = "";
const char* mqtt_client   = "ESP8266_IoT_Client";

// ─── MQTT Topic'leri ─────────────────────────────────────
const char* TOPIC_SENSOR  = "sensor_data";
const char* TOPIC_CONTROL = "control";

// ─── Zamanlama ───────────────────────────────────────────
const unsigned long SENSOR_INTERVAL = 2000;  // Sensör okuma aralığı (ms)
unsigned long lastSensorRead = 0;

// ─── Nesneler ────────────────────────────────────────────
DHT dht(DHTPIN, DHTTYPE);
WiFiClient espClient;
PubSubClient client(espClient);

// ═══════════════════════════════════════════════════════════
// WiFi Bağlantısı
// ═══════════════════════════════════════════════════════════
void setupWifi() {
  delay(10);
  Serial.println();
  Serial.print("WiFi bağlanıyor: ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 40) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi bağlandı!");
    Serial.print("IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nWiFi bağlantısı başarısız! Yeniden deneniyor...");
    ESP.restart();
  }
}

// ═══════════════════════════════════════════════════════════
// MQTT Yeniden Bağlanma
// ═══════════════════════════════════════════════════════════
void reconnect() {
  int retries = 0;
  while (!client.connected() && retries < 5) {
    Serial.print("MQTT bağlanıyor...");

    bool connected;
    if (strlen(mqtt_user) > 0) {
      connected = client.connect(mqtt_client, mqtt_user, mqtt_password);
    } else {
      connected = client.connect(mqtt_client);
    }

    if (connected) {
      Serial.println(" bağlandı!");
      client.subscribe(TOPIC_CONTROL);
      Serial.print("Abone olundu: ");
      Serial.println(TOPIC_CONTROL);
    } else {
      Serial.print(" başarısız, rc=");
      Serial.print(client.state());
      Serial.println(" - 5 saniye sonra tekrar deneniyor...");
      delay(5000);
    }
    retries++;
  }
}

// ═══════════════════════════════════════════════════════════
// MQTT Mesaj Callback
// ═══════════════════════════════════════════════════════════
void callback(char* topic, byte* payload, unsigned int length) {
  String message = "";
  for (unsigned int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  Serial.print("[");
  Serial.print(topic);
  Serial.print("] ");
  Serial.println(message);

  if (String(topic) == TOPIC_CONTROL) {
    if (message == "suac") {
      digitalWrite(SUAC_PIN, HIGH);
      Serial.println("-> Su AÇILDI");
    } else if (message == "sukapa") {
      digitalWrite(SUAC_PIN, LOW);
      Serial.println("-> Su KAPANDI");
    } else if (message == "isikac") {
      digitalWrite(ISIKAC_PIN, HIGH);
      Serial.println("-> Işık AÇILDI");
    } else if (message == "isikkapat") {
      digitalWrite(ISIKAC_PIN, LOW);
      Serial.println("-> Işık KAPANDI");
    } else {
      Serial.print("-> Bilinmeyen komut: ");
      Serial.println(message);
    }
  }
}

// ═══════════════════════════════════════════════════════════
// Setup
// ═══════════════════════════════════════════════════════════
void setup() {
  Serial.begin(115200);
  Serial.println("\n=== IoT Sensör ve Kontrol Başlatılıyor ===");

  // GPIO ayarları
  pinMode(SUAC_PIN, OUTPUT);
  pinMode(ISIKAC_PIN, OUTPUT);
  digitalWrite(SUAC_PIN, LOW);
  digitalWrite(ISIKAC_PIN, LOW);

  // DHT sensörü başlat
  dht.begin();

  // WiFi bağlantısı
  setupWifi();

  // MQTT bağlantısı
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
  reconnect();

  Serial.println("=== Sistem Hazır ===\n");
}

// ═══════════════════════════════════════════════════════════
// Ana Döngü
// ═══════════════════════════════════════════════════════════
void loop() {
  // MQTT bağlantı kontrolü
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  // Sensör okuma (belirli aralıklarla)
  unsigned long now = millis();
  if (now - lastSensorRead >= SENSOR_INTERVAL) {
    lastSensorRead = now;

    float humidity    = dht.readHumidity();
    float temperature = dht.readTemperature();
    int   lightValue  = analogRead(LDRPIN);

    // NaN kontrolü
    if (isnan(humidity) || isnan(temperature)) {
      Serial.println("DHT okuma hatası!");
      return;
    }

    // Veri formatı: Flutter SensorData.fromPayload() ile uyumlu
    // Format: "humidity,temperature,lightIntensity"
    String sensorPayload = String(humidity, 1) + ","
                         + String(temperature, 1) + ","
                         + String(lightValue);

    client.publish(TOPIC_SENSOR, sensorPayload.c_str());

    // Seri monitöre de yazdır
    Serial.print("Nem: ");
    Serial.print(humidity, 1);
    Serial.print("% | Sıcaklık: ");
    Serial.print(temperature, 1);
    Serial.print("°C | Işık: ");
    Serial.print(lightValue);
    Serial.print(" | MQTT: ");
    Serial.println(sensorPayload);
  }
}

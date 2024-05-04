#include <ESP8266WiFi.h>
#include <DHT.h>
#include <PubSubClient.h> //Messsage Broker için kütüphane eklendi.
 // Emin bu kodda sen float humidity, temperature ve lightIntensity degerleını mobıl app de sadece gostereceksın. ek olarak SUAC_PIN 5 ve ISIKAC_PIN 14 pınlerını acık kapalı konuma getormek ıcın serı ekrana yazmamız gereken metınlerı serı ekrana yazman gerekıyor. bu modul su an ınternete baglı kullanıcı adı ve sıfreyı degıstırererk ıstedıgın ınternet agına baglayabılırsın. 2 dıjıtal pının calısıp calısmamdıgını anlamak ıcın serı ekranı takıp edebılırsın, verdıgın komuta donus yapıyor. 
#define DHTPIN 2      // DHT11 sensörünün bağlı olduğu pin
#define DHTTYPE DHT11 // Kullanılan DHT sensör tipi
#define LDRPIN A0      // LDR'nin bağlı olduğu analog pin
#define SUAC_PIN 5    // Su açma kanalının bağlı olduğu pin (örnek olarak D1)
#define ISIKAC_PIN 14 // Işık açma kanalının bağlı olduğu pin (örnek olarak D5)


const char* ssid = "Tibax"; //Wifi ismi
const char* password = "20202020";//wifi şifre

const char* mqtt_server = "driver.cloudmqtt.com"; //mqtt server adı
const int mqtt_port = 18968; //mqttt port numarası
const char* mqtt_user = "xnfrrtci"; //mqtt kullanıcı adı 
const char* mqtt_password = "FjrZfpbzhWrj"; //mqtt şifre adı





DHT dht(DHTPIN, DHTTYPE);
WiFiClient espClient;
PubSubClient client(espClient);


// void setup_wifi() {
  
// }

// void reconnect() {
//   while (!client.connected()) {
//     Serial.print("Attempting MQTT connection...");
//     String clientId = "ESP8266Client - MyClient";
//     // if (client.connect(clientId.c_str(), mqtt_user, mqtt_password)) 
//     if (client.connect(clientId.c_str(), "yagiz34", "Birey1453"))
//     {
//       Serial.println("connected");
//       client.subscribe("sensor_data");
//       client.subscribe("control");
//     } 
//     else {
//       Serial.print("failed, rc=");
//       Serial.print(client.state());
//       Serial.println(" try again in 5 seconds");
//       delay(5000);
//     }
//   }
// }

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  Serial.println(message);

  if (String(topic) == "control") {
    if (message == "suac") {
      digitalWrite(SUAC_PIN, HIGH);
      Serial.println("Su açma kanalı açıldı.");
    } else if (message == "sukapa") {
      digitalWrite(SUAC_PIN, LOW);
      Serial.println("Su kapama kanalı açıldı.");
    } else if (message == "isikac") {
      digitalWrite(ISIKAC_PIN, HIGH);
      Serial.println("Işık açma kanalı açıldı.");
    } else if (message == "isikkapat") {
      digitalWrite(ISIKAC_PIN, LOW);
      Serial.println("Işık kapama kanalı açıldı.");
    } else {
      Serial.println("Invalid command!");
    }
  }
}

void setup() {
  Serial.begin(115200);
//Wifi Başlangıcı
 delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
//Wifi Sonu

  // MQTT bağlantısı başlangıcı
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);

   while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP8266Client - MyClient";

    if (client.connect(clientId.c_str(), mqtt_user, mqtt_password))
    {
      Serial.println("connected");
      client.subscribe("sensor_data");
      client.subscribe("control");
    } 
    else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
  // MQTT bağlantısı sonu

  pinMode(SUAC_PIN, OUTPUT);
  pinMode(ISIKAC_PIN, OUTPUT);

  // Başlangıçta tüm çıkışları kapalı konuma getirin
  digitalWrite(SUAC_PIN, LOW);
  digitalWrite(ISIKAC_PIN, LOW);

  dht.begin();

}

// void loop() {
//       // Sıcaklık ve nem ölçümü yap
//     float humidity = dht.readHumidity();
//     float temperature = dht.readTemperature();

//     // Işık şiddeti ölçümü yap
//     int lightIntensity = analogRead(LDRPIN);

//     // Sensör değerlerini seri monitöre yazdır
//     Serial.print("Nem: ");
//     Serial.print(humidity);
//     Serial.print(" %\t");
//     Serial.print("Sıcaklık: ");
//     Serial.print(temperature);
//     Serial.print(" °C\t");
//     Serial.print("Işık Şiddeti: ");
//     Serial.println(lightIntensity);
//     delay(5000);
  
  
//   if (Serial.available() > 0) {
//     String command = Serial.readStringUntil('\n');

//     if (command == "suac") {
//       digitalWrite(SUAC_PIN, HIGH);
//       Serial.println("Su açma kanalı açıldı.");
//     } else if (command == "sukapa") {
//       digitalWrite(SUAC_PIN, LOW);
//       Serial.println("Su kapama kanalı açıldı.");
//     } else if (command == "ısıkac") {
//       digitalWrite(    , HIGH);
//       Serial.println("Işık açma kanalı açıldı.");
//     } else if (command == "ısıkkapat") {
//       digitalWrite(ISIKAC_PIN, LOW);
//       Serial.println("Işık kapama kanalı açıldı.");
//     } else {
//       Serial.println("Geçersiz komut!");
//     }



//     // Bir süre sonra çıkışları kapat
//     delay(1000);
//     digitalWrite(SUAC_PIN, LOW);
//     digitalWrite(ISIKAC_PIN, LOW);
//   }
// }

void loop() {
  // if (!client.connected()) {
  //   // reconnect();
  // }
  client.loop();

  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();
  int lightIntensity = analogRead(LDRPIN);

    // Serial.print("Nem: ");
    // Serial.print(humidity);
    // Serial.print(" %\t");
    // Serial.print("Sıcaklık: ");
    // Serial.print(temperature);
    // Serial.print(" °C\t");
    // Serial.print("Işık Şiddeti: ");
    // Serial.println(lightIntensity);

  String sensor_data = String(humidity) + "," + String(temperature) + "," + String(lightIntensity);
  client.publish("sensor_data", sensor_data.c_str());



  delay(500);
}




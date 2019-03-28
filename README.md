# slutprojektvt19webbserver

# Projektplan - Forumsida

## 1. Projektbeskrivning
En forumsida där användare kan skapa diskussioner som användare kan lägga till inlägg i.
Den ska innehålla ett inloggningssystem så att man måste vara inloggad för att kunna lägga
upp inlägg på sidan. Många till många relation uppnås då en användare ska kunna följa
flera diskussioner så att den får en notis när ett nytt inlägg läggs upp.

## 2. Vyer (sidor)
* Det ska finnas en förstasida där man kan navigera till resten av forumet.
* Man ska kunna logga in på en inloggningssida och registrera nya konton på en registreringssida.
* Alla användare har en egen profil som de kan se på redigera på sin profilsida, det ska också gå att se andras profiler.
* Det ska finnas en sida som listar alla kategorier av diskussioner. Nya kategorier kan inte skapas av vanliga användare.
* I varje kategori ska alla diskussioner listas. Alla användare kan skapa nya diskussioner om de är inloggade.
* I varje diskussion kan inloggade användare lämna inlägg samt även välja att följa diskussionen för att få uppdateringar när nya inlägg görs.

## 3. Funktionalitet (med sekvensdiagram)


## 4. Arkitektur (Beskriv filer och mappar)
### Mappar:
* db: Mapp där databasen ligger.
* public: Mapp där all information som användare behöver (css, bilder etc.) för att ladda sidan befinner sig.
* views: Mapp där alla slim filer befinner sig för generering av html sidor.

### Filer:
* controller.rb: Den fil som behandlar all kommunikation mellan servern och användare, genom exempelvis routes etc.
* model.rb: Den fil som behandlar all kommunikation som servern behöver göra med databasen.

## 5. (Databas med ER-diagram)
* Ofärdigt ER diagram finns i misc.
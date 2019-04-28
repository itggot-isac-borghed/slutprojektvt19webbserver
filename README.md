# slutprojektvt19webbserver

# Projektplan - Forumsida

## 1. Projektbeskrivning
En forumsida där användare kan skapa diskussioner som användare kan lägga till inlägg i.
Den ska innehålla ett inloggningssystem så att man måste vara inloggad för att kunna lägga
upp inlägg på sidan. Många till många relation uppnås då en användare ska kunna följa
flera diskussioner så att den lätt kan hitta till dem utan att behöva navigera sig genom
hela sidan först

## 2. Vyer (sidor)
* Hem: Den första sidan som man möts av när man surfar in. Här kan man nå inloggningssidan om man ej är inloggad, sin profilsida om man har loggat in samt även en sida där man kan hitta alla kategorier av diskussioner. Misslyckas man med att logga in skickas man till en ny inloggninssida, där en text som beskriver att inloggningen misslyckades visas.
* Från inloggningssidan kan man dels logga in om man har ett konto eller ta sig till registreringssidan om man inte har ett konto.
* På registreringssidan skriver man in sitt önskade användarnamn, sin email och sitt lösenord för att skapa ett konto. När man gjort det skickas man tillbaka till hem vyn, om registreringen lyckas.
* På profilsidan kan man dels se alla sina kontouppgifter och även redigera dem om man är inloggad. Här kan man lägga in en liten beskrivning om sig själv så att andra användare vet vem man är. Alla användare kan kolla på varandras profilsidor, däremot kan man endast redigera sin egna. Lösenordet visas ej på denna sida.
* Från profilsidan kan man nå en sida som visar alla diskussioner som man följer. Dessa är också länkade, och här kan man också välja att sluta följa de diskussioner man vill.
* På kategorisidan visas alla typer av kategorier som diskussioner kan ordnas efter. Användare kan inte skapa nya kategorier.
* När man surfat in på en kategori visas alla diskussioner som finns i denna, med deras respektive ägares profilsidor länkade. Användare kan skapa nya diskussioner som har en titel, lite information om diskussionen och eventuellt en bild. 
* Väl inne på diskussionen syns dess titel, information och eventuella bild. Den som skapat diskussionen kan nå en sida för att redigera sin diskussion samt även radera den härifrån. När en diskussion raderas tas även alla tillhörande inlägg bort. Andra användare (samt diskussionens ägare) kan lägga till inlägg till varje diskussion, om de är inloggade. Dessa inkluderar lite text samt eventuella bilder. Varje inlägg på diskussionen listas sedan i ordningen som de har lagts upp i, med skaparnas profiler länkade. 
* För att redigera diskussionen skickas man till en ny sida där man fyller i ett formulär som liknar det som behövs för att skapa en ny diskussion. Om man inte ändrar på något så behålls det som det var.
* För att redigera inlägg skickas man också till en ny sida där man fyller i ett formulär. Likväl så ändras inte inlägget om ingen ny information skrivs.

## 3. Funktionalitet (med sekvensdiagram)

För att säkerställa att lösenord inte blir knäckta använder jag mig av ruby biblioteket bcrypt. Detta konverterar insatta 

## 4. Arkitektur (Beskriv filer och mappar)
### Mappar:
* db: Mapp där databasen ligger.
* public: Mapp där all statisk information som användare behöver (css, html, bilder etc.) för att ladda sidan där de befinner sig.
* views: Mapp där alla slim filer befinner sig för generering av html sidor.

### Filer:
* controller.rb: Den fil som behandlar all kommunikation mellan servern och användare, genom att behandla routes etc. 
* model.rb: Den fil som behandlar all kommunikation som servern behöver göra med databasen, som att hämta information, uppdatera etc. Allting denna fil utför görs på kommando av controller filen. I model utförs också alla beräkningar och majoriteten av all logik som behandlar data. 
* databas.db: Databasen där all information lagras. Struktur visas i ER diagrammet.
* categories.slim: Den fil som genererar html åt vyn där man kan välja vilken kategori man vill nå.
* category.slim: Filen som genererar html åt vyn där alla diskussioner inom en kategori visas.
* createdisc.slim: Genererar html åt vyn som man når när man vill skapa en ny diskussion.
* discussion.slim: Den fil som genererar html åt vyn där en diskussion och dess inlägg visas.
* editdisc.slim: Genererar html åt vyn där man kan redigera en diskussion.
* editpost.slim: Filen som genererar html åt vun där man kan redigera ett inlägg.
* home.slim: Genererar html åt hemvyn.
* layout.slim: Ett tillägg till alla andra slimfiler. Denna lägger till en html head till alla filer så att allt de har gemensamt endast behöver skrivas en gång.
* login.slim: Genererar html till loginvyn.
* loginfail.slim: Nästan indentisk till login.slim, däremot visar den också ett meddelande som beskriver att inloggning har misslyckats.
* profile.slim: Den fil som generar html till profilvyn.
* saved.slim: Filen som genererar html till vyn där man kan se alla diskussioner som man följer.
* signup.slim: Genererar html till registreringsvyn.

## 5. (Databas med ER-diagram)
* Ofärdigt ER diagram finns i misc.
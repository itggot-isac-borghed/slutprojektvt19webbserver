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
* På profilsidan kan man dels se alla sina kontouppgifter och även redigera dem om man är inloggad. Här kan man lägga in en liten beskrivning om sig själv så att andra användare vet vem man är. Alla användare kan kolla på varandras profilsidor, däremot kan man endast redigera sin egna. Lösenordet visas ej på denna sida. Profilen redigerar man från en separat sida.
* Från profilsidan kan man nå en sida som visar alla diskussioner som man följer. Dessa är också länkade, och här kan man också välja att sluta följa de diskussioner man vill.
* På kategorisidan visas alla typer av kategorier som diskussioner kan ordnas efter. Användare kan inte skapa nya kategorier.
* När man surfat in på en kategori visas alla diskussioner som finns i denna, med deras respektive ägares profilsidor länkade. Användare kan skapa nya diskussioner som har en titel, lite information om diskussionen och eventuellt en bild. 
* Väl inne på diskussionen syns dess titel, information och eventuella bild. Den som skapat diskussionen kan nå en sida för att redigera sin diskussion samt även radera den härifrån. När en diskussion raderas tas även alla tillhörande inlägg bort. Andra användare (samt diskussionens ägare) kan lägga till inlägg till varje diskussion, om de är inloggade. Dessa inkluderar lite text samt eventuella bilder. Varje inlägg på diskussionen listas sedan i ordningen som de har lagts upp i, med skaparnas profiler länkade. 
* För att redigera diskussionen skickas man till en ny sida där man fyller i ett formulär som liknar det som behövs för att skapa en ny diskussion. Om man inte ändrar på något så behålls det som det var.
* För att redigera inlägg skickas man också till en ny sida där man fyller i ett formulär. Likväl så ändras inte inlägget om ingen ny information skrivs.

## 3. Funktionalitet (med sekvensdiagram i misc för registrering och inlägg)
* Inloggningssystem: Vid inloggning så skickar man sitt användarnamn och lösenord till servern. Servern jämför användarnamnet och det hashade lösenordet (görs med bcrypt biblioteket i ruby) med det som är sparat i databasen. Om det matchar skickas man till hemvyn och användarnamnet samt användarens id sparas i sessioner. Misslyckas det så får man försöka igen på en sida där det står att inloggning misslyckades.
* Registrering: När man registrerar så skickar man sitt önskade användarnamn, lösenord (repeterat två gånger i separata fält) samt sin mailaddress. Om alla fält inte är ifyllda så registreras man inte. Sedan kollar servern om kontot redan är registrerat genom att försöka hämta ett användarid som är kopplat till det inskickade användarnamnet och mailaddressen. Om det ger ett resultat reistreras inte kontot. Om det inte ger ett resultat registreras användaren och skickas till inloggningssidan.
* Utloggning: Från hemvyn så kan man klicka på en knapp som loggar ut en ifall man är inloggad. När detta sker så sätts användarnamnet och användarid i sessionen till nil.
* Uppdatering av profil: Direkt från sin egna profilsida så kan man skicka in lite information om sig själv ifall man vill ge en beskrivning (denna kan vara tom). Är man inte inloggad, eller inte inne på sin egen profil, så visas formuläret ej. Stämmer det användarid som är sparat i sessionen överrens med profilen som man uppdaterars användarid så uppdateras databasen. Annars ges felkoden 403 (forbidden action). Från profilsidan kan man även ta sig till en sida där man kan uppdatera sitt lösenord, mailaddress eller användarnamn. Man behöver inte skicka in alla samtidigt, uppdaterar man exempelvis endast lösenordet så uppdateras bara detta i databasen. För att göra en uppdatering behöver man skriva in sitt nuvarande lösenord längst ned i formuläret. Är man inte inloggad eller försöker ändra en annan användares inloggninsuppgifter så ges felkod 403.
* Följ diskussion: När man är inne på en diskussion så kan man klicka i en knapp för att följa den. Då skickas ens användarid och diskussionens id (där man befinner sig) in i databasen, vilket kopplar diskussionens id till ens användarid. Är man inte inloggad går detta ej att genomföra. Från ens profilsida kan man nå alla diskussioner som man följer. Härifrån kan man även sluta följa diskussioner, vilket då tar bort kopplingen mellan den aktuella diskussionens id och användarid i databasen.
* Diskussioner: När man skapar en diskussion behöver man ge den en titel och lite information om den. Eventuellt kan man även lägga till en bild till diskussionen. Är man inloggad så skapas då diskussionen. Om man är inne på en diskussion som man själv lagt upp så kan man ta bort den därifrån. Är man inte inloggad på rätt konto när man försöker ta bort en diskussion ges felkod 403. Från en diskussion så kan man även nå profilen till ägaren av diskussionen. Om en diskussion raderas så raderas även alla inlägg till denna diskussion från databasen. Man kan också redigera en diskussion om man är ägaren till den. Man kan redigera diskussionens titel, information samt dess eventuella bild.
* Inlägg: För att skapa ett inlägg behöver man vara inloggad. Ett inlägg behöver endast ha lite information för att läggas upp, det kan också innehålla en bild. När inlägget väl är upplagt så kan man ta bort det från diskussionssidan. Endast den användare som lagt upp inlägget kan ta bort det, om inte den aktuella diskussionen tas bort för då raderas också alla tillhörande inlägg. Inlägg kan liksom diskussioner också redigeras om man är inloggad på rätt användare.

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
* editpost.slim: Filen som genererar html åt vyn där man kan redigera ett inlägg.
* editprofile.slim: Den fil som genererar html åt vyn där man kan redigera sin användares namn, lösenord och mailaddress.
* home.slim: Genererar html åt hemvyn.
* layout.slim: Ett tillägg till alla andra slimfiler. Denna lägger till en html head till alla filer så att allt de har gemensamt endast behöver skrivas en gång.
* login.slim: Genererar html till loginvyn.
* loginfail.slim: Nästan indentisk till login.slim, däremot visar den också ett meddelande som beskriver att inloggning har misslyckats.
* profile.slim: Den fil som generar html till profilvyn.
* saved.slim: Filen som genererar html till vyn där man kan se alla diskussioner som man följer.
* signup.slim: Genererar html till registreringsvyn.

## 5. (Databas med ER-diagram)
* ER diagram finns i misc.
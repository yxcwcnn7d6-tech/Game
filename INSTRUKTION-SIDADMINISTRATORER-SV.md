# Instruktion: Lägg till Process Owner på din sida

## För dig som administrerar en process-sida

Du behöver lägga till information om Process Owner och Process Manager på din sida så att vi kan samla in en översikt automatiskt.

**Det tar 2 minuter och ändrar INGENTING på hur din sida ser ut.**

---

## Metod 1: Via information-panelen (ENKLAST)

### Steg 1: Öppna din sida
Gå till din process-sida (t.ex. SITS-sidan)
**Klicka INTE på Edit än**

### Steg 2: Öppna information
Längst upp till höger, klicka på **"i"** (information-ikonen)

Det ser ut ungefär så här: **🛈** eller **ⓘ**

### Steg 3: Öppna alla egenskaper
I panelen som öppnas till höger:
- Klicka på **"View all properties"** eller **"Visa alla egenskaper"** längst ner

### Steg 4: Redigera
- Klicka på **"Edit all"** eller **"Redigera alla"** längst upp i panelen

### Steg 5: Fyll i fälten
Du ser nu flera fält. Hitta dessa:

**ProcessOwner** (eller "Process Owner")
- Klicka i fältet
- Skriv namnet på process-ägaren
- Välj personen från dropdown

**ProcessManager** (eller "Process Manager")
- Klicka i fältet
- Skriv namnet på process manager(s)
- Välj person(er) från dropdown
- Du kan välja flera personer om det finns flera managers

**ProcessName** (eller "Process Name") - om fältet finns
- Skriv processens namn (t.ex. "SITS", "Problem", etc.)

### Steg 6: Spara
- Klicka **Save** eller **Spara** längst upp
- Stäng panelen

**Klart!** ✅

Din sida ser exakt likadan ut, men informationen finns nu i bakgrunden.

---

## Metod 2: Via detaljer-menyn (ALTERNATIV)

### Steg 1: Öppna menyn
På din sida, klicka på **"..."** (tre prickar) längst upp till höger

### Steg 2: Välj Details
Välj **"Details"** eller **"Detaljer"** från menyn

### Steg 3: Gå till Properties
I panelen som öppnas:
- Klicka på **"Properties"** eller **"Egenskaper"**

### Steg 4-6: Samma som ovan
Följ steg 4-6 från Metod 1

---

## Metod 3: Direkt i URL (för avancerade användare)

Om metoderna ovan inte fungerar:

### Steg 1: Kopiera din sidas URL
T.ex: `https://company.sharepoint.com/sites/IT/SitePages/SITS.aspx`

### Steg 2: Lägg till parameter
Lägg till `?Mode=Edit&DisplayMode=Design` i slutet:
`https://company.sharepoint.com/sites/IT/SitePages/SITS.aspx?Mode=Edit&DisplayMode=Design`

### Steg 3: Öppna URL:en
Klistra in den nya URL:en i din webbläsare

### Steg 4: Fyll i fält
Du kommer till en sida där du kan fylla i metadata-fält direkt

---

## Vanliga frågor

### F: Jag ser inte fälten ProcessOwner eller ProcessManager
**S:** Kontakta IT/SharePoint-administratören - de behöver lägga till fälten först i Site Pages-biblioteket. Visa dem filen: `SHAREPOINT-PAGE-PROPERTIES-GUIDE-SV.md`

### F: Vad händer med innehållet på min sida?
**S:** Ingenting! Page properties är separata från sidinnehållet. Allt du har skrivit och alla web parts förblir exakt som de är.

### F: Måste jag ta bort den gamla informationen från sidan?
**S:** Nej, du kan ha kvar den om du vill. Men om du vill kan du ta bort den eftersom informationen nu finns i metadata istället.

### F: Kan jag ändra ProcessOwner senare?
**S:** Ja, absolut! Följ samma steg och uppdatera fältet. Power Automate-flödet kommer att plocka upp ändringen nästa natt.

### F: Vad är skillnaden på ProcessOwner och ProcessManager?
**S:**
- **ProcessOwner**: En person som äger processen
- **ProcessManager**: En eller flera personer som hanterar processen dagligen

Om du bara har en, fyll i den som finns. Om du har båda, fyll i båda.

### F: Jag kan välja flera personer i ProcessManager men bara en i ProcessOwner
**S:** Det är korrekt! ProcessOwner ska vara EN person, ProcessManager kan vara flera.

### F: Vad ska jag skriva i ProcessName?
**S:** Namnet på din process, t.ex:
- "SITS" (för SITS-sidan)
- "Problem Management" (för Problem-sidan)
- "Incident Management" (för Incident-sidan)

### F: Vad händer om jag inte fyller i detta?
**S:** Din sida kommer inte att inkluderas i den automatiska översikten. Om vi behöver din information får vi kontakta dig manuellt istället.

---

## Tidsåtgång
⏱️ **2 minuter per sida**

---

## Hjälp behövs?

Om du kör fast:
1. Ta en skärmbild på vad du ser
2. Kontakta: [din kontaktperson/email]
3. Vi hjälper dig!

---

## Visuell guide (vad du ska leta efter)

När du klickar på **ⓘ** ser du något liknande detta:

```
┌────────────────────────────┐
│  Information              │
│  ─────────────────────    │
│  Name: SITS.aspx          │
│  Modified: 2025-01-15     │
│  Modified by: Dig         │
│                           │
│  View all properties ↓    │  ← KLICKA HÄR
└────────────────────────────┘
```

Sedan ser du:

```
┌────────────────────────────┐
│  Properties        Edit ✏️  │  ← KLICKA HÄR
│  ─────────────────────────│
│  Name: SITS.aspx          │
│  Created: 2024-12-18      │
│  ProcessOwner: [____]     │  ← FYLL I HÄR
│  ProcessManager: [____]   │  ← FYLL I HÄR
│  ProcessName: [____]      │  ← FYLL I HÄR
│                           │
│  [Cancel]  [Save]         │
└────────────────────────────┘
```

---

## Tack för din hjälp! 🙏

Genom att fylla i denna information hjälper du oss att:
- Ha en aktuell översikt över alla processer
- Snabbt hitta rätt personer vid frågor
- Förbättra samarbetet mellan teamen

**Det tar 2 minuter men sparar många timmar för oss alla!**

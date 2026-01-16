# Guide: Lägga till Page Properties (Sidegenskaper) på SharePoint-sidor

## Översikt

Page properties är **metadata-fält** som lagras på varje SharePoint-sida. De syns inte direkt på sidan, men finns i bakgrunden och kan läsas av Power Automate.

**Fördelen:**
- Power Automate kan läsa dessa fält automatiskt
- Sidadministratörerna kan fortsätta visa informationen som de vill på sidan
- Men datan finns också strukturerad i bakgrunden

---

## Del 1: Förberedelser (För IT-administratör eller Site Owner)

### Vad du behöver:
- **Site Owner** eller **Site Collection Administrator** behörighet
- Access till SharePoint-siten
- 10-15 minuter

---

## Del 2: Lägg till kolumner i Site Pages-biblioteket

### Steg 1: Öppna Site Pages-biblioteket

1. Gå till din SharePoint-site (t.ex. IT-siten)
2. Klicka på **kugghjulet** (Settings) längst upp till höger
3. Välj **Site contents** / **Webbplatsinnehåll**
4. Klicka på **Site Pages** (där alla sidor lagras)

**Alternativ väg:**
- Gå till: `https://[din-site]/SitePages/Forms/AllPages.aspx`

---

### Steg 2: Öppna biblioteksinställningar

1. Du ser nu alla dina sidor i en lista
2. Klicka på **kugghjulet** igen (eller välj fliken **Library** i menyn)
3. Välj **Library settings** / **Biblioteksinställningar**

**Alternativ:**
- Klicka på **Settings** > **Library settings** i menyfliksområdet

---

### Steg 3: Skapa kolumn för Process Owner

1. Scrolla ner till sektionen **Columns** / **Kolumner**
2. Klicka på **Create column** / **Skapa kolumn**

**Fyll i följande:**

| Fält | Värde |
|------|-------|
| **Column name** | `ProcessOwner` (inget mellanslag!) |
| **Type** | **Person or Group** / **Person eller grupp** |
| **Description** | "Process Owner för denna process" |
| **Require that this column contains information** | ☐ Nej (inte obligatoriskt) |
| **Allow multiple selections** | ☐ Nej (en person) |
| **Allow selection of** | **People Only** / **Endast personer** |
| **Choose from** | **All Users** / **Alla användare** |
| **Show field** | **Name with picture** / **Namn med bild** |

3. Klicka **OK**

---

### Steg 4: Skapa kolumn för Process Manager

Upprepa Steg 3 med dessa värden:

| Fält | Värde |
|------|-------|
| **Column name** | `ProcessManager` |
| **Type** | **Person or Group** |
| **Description** | "Process Manager för denna process" |
| **Allow multiple selections** | ☑ **Ja** (flera personer) |
| *(resten samma som ovan)* | |

---

### Steg 5: (Valfritt) Skapa kolumn för Process Name

Om du vill lägga till processnamnet som ett fält också:

| Fält | Värde |
|------|-------|
| **Column name** | `ProcessName` |
| **Type** | **Single line of text** / **Textrad** |
| **Description** | "Namn på processen (t.ex. SITS, Problem, etc.)" |
| **Require** | ☐ Nej |
| **Maximum characters** | 100 |

---

### Steg 6: Verifiera att kolumnerna finns

1. Gå tillbaka till **Site Pages**-biblioteket
2. Klicka på **All Pages** / **Alla sidor** (dropdown)
3. Välj **Edit current view** / **Redigera aktuell vy**
4. Scrolla ner till listan över kolumner
5. Leta efter:
   - ☑ **ProcessOwner**
   - ☑ **ProcessManager**
   - ☑ **ProcessName** (om du skapade den)
6. Bocka i dem så de visas i vyn
7. Klicka **OK**

**Nu ska du se kolumnerna i listan!** 🎉

---

## Del 3: Fylla i fälten på befintliga sidor

Nu måste varje sidadministratör fylla i dessa fält på sina sidor.

### Metod 1: Direkt i biblioteket (snabbast för många sidor)

1. Gå till **Site Pages**-biblioteket
2. Du ser nu dina nya kolumner
3. Klicka direkt i cellen för varje sida
4. Skriv namnet på Process Owner/Manager
5. Välj person från dropdown

**Fördel:** Snabbt om du ska fylla i många sidor
**Nackdel:** Måste ha tillgång till Site Pages-biblioteket

---

### Metod 2: Via sidans egenskaper (för sidadministratörer)

#### Steg 2.1: Öppna sidan

1. Gå till din process-sida (t.ex. SITS-sidan)
2. **Klicka INTE på Edit**

#### Steg 2.2: Öppna sidegenskaper

**Alternativ A:**
1. Längst upp till höger, klicka på **"i"** (information-ikonen)
2. Ett panel öppnas till höger
3. Klicka på **View all properties** / **Visa alla egenskaper**

**Alternativ B:**
1. Klicka på **"..."** (tre prickar) längst upp
2. Välj **Details** / **Detaljer**
3. Klicka på **Properties** / **Egenskaper**

**Alternativ C:**
1. Gå till sidans URL och lägg till `?Mode=Edit` i slutet
2. Exempel: `https://site.sharepoint.com/SitePages/SITS.aspx?Mode=Edit`

#### Steg 2.3: Redigera egenskaper

1. I properties-panelen klickar du på **Edit all** / **Redigera alla**
2. Du ser nu alla fält, inklusive:
   - **ProcessOwner**
   - **ProcessManager**
   - **ProcessName**
3. Klicka i fältet och välj person(er)
4. Klicka **Save** / **Spara**

**Klart!** Fälten är nu ifyllda och Power Automate kan läsa dem.

---

### Metod 3: Via Edit-mode på sidan (enklast för sidadministratörer)

#### Steg 3.1: Editera sidan

1. Öppna din process-sida
2. Klicka **Edit** / **Redigera** längst upp

#### Steg 3.2: Lägg till Property pane web part (om du vill visa fälten)

Detta är **valfritt** - bara om du vill att fälten också ska synas på sidan:

1. I edit-mode, klicka **+** för att lägga till en web part
2. Sök efter **"Properties"** eller **"Page properties"**
3. Lägg till web parten
4. Konfigurera den att visa ProcessOwner och ProcessManager

**OBS:** Detta visar bara fälten - du måste fortfarande fylla i dem via sidegenskaperna!

#### Steg 3.3: Fyll i metadata

1. Medan du är i edit-mode, titta längst upp
2. Under sidtiteln finns det ibland fält som du kan fylla i direkt
3. **ELLER** använd Metod 2 (properties-panelen) för att fylla i

---

## Del 4: Skapa en sidmall (för framtida sidor)

Om du vill att alla nya sidor automatiskt ska ha dessa fält:

### Steg 1: Skapa en template-sida

1. Gå till **Site Pages**
2. Klicka **New** > **Site Page** / **Ny** > **Webbplatssida**
3. Välj en layout
4. Namnge sidan: "Process Template" eller liknande
5. Lägg till text/web parts som är gemensamma för alla processer
6. Lägg till en "Page properties" web part som visar ProcessOwner och ProcessManager
7. **Publish** / **Publicera** sidan

### Steg 2: Spara som template (Page Template)

**OBS:** Detta kräver moderna SharePoint-templates

1. Öppna din template-sida
2. Klicka **"..."** längst upp
3. Välj **Save as template** / **Spara som mall**
4. Ge den ett namn: "Process Page Template"
5. Klicka **Save**

### Steg 3: Använd template för nya sidor

När någon skapar en ny sida:
1. **New** > **Site Page**
2. Välj din template från listan
3. Sidan skapas med alla fält redan klara

---

## Del 5: Instruktioner för sidadministratörerna

### Kort instruktion du kan skicka till de som äger sidorna:

```
Hej!

För att vi ska kunna samla process-information automatiskt, behöver du
lägga till följande information på din sida:

1. Öppna din process-sida (t.ex. SITS)
2. Klicka på "i"-ikonen längst upp till höger
3. Klicka "View all properties"
4. Klicka "Edit all"
5. Fyll i:
   - ProcessOwner: [välj person]
   - ProcessManager: [välj person(er)]
   - ProcessName: [t.ex. "SITS"]
6. Klicka Save

Detta ändrar inte hur din sida ser ut - det lägger bara till
metadata som gör det möjligt för oss att samla informationen
automatiskt.

Tack!
```

---

## Del 6: Verifiera att det fungerar

### Test med en sida:

1. Gå till **Site Pages**-biblioteket
2. Hitta en sida där du fyllt i fälten
3. Se att ProcessOwner och ProcessManager visas i kolumnerna
4. Klicka på sidan för att öppna properties
5. Verifiera att data är korrekt

### Test med Power Automate (snabbtest):

1. Skapa ett enkelt test-flöde:
   ```
   Trigger: Manually
   Action: Get items
     - Site: [Din site]
     - List: Site Pages
     - Filter Query: FileLeafRef eq 'SITS.aspx'
   Action: Compose
     - Input: @{items('Apply_to_each')?['ProcessOwner']?['DisplayName']}
   ```
2. Kör flödet
3. Du ska se namnet på Process Owner i output

**Om du ser namnet = det fungerar!** ✅

---

## Del 7: Vanliga problem och lösningar

### Problem 1: Jag ser inte kolumnerna i Site Pages
**Lösning:**
- Kontrollera att du är i Site Pages-biblioteket (inte bara på en sida)
- Gå via Site contents > Site Pages
- Redigera vyn för att visa kolumnerna

### Problem 2: Fälten visas inte när jag editerar sidan
**Lösning:**
- Page properties visas inte alltid i edit-mode
- Använd i-ikonen eller "Details" istället
- Eller fyll i direkt i Site Pages-biblioteket

### Problem 3: Jag kan inte skapa kolumner
**Lösning:**
- Du behöver Site Owner-behörighet
- Kontakta din SharePoint-administratör
- De kan skapa kolumnerna åt dig

### Problem 4: "ProcessOwner" vs "Process Owner" (med mellanslag)
**Rekommendation:**
- Använd UTAN mellanslag: `ProcessOwner` (internal name)
- Display name kan ha mellanslag: "Process Owner"
- Men internal name är viktigare för Power Automate

### Problem 5: Kan jag namnge fälten olika för varje site?
**Svar:**
- Tekniskt ja, men GÖR INTE DET
- Power Automate blir mycket svårare
- Använd samma fältnamn på alla sites för enkelhetens skull
- `ProcessOwner` och `ProcessManager` överallt

### Problem 6: Vad händer med gamla web parts på sidan?
**Svar:**
- Ingenting! De kan vara kvar
- Page properties är separata från sidinnehållet
- Sidadministratörer kan behålla sin nuvarande layout
- De lägger bara till metadata i bakgrunden

---

## Del 8: Efter att fälten är tillagda - Power Automate

När fälten är ifyllda på alla (eller de flesta) sidor:

### Power Automate kan nu:

```
1. Get files (properties only)
   - Site: https://yoursite.sharepoint.com/sites/IT
   - Library: Site Pages

2. Filter Array
   - Where: ProcessOwner is not empty

3. Apply to each (filtered pages)

4. Compose
   {
     "SiteName": "IT Site",
     "PageName": @{item()?['FileLeafRef']},
     "ProcessOwner": @{item()?['ProcessOwner']?['DisplayName']},
     "ProcessOwnerEmail": @{item()?['ProcessOwner']?['Email']},
     "ProcessManagers": @{item()?['ProcessManager']} (array)
   }

5. Add to Excel
```

**Detta fungerar perfekt!** ✅

---

## Del 9: Rollout-plan för 100 sidor

### Fas 1: Pilot (Vecka 1)
- Välj 5-10 sidor
- Lägg till kolumner på EN site
- Fyll i fälten
- Testa Power Automate-flödet
- Verifiera att allt fungerar

### Fas 2: Dokumentation (Vecka 1-2)
- Skapa enkel instruktion för sidadministratörer
- Skapa video/screenshots om möjligt
- Förbered support för frågor

### Fas 3: Kommunikation (Vecka 2)
- Maila alla sidadministratörer
- Förklara VARFÖR (för att samla översikt)
- Ge deadline (t.ex. 2 veckor)
- Erbjud hjälp

### Fas 4: Implementering (Vecka 3-4)
- Sidadministratörer fyller i sina sidor
- Du följer upp vilka som är klara
- Påminnelser till de som inte gjort det

### Fas 5: Automation (Vecka 5)
- När 80%+ är klara: starta Power Automate-flödet
- De sista 20% kan du fylla i manuellt om nödvändigt
- Eller vänta tills de är klara

### Fas 6: Underhåll (Löpande)
- Power Automate kör varje natt
- Excel uppdateras automatiskt
- När nya sidor skapas: påminn om att fylla i fälten

---

## Del 10: Alternativ approach - Content Type

Om du vill göra det mer strukturerat kan du skapa en **Content Type**:

### Fördelar med Content Type:
- Fälten följer automatiskt med när sidor skapas
- Mer professionellt
- Lättare att rulla ut till flera sites

### Hur man skapar:

1. **Site Settings** > **Site content types**
2. **Create** ny content type
3. Basera på "Site Page"
4. Lägg till dina kolumner (ProcessOwner, ProcessManager)
5. Gå till Site Pages-biblioteket settings
6. **Advanced settings** > Allow management of content types: Yes
7. **Add from existing** > Välj din content type
8. Sätt som default för nya sidor

**Detta är mer avancerat** men ger bättre struktur långsiktigt.

---

## Sammanfattning - Checklista

För IT-admin/Site Owner:
- [ ] Skapa kolumner i Site Pages: ProcessOwner, ProcessManager, ProcessName
- [ ] Verifiera att kolumnerna syns i biblioteket
- [ ] Testa fylla i en sida
- [ ] Skapa instruktioner för sidadministratörer
- [ ] (Valfritt) Skapa sidmall

För sidadministratörer (x100):
- [ ] Öppna sidan
- [ ] Klicka i-ikonen > View all properties > Edit all
- [ ] Fyll i ProcessOwner, ProcessManager, ProcessName
- [ ] Spara

För dig (automation):
- [ ] Bygg Power Automate-flöde när >80% är klart
- [ ] Testa flödet
- [ ] Schemalägg för nattlig körning
- [ ] Njut av automatisk Excel-rapport! 🎉

---

**Lycka till! Om något är oklart, fråga gärna.** 👍

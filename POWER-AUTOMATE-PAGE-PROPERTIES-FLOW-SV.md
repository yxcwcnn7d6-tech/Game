# Power Automate Flöde: Läs Process Owners från SharePoint-sidor

## Översikt

Detta flöde läser **page properties** (sidegenskaper) från SharePoint Site Pages-biblioteket och samlar Process Owner/Manager-information i en Excel-fil.

**Förutsättningar:**
- Page properties är tillagda enligt guiden: `SHAREPOINT-PAGE-PROPERTIES-GUIDE-SV.md`
- Sidadministratörer har fyllt i fälten
- Du har skapat Excel-filen (se Del 1 nedan)

---

## Del 1: Skapa Excel-filen

### Steg 1: Skapa Excel-fil i OneDrive eller SharePoint

1. Gå till OneDrive eller en SharePoint-site där du vill lagra rapporten
2. Skapa ny Excel-fil: `Process_Owners_Report.xlsx`

### Steg 2: Skapa tabell

1. Lägg in dessa kolumnrubriker i rad 1:

| A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|
| SiteName | SiteURL | PageName | PageURL | ProcessName | ProcessOwner | ProcessOwnerEmail | ProcessManagers | LastUpdated |

2. Markera hela raden (A1:I1)
3. **Insert** > **Table** (bocka "My table has headers")
4. Klicka på tabellen, gå till **Table Design**
5. Namnge tabellen: `ProcessOwnersTable`
6. **Spara filen**

---

## Del 2: Bygg Power Automate-flödet

### Steg 1: Skapa nytt flöde

1. Gå till https://make.powerautomate.com
2. **Create** > **Scheduled cloud flow**
3. Namn: `SharePoint Process Owners - Page Properties Extractor`
4. **Repeats**: Every **1 Day** at **02:00**
5. **Create**

---

### Steg 2: Initiera variabler

#### Variabel 1: SharePoint Sites
```
Action: Initialize variable
Name: SharePointSites
Type: Array
Value:
[
  "https://company.sharepoint.com/sites/IT",
  "https://company.sharepoint.com/sites/Finance",
  "https://company.sharepoint.com/sites/HR"
]
```
*(Ersätt med dina faktiska site-URLs)*

#### Variabel 2: Excel-detaljer
```
Action: Initialize variable
Name: ExcelSiteAddress
Type: String
Value: https://company.sharepoint.com/sites/YourSite
(eller OneDrive-sökväg)

Action: Initialize variable
Name: ExcelFilePath
Type: String
Value: /Shared Documents/Process_Owners_Report.xlsx

Action: Initialize variable
Name: ExcelTableName
Type: String
Value: ProcessOwnersTable
```

#### Variabel 3: Array för data
```
Action: Initialize variable
Name: CollectedData
Type: Array
Value: []
```

---

### Steg 3: Loopa genom alla sites

```
Action: Apply to each
Select: SharePointSites
```

Inside this loop:

#### 3.1: Sätt current site
```
Action: Compose
Name: CurrentSiteName
Inputs:
  @{split(item(), '/')[last()]}
(Extraherar site-namnet från URL)
```

#### 3.2: Hämta alla sidor från Site Pages
```
Action: Get files (properties only)
Site Address: @{item()}
Library Name: Site Pages
Limit: 5000
```

**VIKTIGT:** Välj "Get files (properties only)" - inte "Get items"!

#### 3.3: Loopa genom sidorna (nested loop)
```
Action: Apply to each
Select: value (från Get files)
```

Inside nested loop:

##### 3.3.1: Kontrollera om ProcessOwner finns
```
Action: Condition
Left: @{item()?['ProcessOwner']}
Operator: is not equal to
Right: null
```

##### 3.3.2: Om ProcessOwner finns - extrahera data

**I "If yes"-grenen:**

```
Action: Compose
Name: ProcessManagersNames
Inputs:
  @{join(item()?['ProcessManager'], '; ')}
(Kombinerar flera managers till en sträng)

Action: Compose
Name: ExtractedRecord
Inputs:
{
  "SiteName": "@{outputs('CurrentSiteName')}",
  "SiteURL": "@{item()}",
  "PageName": "@{item()?['FileLeafRef']}",
  "PageURL": "@{item()?['FileRef']}",
  "ProcessName": "@{item()?['ProcessName']}",
  "ProcessOwner": "@{item()?['ProcessOwner']?['DisplayName']}",
  "ProcessOwnerEmail": "@{item()?['ProcessOwner']?['Email']}",
  "ProcessManagers": "@{outputs('ProcessManagersNames')}",
  "LastUpdated": "@{utcNow()}"
}

Action: Append to array variable
Name: CollectedData
Value: @{outputs('ExtractedRecord')}
```

---

### Steg 4: Rensa Excel-tabellen

Efter alla loopar är klara:

```
Action: List rows present in a table
Location: (OneDrive eller SharePoint)
Document Library: Documents
File: Process_Owners_Report.xlsx
Table: ProcessOwnersTable

Action: Apply to each
Select: value (från List rows)

  Action: Delete a row
  Location: (samma som ovan)
  File: Process_Owners_Report.xlsx
  Table: ProcessOwnersTable
  Row id: @{item()?['id']}
```

**Varför?** Vi raderar alla gamla rader och lägger till fresh data varje gång.

---

### Steg 5: Skriv till Excel

```
Action: Apply to each
Select: CollectedData

  Action: Add a row into a table
  Location: (OneDrive eller SharePoint)
  Document Library: Documents
  File: Process_Owners_Report.xlsx
  Table: ProcessOwnersTable

  Column mapping:
  - SiteName: @{item()?['SiteName']}
  - SiteURL: @{item()?['SiteURL']}
  - PageName: @{item()?['PageName']}
  - PageURL: @{item()?['PageURL']}
  - ProcessName: @{item()?['ProcessName']}
  - ProcessOwner: @{item()?['ProcessOwner']}
  - ProcessOwnerEmail: @{item()?['ProcessOwnerEmail']}
  - ProcessManagers: @{item()?['ProcessManagers']}
  - LastUpdated: @{item()?['LastUpdated']}
```

---

### Steg 6: Skicka notifiering (valfritt)

```
Action: Send an email (V2)
To: din.email@company.com
Subject: Process Owners Report Updated - @{formatDateTime(utcNow(), 'yyyy-MM-dd')}
Body:
Rapporten har uppdaterats!

- Sites processade: @{length(variables('SharePointSites'))}
- Sidor hittade: @{length(variables('CollectedData'))}
- Uppdaterad: @{formatDateTime(utcNow(), 'yyyy-MM-dd HH:mm')}

Öppna Excel-filen för att se resultat.
```

---

## Del 3: Förbättringar och optimeringar

### Optimering 1: Filtrera direkt i Get files

Istället för att hämta ALLA sidor och sedan filtrera:

```
Action: Get files (properties only)
Site Address: @{item()}
Library Name: Site Pages
Filter Query: ProcessOwner ne null
Limit: 5000
```

**Fördel:** Snabbare, färre API-anrop

---

### Optimering 2: Hantera flera Process Managers

Om ProcessManager är ett multi-person-fält:

```
Action: Apply to each
Select: @{item()?['ProcessManager']}

  Action: Append to string variable
  Name: ManagersList
  Value: @{items('Apply_to_each_managers')?['DisplayName']},
```

Sedan använd `ManagersList` i Excel-raden.

---

### Optimering 3: Inkrementell uppdatering (istället för full clear)

Istället för att radera alla rader varje gång:

**Strategi:**
1. Hämta befintliga rader från Excel
2. För varje ny sida: kolla om den redan finns (baserat på PageURL)
3. Om finns OCH data är samma: skippa
4. Om finns OCH data har ändrats: uppdatera raden
5. Om inte finns: lägg till ny rad

**Implementation:**
```
Action: List rows present in a table
(hämta befintliga)

Action: Apply to each (CollectedData)

  Action: Filter array
  From: body('List_rows_present_in_a_table')?['value']
  Where: item()?['PageURL'] is equal to @{items('Apply_to_each')?['PageURL']}

  Action: Condition
  If length(body('Filter_array')) is greater than 0
    → Update row (om data ändrats)
  Else
    → Add row (ny sida)
```

**Fördel:** Snabbare, mer effektivt

---

## Del 4: Felsökning

### Problem 1: "Column 'ProcessOwner' does not exist"

**Orsak:** Kolumnen finns inte i Site Pages-biblioteket

**Lösning:**
1. Gå till Site Pages > Library Settings
2. Kontrollera att kolumnen finns under "Columns"
3. Om inte: skapa den enligt guiden

---

### Problem 2: Får "null" för ProcessOwner

**Orsak:** Fältet är inte ifyllt på sidan

**Lösning:**
- Fyll i fältet enligt Del 3 i guiden
- Eller lägg till filter i Get files för att skippa sidor utan ProcessOwner

---

### Problem 3: ProcessManager är tomt array

**Orsak:** Ingen manager är ifylld

**Lösning:**
- Lägg till null-check:
```
@{if(empty(item()?['ProcessManager']), 'N/A', join(item()?['ProcessManager'], '; '))}
```

---

### Problem 4: Flödet timeout:ar

**Orsak:** För många sidor att processa

**Lösning:**
1. Öka timeout på actions
2. Processera en site i taget istället för alla
3. Eller skapa separata flöden per site

---

### Problem 5: "The file is locked for editing"

**Orsak:** Någon har Excel-filen öppen

**Lösning:**
1. Stäng filen
2. Lägg till retry-logik i flödet:
   - Settings på Excel-action > Configure run after
   - Add retry policy: 3 retries, 5 min interval

---

## Del 5: Testplan

### Test 1: En site, en sida
1. Skapa flödet för EN site
2. Fyll i ProcessOwner på EN sida
3. Kör flödet manuellt
4. Kontrollera att rad skapas i Excel ✅

### Test 2: En site, flera sidor
1. Fyll i ProcessOwner på 5 sidor
2. Kör flödet
3. Kontrollera att 5 rader skapas ✅

### Test 3: Flera sites
1. Lägg till 2-3 sites i array
2. Kör flödet
3. Kontrollera att alla sites processas ✅

### Test 4: Uppdatering
1. Ändra ProcessOwner på en sida
2. Kör flödet igen
3. Kontrollera att Excel uppdateras ✅

### Test 5: Tom data
1. Ta bort ProcessOwner från en sida
2. Kör flödet
3. Kontrollera att sidan inte längre finns i Excel ✅

---

## Del 6: Komplett flöde - översikt

```
┌─────────────────────────────────────────┐
│ Trigger: Recurrence (Daily 2 AM)       │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│ Initialize variables                    │
│ - SharePointSites (array)              │
│ - ExcelSiteAddress, FilePath, Table    │
│ - CollectedData (array)                │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│ Apply to each: SharePointSites         │
│  │                                      │
│  ├─ Get files from Site Pages          │
│  │                                      │
│  └─ Apply to each: Pages               │
│     │                                   │
│     ├─ Condition: ProcessOwner exists? │
│     │                                   │
│     └─ If yes:                          │
│        ├─ Compose extracted data       │
│        └─ Append to CollectedData      │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│ List rows from Excel                    │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│ Apply to each: Excel rows              │
│  └─ Delete row                          │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│ Apply to each: CollectedData           │
│  └─ Add row to Excel                    │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│ Send email notification (optional)      │
└─────────────────────────────────────────┘
```

---

## Del 7: Exempel på uttryck (expressions)

### Extrahera site-namn från URL
```
@{last(split(variables('CurrentSiteURL'), '/'))}
```

### Formatera datum
```
@{formatDateTime(utcNow(), 'yyyy-MM-dd HH:mm:ss')}
```

### Kombinera flera managers
```
@{join(item()?['ProcessManager'], '; ')}
```

### Kolla om fält är tomt
```
@{if(empty(item()?['ProcessName']), 'Unknown', item()?['ProcessName'])}
```

### Extrahera processnamn från sidnamn
Om sidan heter "SITS.aspx":
```
@{first(split(item()?['FileLeafRef'], '.'))}
```
Resultat: "SITS"

---

## Del 8: Behörigheter

### Vad flödet behöver:

**SharePoint:**
- Read access till Site Pages-biblioteket på alla sites
- Om flödet körs med ditt konto: du behöver read access
- Om flödet körs med service account: det kontot behöver access

**Excel-fil:**
- Edit access till OneDrive/SharePoint där Excel-filen ligger

**Email:**
- Om du skickar notifieringar: Office 365 Outlook-connector

### Ge flödet behörighet:

1. När du skapar connections första gången:
   - Logga in med ditt konto
   - Eller använd ett service account

2. Om du får "Unauthorized":
   - Re-authenticate connections
   - Gå till Connections i Power Automate
   - Edit > Sign in again

---

## Del 9: Schemaläggning och underhåll

### Rekommenderad schemaläggning:
- **Daglig körning**: 02:00 (när minst aktivitet på SharePoint)
- **Alternativ**: Varje måndag morgon kl 06:00

### Underhåll:

**Veckovis:**
- Kolla run history i Power Automate
- Verifiera att inga fel har uppstått

**Månadsvis:**
- Granska Excel-filen
- Kontrollera att alla sites är med
- Ta bort eventuella gamla/borttagna sidor

**Vid behov:**
- Lägg till nya sites i SharePointSites-array
- Uppdatera email-notifieringar

---

## Del 10: Nästa steg - avancerade funktioner

### Funktion 1: Change tracking
Spara historik när Process Owners ändras:

```
- Skapa en andra tabell: ProcessOwnersHistory
- Innan du uppdaterar en rad: kopiera gamla värdet till history
- Inkludera timestamp och vem som ändrade
```

### Funktion 2: Notifiering vid ändring
Skicka email när specifika processer byter ägare:

```
- Jämför nya data med gamla Excel-rader
- Om ProcessOwner har ändrats:
  → Send email to stakeholders
```

### Funktion 3: Power BI Dashboard
Skapa dashboard baserat på Excel:

```
- Importera Excel till Power BI
- Visualisera: Antal processer per site, per owner, etc.
- Auto-refresh varje morgon
```

### Funktion 4: Teams-integration
Posta uppdateringar i Teams:

```
Action: Post message in a chat or channel
Team: Your team
Channel: General
Message: Process Owners rapport uppdaterad - @{length(variables('CollectedData'))} processer
```

---

## Sammanfattning

### Du har nu:
✅ Guide för att lägga till page properties
✅ Komplett Power Automate-flöde
✅ Excel-rapport som uppdateras automatiskt varje natt
✅ Strukturerad data från alla SharePoint-sites

### Tidsåtgång:
- Setup (en gång): 2-3 timmar
- Rollout till 100 sidor: 2-4 veckor (beroende på sidadministratörernas tempo)
- Underhåll: 5-10 minuter/månad

### ROI:
- **Innan:** 2-3 timmar manuellt arbete varje gång du behöver en översikt
- **Efter:** 0 minuter - Excel uppdateras automatiskt
- **Plus:** Data alltid aktuell, inga mänskliga fel

---

**Lycka till med implementeringen!** 🎉

Om du kör fast någonstans, kolla först:
1. Flödets run history för felmeddelanden
2. Verifiera att page properties finns och är ifyllda
3. Testa med EN site först innan du lägger till alla

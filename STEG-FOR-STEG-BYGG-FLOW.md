# Steg-för-steg: Bygg AI-driven SharePoint Process Owners Flow

## Översikt

Denna guide visar **exakt** hur du bygger flödet i Power Automate - klick för klick.

**Vad du behöver innan du börjar:**
- [ ] Power Automate-access (Office 365)
- [ ] OpenAI API-nyckel (från https://platform.openai.com/api-keys)
- [ ] Excel-fil skapad (se Del 0 nedan)
- [ ] Lista på SharePoint-sites (URLs)
- [ ] 30-60 minuter ostörd tid

---

## Del 0: Förberedelser (10 minuter)

### Steg 0.1: Skapa Excel-filen

1. **Öppna OneDrive eller SharePoint** där du vill lagra rapporten
2. **Klicka "New"** > **Excel workbook**
3. **Namnge filen:** `Process_Owners_Report.xlsx`

4. **Lägg till kolumnrubriker** i rad 1:
   ```
   A1: SiteName
   B1: SiteURL
   C1: PageName
   D1: PageURL
   E1: ProcessName
   F1: ProcessOwner
   G1: ProcessManagers
   H1: Confidence
   I1: LastUpdated
   ```

5. **Markera hela raden** (A1:I1)
6. **Klicka fliken "Insert"** (Infoga) > **Table** (Tabell)
7. **Bocka "My table has headers"** > **OK**
8. **Klicka på tabellen** > **Flik "Table Design"** (Tabelldesign)
9. **Table Name:** Ändra till `ProcessOwnersTable`
10. **Spara filen** (Ctrl+S)

**Anteckna:**
- Excel-filens plats: `___________________________`
- Library name: `___________________________` (vanligtvis "Documents")

### Steg 0.2: Skaffa OpenAI API-nyckel

1. **Gå till:** https://platform.openai.com/api-keys
2. **Logga in** (eller skapa konto om du inte har)
3. **Klicka "Create new secret key"**
4. **Namnge nyckeln:** "SharePoint Process Owners Flow"
5. **Kopiera nyckeln** - VIKTIG: Den visas bara EN gång!
6. **Spara nyckeln** i en säker plats (t.ex. notepad tillfälligt)

**API-nyckel:** `sk-proj-...` (börjar alltid med "sk-")

### Steg 0.3: Lista dina SharePoint-sites

Skriv ner alla sites du vill processa:

```
1. https://company.sharepoint.com/sites/IT
2. https://company.sharepoint.com/sites/Finance
3. https://company.sharepoint.com/sites/HR
4. (etc.)
```

**Tips:** Börja med 1-2 sites för testning!

---

## Del 1: Skapa flödet (40 minuter)

### Steg 1.1: Öppna Power Automate

1. **Gå till:** https://make.powerautomate.com
2. **Logga in** med ditt Office 365-konto
3. **Vänta** tills startsidan laddas

### Steg 1.2: Skapa nytt flöde

1. **Klicka** på **"Create"** (Skapa) i vänstermenyn
2. **Välj** **"Scheduled cloud flow"** (Schemalagt molnflöde)

3. **Fyll i popup:**
   - **Flow name:** `SharePoint Process Owners - AI Extractor`
   - **Starting:** Välj datum (t.ex. imorgon)
   - **Repeat every:** `1 Day`
   - **At these times:** `02:00:00` (kl 02 på natten)

4. **Klicka "Create"**

**✅ Du bör nu se en canvas med "Recurrence" längst upp.**

---

## Del 2: Lägg till variabler (5 minuter)

### Steg 2.1: Lägg till första variabeln (SharePoint Sites)

1. **Klicka "+ New step"** under Recurrence
2. **Sök:** `initialize variable`
3. **Välj** **"Initialize variable"** (Variable-ikonen)

4. **Fyll i:**
   - **Name:** `SharePointSites`
   - **Type:** Välj **Array** från dropdown
   - **Value:** Klicka i fältet och klistra in:
     ```json
     [
       "https://company.sharepoint.com/sites/IT",
       "https://company.sharepoint.com/sites/Finance"
     ]
     ```
     *(Ersätt med DINA site-URLs!)*

5. **Klicka var som helst utanför** för att bekräfta

**✅ Du bör se variabeln "SharePointSites" skapad**

### Steg 2.2: Lägg till andra variabeln (Excel Site)

1. **Klicka "+ New step"**
2. **Sök:** `initialize variable`
3. **Välj** **"Initialize variable"**

4. **Fyll i:**
   - **Name:** `ExcelSiteAddress`
   - **Type:** **String**
   - **Value:** Din Excel-fils SharePoint-site URL
     - Exempel: `https://company.sharepoint.com/sites/YourSite`
     - ELLER tom om filen ligger i OneDrive

### Steg 2.3: Lägg till tredje variabeln (Excel File Path)

1. **Klicka "+ New step"**
2. **Sök:** `initialize variable`
3. **Välj** **"Initialize variable"**

4. **Fyll i:**
   - **Name:** `ExcelFilePath`
   - **Type:** **String**
   - **Value:** Sökväg till filen
     - Exempel: `/Shared Documents/Process_Owners_Report.xlsx`
     - ELLER `/Process_Owners_Report.xlsx` om OneDrive

### Steg 2.4: Lägg till fjärde variabeln (Collected Data)

1. **Klicka "+ New step"**
2. **Sök:** `initialize variable`
3. **Välj** **"Initialize variable"**

4. **Fyll i:**
   - **Name:** `CollectedData`
   - **Type:** **Array**
   - **Value:** Lämna TOM

**✅ Du bör nu ha 4 variabler initierade**

---

## Del 3: Loop genom sites (10 minuter)

### Steg 3.1: Lägg till Apply to each (Loop sites)

1. **Klicka "+ New step"**
2. **Sök:** `apply to each`
3. **Välj** **"Apply to each"** (Control-ikonen)

4. **Klicka i "Select an output"**
5. **I popup som öppnas:** Leta i "Dynamic content"-tabben
6. **Välj** **"SharePointSites"** (från dina variabler)

**✅ Du bör se en loop med text "Apply to each"**

### Steg 3.2: Lägg till action inuti loopen (Get Pages)

Nu arbetar vi **INUTI** "Apply to each"-boxen:

1. **Klicka "+ Add an action"** (inuti Apply to each)
2. **Sök:** `http sharepoint`
3. **Välj** **"Send an HTTP request to SharePoint"**

4. **Fyll i:**
   - **Site Address:** Klicka i fältet
     - I Dynamic content-popup: Välj **"Current item"** (från Apply to each-loopen)
   - **Method:** Välj **GET** från dropdown
   - **Uri:** Klistra in exakt detta:
     ```
     _api/web/lists/getbytitle('Site Pages')/items?$select=Title,FileRef,FileLeafRef,Id
     ```
   - **Headers:** Klicka "Show advanced options"
     - Key: `Accept`
     - Value: `application/json;odata=nometadata`

**✅ Du bör se "Send an HTTP request to SharePoint" inuti loopen**

### Steg 3.3: Parse JSON-svaret

1. **Klicka "+ Add an action"** (under HTTP request, fortfarande inuti stora loopen)
2. **Sök:** `parse json`
3. **Välj** **"Parse JSON"** (Data Operation)

4. **Fyll i:**
   - **Content:** Klicka i fältet
     - Dynamic content: Välj **"Body"** (från Send an HTTP request)

   - **Schema:** Klicka i fältet och klistra in:
     ```json
     {
       "type": "object",
       "properties": {
         "value": {
           "type": "array",
           "items": {
             "type": "object",
             "properties": {
               "Title": {"type": "string"},
               "FileRef": {"type": "string"},
               "FileLeafRef": {"type": "string"},
               "Id": {"type": "integer"}
             }
           }
         }
       }
     }
     ```

**✅ Parse JSON är nu konfigurerad**

---

## Del 4: Loop genom varje sida (15 minuter)

### Steg 4.1: Lägg till nested loop (Loop pages)

1. **Klicka "+ Add an action"** (under Parse JSON, inuti första loopen)
2. **Sök:** `apply to each`
3. **Välj** **"Apply to each"**

4. **Select an output:** Klicka i fältet
   - Dynamic content: Välj **"value"** (från Parse JSON)

**✅ Du har nu en loop INUTI en annan loop**

### Steg 4.2: Hämta sidans innehåll

Nu arbetar vi **INUTI** den INRE loopen (Apply to each 2):

1. **Klicka "+ Add an action"**
2. **Sök:** `get file content sharepoint`
3. **Välj** **"Get file content"** (SharePoint)

4. **Fyll i:**
   - **Site Address:** Klicka och välj **"Current item"** från YTTRE loopen
     - OBS: Det finns NU två "Current item" - välj den som är från **Apply to each** (inte Apply to each 2)
   - **File Identifier:** Klicka i fältet
     - Dynamic content: Välj **"FileRef"** (från Apply to each 2)

**✅ "Get file content" är konfigurerad**

### Steg 4.3: Konvertera innehåll till text

1. **Klicka "+ Add an action"**
2. **Sök:** `compose`
3. **Välj** **"Compose"** (Data Operation)

4. **Inputs:** Klicka i fältet
   - Dynamic content: Välj **"File content"** (från Get file content)

**✅ Compose är konfigurerad**

**Byt namn på denna action:**
- Klicka på **"..."** (tre prickar) längst upp på Compose-boxen
- Välj **"Rename"**
- Skriv: `PageContent`

---

## Del 5: Skicka till AI (20 minuter) - VIKTIGASTE DELEN!

### Steg 5.1: Bygg AI-prompten

1. **Klicka "+ Add an action"**
2. **Sök:** `compose`
3. **Välj** **"Compose"**

4. **Inputs:** Klicka i fältet och klistra in hela denna prompt:

```
You are a SharePoint content analyzer specializing in process ownership extraction.

YOUR TASK:
Extract process ownership information from the provided SharePoint page content.

WHAT TO EXTRACT:
1. Process Name - the name of the business process
2. Process Owner - ONE person who owns the process
3. Process Managers - ONE OR MORE people who manage the process

WHERE TO LOOK:
- Section headings containing "Process Owner" or "Processägare"
- Section headings containing "Process Manager" or "Processledare"
- Variations like "[ProcessName] Process Owner" (e.g., "SITS Process Owner")
- People cards/web parts showing names and roles
- Plain text stating "Owner: [Name]" or "Manager: [Name]"

EXTRACTION RULES:
✓ Extract person names only (First Name + Last Name)
✓ Remove job titles in parentheses: "John Doe (YISP)" → "John Doe"
✓ Remove titles: "Dr. John Doe" → "John Doe"
✓ Be case-insensitive when matching patterns
✓ Accept both Swedish and English terms
✗ Do NOT extract job titles alone (e.g., "Operation Process Improv.")
✗ Do NOT guess or invent names
✗ Do NOT extract department names

IF INFORMATION IS MISSING:
Return "Not found" for that field

CONFIDENCE LEVELS:
- "high": Clear labels with names directly stated
- "medium": Names found near ownership keywords
- "low": Ambiguous or weak signals

REQUIRED OUTPUT FORMAT (JSON ONLY):
{
  "processName": "extracted name or page title",
  "processOwner": "Full Name or Not found",
  "processManagers": ["Full Name 1", "Full Name 2"] or ["Not found"],
  "confidence": "high" or "medium" or "low"
}

EXAMPLES:

Example 1:
Input: "SITS Process Owner: Thiel Michael (YISP). SITS Process Managers: John Doe, Jane Smith."
Output:
{
  "processName": "SITS",
  "processOwner": "Thiel Michael",
  "processManagers": ["John Doe", "Jane Smith"],
  "confidence": "high"
}

Example 2:
Input: "Finance process. Responsible: Anna Svensson. Team leads: Per Olsson and Maria Berg."
Output:
{
  "processName": "Finance",
  "processOwner": "Anna Svensson",
  "processManagers": ["Per Olsson", "Maria Berg"],
  "confidence": "medium"
}

NOW ANALYZE THIS CONTENT:
---
```

5. **Efter "---", klicka i fältet igen**
   - Dynamic content: Välj **"Outputs"** (från PageContent/Compose)

6. **Efter det, skriv:**
```
---

CRITICAL: Return ONLY the JSON object above. No explanations, no markdown, no code blocks.
```

**✅ Prompten är nu klar**

**Byt namn:**
- Klicka "..." > Rename
- Skriv: `AIPrompt`

### Steg 5.2: Anropa OpenAI API

1. **Klicka "+ Add an action"**
2. **Sök:** `http`
3. **Välj** **"HTTP"** (utan ikoner, bara "HTTP")

4. **Fyll i:**
   - **Method:** Välj **POST**
   - **URI:** Klistra in:
     ```
     https://api.openai.com/v1/chat/completions
     ```

   - **Headers:** Klicka "Show advanced options"
     - Klicka **"+ Add new item"** två gånger för att få två rader

     **Rad 1:**
     - Key: `Authorization`
     - Value: `Bearer sk-proj-DINNYCKELHÄR`
       *(Ersätt "sk-proj-DINNYCKELHÄR" med din RIKTIGA OpenAI API-nyckel!)*

     **Rad 2:**
     - Key: `Content-Type`
     - Value: `application/json`

   - **Body:** Klicka i fältet och klistra in:
     ```json
     {
       "model": "gpt-4o-mini",
       "messages": [
         {
           "role": "system",
           "content": "You are a data extraction assistant. Return only valid JSON."
         },
         {
           "role": "user",
           "content": "
     ```

   - **Efter "content": ", klicka i fältet**
     - Dynamic content: Välj **"Outputs"** (från AIPrompt/Compose)

   - **Efter det, skriv:**
     ```json
     "
         }
       ],
       "temperature": 0.3,
       "max_tokens": 500
     }
     ```

**VIKTIGT: Body-fältet ska se ut så här:**
```json
{
  "model": "gpt-4o-mini",
  "messages": [
    {
      "role": "system",
      "content": "You are a data extraction assistant. Return only valid JSON."
    },
    {
      "role": "user",
      "content": "[OUTPUTS FRÅN AIPROMPT HÄR]"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 500
}
```

**✅ HTTP-anropet är konfigurerat**

**Byt namn:**
- Klicka "..." > Rename
- Skriv: `CallOpenAI`

---

## Del 6: Parse AI-svaret (10 minuter)

### Steg 6.1: Extrahera JSON från AI-svar

1. **Klicka "+ Add an action"**
2. **Sök:** `compose`
3. **Välj** **"Compose"**

4. **Inputs:** Skriv följande expression (klicka på fx-ikonen om du inte ser expression-fält):
   ```
   body('CallOpenAI')?['choices']?[0]?['message']?['content']
   ```

**Alternativ enklare metod:**
- Klicka i Inputs-fältet
- Dynamic content: Leta efter **"Body"** (från CallOpenAI)
- Men du måste fortfarande lägga till `?['choices'][0]['message']['content']` efter

**✅ Compose extraherar AI-svaret**

**Byt namn:**
- "..." > Rename > `AIResponse`

### Steg 6.2: Parse JSON-svaret från AI

1. **Klicka "+ Add an action"**
2. **Sök:** `parse json`
3. **Välj** **"Parse JSON"**

4. **Fyll i:**
   - **Content:** Klicka i fältet
     - Dynamic content: Välj **"Outputs"** (från AIResponse)

   - **Schema:** Klistra in:
     ```json
     {
       "type": "object",
       "properties": {
         "processName": {"type": "string"},
         "processOwner": {"type": "string"},
         "processManagers": {
           "type": "array",
           "items": {"type": "string"}
         },
         "confidence": {"type": "string"}
       }
     }
     ```

**✅ Parse JSON är konfigurerad**

**Byt namn:**
- "..." > Rename > `ParseAIResponse`

---

## Del 7: Samla data (5 minuter)

### Steg 7.1: Skapa dataobjekt

1. **Klicka "+ Add an action"**
2. **Sök:** `compose`
3. **Välj** **"Compose"**

4. **Inputs:** Klicka i fältet och bygg JSON-objektet:

Skriv:
```json
{
  "SiteName": "
```

Klicka i fältet efter `"SiteName": "` och välj Dynamic content:
- Välj **"Current item"** från första Apply to each (site-loopen)

Fortsätt skriva (se till att du har citattecken rätt):
```json
",
  "SiteURL": "
```

Välj Dynamic content igen: **"Current item"**

Fortsätt:
```json
",
  "PageName": "
```

Dynamic content: **"Title"** (från Apply to each 2)

Fortsätt bygga hela objektet:
```json
",
  "PageURL": "
```
Dynamic: **"FileRef"**

```json
",
  "ProcessName": "
```
Dynamic: **"processName"** (från ParseAIResponse)

```json
",
  "ProcessOwner": "
```
Dynamic: **"processOwner"**

```json
",
  "ProcessManagers": "
```

**För detta fält, använd expression:**
- Klicka fx-ikonen
- Skriv: `join(body('ParseAIResponse')?['processManagers'], '; ')`

```json
",
  "Confidence": "
```
Dynamic: **"confidence"**

```json
",
  "LastUpdated": "
```
Expression: `utcNow()`

```json
"
}
```

**FÄRDIGT JSON-objekt ska se ut ungefär så här:**
```json
{
  "SiteName": "[Current item]",
  "SiteURL": "[Current item]",
  "PageName": "[Title]",
  "PageURL": "[FileRef]",
  "ProcessName": "[processName]",
  "ProcessOwner": "[processOwner]",
  "ProcessManagers": "[join expression]",
  "Confidence": "[confidence]",
  "LastUpdated": "[utcNow()]"
}
```

**✅ Dataobjektet är skapat**

**Byt namn:**
- "..." > Rename > `RecordToSave`

### Steg 7.2: Lägg till i array

1. **Klicka "+ Add an action"**
2. **Sök:** `append to array`
3. **Välj** **"Append to array variable"**

4. **Fyll i:**
   - **Name:** Välj **CollectedData** från dropdown
   - **Value:** Klicka i fältet
     - Dynamic content: **"Outputs"** (från RecordToSave)

**✅ Data läggs nu till i arrayen**

**DU ÄR NU KLAR MED LOOPARNA! 🎉**

---

## Del 8: Skriv till Excel (10 minuter)

Nu arbetar vi **UTANFÖR** alla loopar (längst ner i flödet):

### Steg 8.1: Rensa Excel-tabellen (valfritt)

1. **Klicka "+ New step"** (UTANFÖR alla loopar)
2. **Sök:** `list rows excel`
3. **Välj** **"List rows present in a table"** (Excel Online)

4. **Fyll i:**
   - **Location:** Välj OneDrive eller SharePoint från dropdown
   - **Document Library:** Välj library där din Excel ligger
   - **File:** Klicka på mappikonen och navigera till din Excel-fil
   - **Table:** Välj **ProcessOwnersTable**

### Steg 8.2: Loopa och radera gamla rader

1. **Klicka "+ New step"**
2. **Sök:** `apply to each`
3. **Välj** **"Apply to each"**

4. **Select an output:**
   - Dynamic content: **"value"** (från List rows)

5. **Inuti denna loop, klicka "+ Add an action"**
6. **Sök:** `delete a row excel`
7. **Välj** **"Delete a row"** (Excel Online)

8. **Fyll i:**
   - **Location:** Samma som innan
   - **Document Library:** Samma
   - **File:** Samma Excel-fil
   - **Table:** ProcessOwnersTable
   - **Row id:** Dynamic content: **"id"** (från Apply to each)

**✅ Gamla rader raderas nu**

### Steg 8.3: Skriv ny data

1. **Klicka "+ New step"** (UTANFÖR delete-loopen)
2. **Sök:** `apply to each`
3. **Välj** **"Apply to each"**

4. **Select an output:**
   - Dynamic content: **"CollectedData"** (variabeln)

5. **Inuti denna loop, klicka "+ Add an action"**
6. **Sök:** `add a row excel`
7. **Välj** **"Add a row into a table"** (Excel Online)

8. **Fyll i:**
   - **Location:** Samma
   - **Document Library:** Samma
   - **File:** Samma Excel-fil
   - **Table:** ProcessOwnersTable

9. **Kolumner dyker upp automatiskt. Fyll i varje:**
   - **SiteName:** Dynamic: **"SiteName"** (från Current item i denna loop)
   - **SiteURL:** Dynamic: **"SiteURL"**
   - **PageName:** Dynamic: **"PageName"**
   - **PageURL:** Dynamic: **"PageURL"**
   - **ProcessName:** Dynamic: **"ProcessName"**
   - **ProcessOwner:** Dynamic: **"ProcessOwner"**
   - **ProcessManagers:** Dynamic: **"ProcessManagers"**
   - **Confidence:** Dynamic: **"Confidence"**
   - **LastUpdated:** Dynamic: **"LastUpdated"**

**✅ Nya rader skrivs till Excel**

---

## Del 9: Lägg till notifiering (5 minuter - valfritt)

1. **Klicka "+ New step"** (längst ner)
2. **Sök:** `send email`
3. **Välj** **"Send an email (V2)"** (Office 365 Outlook)

4. **Fyll i:**
   - **To:** Din email-adress
   - **Subject:** `Process Owners Report Updated - `
     - Efter detta, lägg till Expression: `formatDateTime(utcNow(), 'yyyy-MM-dd')`
   - **Body:** Skriv:
     ```
     Rapporten har uppdaterats!

     Sidor processade:
     ```
     - Dynamic: Length expression: `length(variables('CollectedData'))`

     ```

     Uppdaterad:
     ```
     - Expression: `formatDateTime(utcNow(), 'yyyy-MM-dd HH:mm')`

**✅ Du får email när flödet är klart**

---

## Del 10: Spara och testa (10 minuter)

### Steg 10.1: Spara flödet

1. **Klicka "Save"** längst upp till höger
2. **Vänta** tills det står "Your flow is ready"

**✅ Flödet är sparat!**

### Steg 10.2: Testa flödet

1. **Klicka "Test"** längst upp till höger
2. **Välj "Manually"**
3. **Klicka "Test"**
4. **Klicka "Run flow"**
5. **Klicka "Done"**

**Nu körs flödet!** Det kan ta 2-10 minuter beroende på antal sidor.

### Steg 10.3: Övervaka körningen

Du ser en animation med varje steg som körs:
- ✅ Grön checkmark = Lyckades
- ❌ Rött X = Misslyckades

**Om något blir rött:**
1. Klicka på det röda steget
2. Läs felmeddelandet
3. Se "Del 11: Felsökning" nedan

### Steg 10.4: Kolla resultatet

1. **Öppna din Excel-fil**
2. **Uppdatera** (Ctrl+R eller F5)
3. **Kolla att data finns i tabellen**

**Förväntad output:**
- Varje sida = en rad
- ProcessOwner och ProcessManagers ifyllda (eller "Not found")
- Confidence-nivå (high/medium/low)

**✅ OM DU SER DATA: GRATTIS! 🎉**

---

## Del 11: Felsökning

### Problem 1: "Unauthorized" på SharePoint HTTP request

**Symptom:** Rött X på "Send an HTTP request to SharePoint"

**Lösning:**
1. Klicka på steget
2. Klicka "Change connection"
3. Välj din connection eller skapa ny
4. Logga in med ditt konto
5. Spara och testa igen

### Problem 2: "Invalid JSON" på Parse JSON

**Symptom:** Rött X på "Parse JSON" (efter AI-anrop)

**Orsak:** AI returnerade inte valid JSON

**Lösning:**
1. Klicka på "ParseAIResponse" steget som misslyckades
2. Kolla "Content" - vad står där?
3. Om det står text före/efter JSON (t.ex. "```json" eller förklaring):
   - Lägg till ett Compose-steg mellan AIResponse och ParseAIResponse
   - Använd replace-funktioner för att rensa bort extra text:
     ```
     replace(replace(outputs('AIResponse'), '```json', ''), '```', '')
     ```

### Problem 3: "File not found" på Excel

**Symptom:** Rött X på Excel-operationer

**Lösning:**
1. Dubbelkolla sökvägen till Excel-filen
2. Se till att filen är i rätt library
3. Testa att öppna filen manuellt för att bekräfta att den finns

### Problem 4: "Column not found" på Add row to Excel

**Symptom:** Rött X när man ska skriva till Excel

**Lösning:**
1. Öppna Excel-filen
2. Verifiera att alla kolumnnamn stämmer EXAKT (case-sensitive)
3. Kolla att tabellen heter exakt "ProcessOwnersTable"

### Problem 5: "Timeout" - flödet tar för lång tid

**Symptom:** Flödet stannar efter 2 minuter

**Lösning:**
1. Klicka på "Send an HTTP request to SharePoint" steget
2. Klicka "..." > Settings
3. Öka Timeout till "PT10M" (10 minuter)
4. Gör samma för "Get file content" och "HTTP" (OpenAI-anrop)

### Problem 6: AI returnerar "Not found" för allt

**Symptom:** Alla rader i Excel har "Not found" för ProcessOwner

**Orsak:** AI hittar inte informationen i sidinnehållet

**Felsök:**
1. Klicka på "PageContent" steget i en körning
2. Kolla "Outputs" - ser du faktiskt text där?
3. Om du ser HTML-taggar men ingen text:
   - Sidan kanske inte har textinnehåll, bara web parts
   - Prova att justera prompten
   - Eller kolla om du kan få text på annat sätt

**Alternativ lösning:**
- Testa med en sida där du VET att Process Owner finns
- Se om AI:n hittar den
- Justera prompten baserat på det

### Problem 7: API Key-fel från OpenAI

**Symptom:** "Incorrect API key provided" eller "401 Unauthorized"

**Lösning:**
1. Verifiera din API-nyckel på https://platform.openai.com/api-keys
2. Dubbelkolla att du skrev "Bearer " före nyckeln i Authorization-header
3. Se till att det inte finns extra mellanslag
4. Bekräfta att du har credits kvar på OpenAI-kontot

---

## Del 12: Optimeringar efter första körningen

### Optimering 1: Filtrera bara nya/ändrade sidor

Efter "Get HTTP request to SharePoint", lägg till filter:

**Ändra URI till:**
```
_api/web/lists/getbytitle('Site Pages')/items?$select=Title,FileRef,FileLeafRef,Id,Modified&$filter=Modified ge datetime'2025-01-01T00:00:00Z'
```

Detta hämtar bara sidor ändrade efter ett visst datum.

### Optimering 2: Skippa sidor som redan finns

Lägg till ett "Get rows" från Excel före du skriver:
- Jämför PageURL
- Om sidan redan finns OCH Modified-datum är samma: skippa

### Optimering 3: Lägg till felhantering

1. Klicka på "Apply to each 2" (sidor-loopen)
2. Klicka "..." > "Configure run after"
3. Lägg till en parallel gren
4. Sätt den att köra "has failed"
5. Lägg till "Compose" som loggar felet

Detta gör att flödet inte kraschar om EN sida misslyckas.

---

## Sammanfattning - Checklista

### Förberedelser:
- [ ] Excel-fil skapad med ProcessOwnersTable
- [ ] OpenAI API-nyckel skaffad
- [ ] SharePoint-sites listade

### Flödet byggt:
- [ ] Recurrence-trigger (daglig, kl 02:00)
- [ ] 4 variabler initierade
- [ ] Loop genom sites
- [ ] HTTP request för att hämta sidor
- [ ] Parse JSON (sidor)
- [ ] Loop genom varje sida
- [ ] Get file content (sidhinnehåll)
- [ ] Compose AIPrompt (med prompt)
- [ ] HTTP call till OpenAI
- [ ] Parse AI-svar
- [ ] Compose RecordToSave
- [ ] Append to CollectedData
- [ ] List/Delete gamla Excel-rader
- [ ] Add nya rader till Excel
- [ ] Send email-notifiering

### Testat:
- [ ] Manuell körning lyckades
- [ ] Data syns i Excel
- [ ] Accuracy är >85%

### Production:
- [ ] Schemaläggning aktiverad
- [ ] Första veckans körningar övervakade
- [ ] Felhantering lagt till

---

## Nästa steg

**När flödet fungerar:**
1. Låt det köra en vecka
2. Granska accuracy varje dag
3. Justera prompten vid behov
4. Lägg till fler sites gradvis

**Tips för förbättring:**
- Spara lyckade AI-svar för att analysera mönster
- Skapa en "low confidence"-rapport för manuell granskning
- Lägg till versionshantering (spara gamla värden innan uppdatering)

---

**LYCKA TILL! Du har nu en komplett guide för att bygga flödet. 🚀**

**Vid problem: Gå tillbaka till Del 11 (Felsökning) eller fråga mig!**

# Power Automate + AI: Extrahera Process Owners från SharePoint-sidor

## Översikt

Denna lösning använder **AI (GPT)** för att läsa SharePoint-sidornas innehåll och extrahera Process Owner/Manager-information automatiskt - oavsett hur sidorna är formaterade.

**Fördelar:**
- ✅ Fungerar med alla format (web parts, text, tabeller)
- ✅ Ingen behöver ändra sina sidor
- ✅ Inga behörigheter behövs (bara läsrättigheter)
- ✅ Kan börja direkt

**Nackdelar:**
- ⚠️ Kostar pengar (AI Builder credits eller OpenAI API)
- ⚠️ Mindre exakt än strukturerad data (måste verifieras)
- ⚠️ Långsammare (2-5 sekunder per sida)

---

## Del 1: Den perfekta prompten

### Grundprompt (använd denna)

```
You are a data extraction specialist. Your task is to extract process ownership information from SharePoint page content.

EXTRACT THE FOLLOWING:
1. Process Name: The name of the process (e.g., "SITS", "Problem Management", "Incident Management")
2. Process Owner: The person who owns the process (look for titles like "Process Owner", "Process Ägare", "Processägare")
3. Process Manager(s): The person(s) who manage the process (look for titles like "Process Manager", "Process Managers", "Processledare")

SEARCH PATTERNS TO LOOK FOR:
- "Process Owner:", "Process Ägare:", "Processägare:"
- "[ProcessName] Process Owner:" (e.g., "SITS Process Owner:")
- "Process Manager:", "Process Managers:", "Processledare:"
- "[ProcessName] Process Manager:" (e.g., "SITS Process Managers:")
- Person names followed by job titles in parentheses
- Person cards or contact information

IMPORTANT RULES:
- Extract ONLY names of people, not job titles
- If multiple people are listed for Process Manager, include all of them
- If information is missing, return "Not found" for that field
- Return ONLY valid JSON, no additional text or explanation
- Be case-insensitive when searching for patterns
- Look for variations in spelling (Swedish/English)

RETURN FORMAT (JSON only):
{
  "processName": "extracted process name or page title",
  "processOwner": "Full Name" or "Not found",
  "processManagers": ["Full Name 1", "Full Name 2"] or ["Not found"],
  "confidence": "high" or "medium" or "low"
}

PAGE CONTENT TO ANALYZE:
---
{CONTENT}
---

Return only the JSON object, nothing else.
```

---

## Del 2: Förbättrade prompts för olika scenarion

### Prompt för sidor med web parts

```
You are analyzing a SharePoint page that may contain web parts showing people information.

LOOK FOR:
- People web parts (usually show name, photo, and job title)
- Text sections with role labels
- Lists or tables with name-role pairs

EXTRACT:
1. Process Name (from page title or headings)
2. Process Owner (single person)
3. Process Managers (can be multiple people)

PATTERNS:
- "SITS Process Owner" followed by person name
- "Process Managers" section with multiple names
- Person cards showing name and title
- Text like "Owner: John Doe"

IGNORE:
- Job titles alone (e.g., "Operation Process Improv.")
- Department names
- Generic text without names

Return ONLY this JSON format:
{
  "processName": "string",
  "processOwner": "Full Name or Not found",
  "processManagers": ["Name1", "Name2"] or ["Not found"],
  "confidence": "high/medium/low",
  "notes": "Any relevant context if confidence is low"
}

CONTENT:
---
{CONTENT}
---
```

### Prompt för sidor med bara text

```
You are extracting process ownership from plain text content.

TASK: Find person names associated with process ownership roles.

SEARCH FOR THESE PATTERNS:
1. "Process Owner: [Name]"
2. "[ProcessName] Process Owner: [Name]"
3. "Owned by: [Name]"
4. "Responsible: [Name]"
5. "Contact: [Name]" (if in ownership context)
6. "Process Manager(s): [Name(s)]"

EXAMPLES OF VALID EXTRACTIONS:
- "SITS Process Owner: Thiel Michael (YISP)" → processOwner: "Thiel Michael"
- "Process Managers: John Doe, Jane Smith" → processManagers: ["John Doe", "Jane Smith"]
- "Ägare: Anna Andersson" → processOwner: "Anna Andersson"

CLEAN THE NAMES:
- Remove parentheses content: "John (YISP)" → "John"
- Remove titles: "Dr. John Doe" → "John Doe"
- Remove extra spaces
- Keep first and last name only

CONFIDENCE LEVELS:
- high: Clear labels with names directly after
- medium: Names found near ownership keywords
- low: Guessing based on context

Return JSON:
{
  "processName": "string",
  "processOwner": "string",
  "processManagers": ["string"],
  "confidence": "string"
}

CONTENT:
---
{CONTENT}
---
```

### Prompt för svenska sidor

```
Du är en dataextraktionsspecialist som läser svenska SharePoint-sidor.

UPPGIFT: Extrahera processägare och processledare från sidinnehållet.

SÖKORD (svenska och engelska):
- "Processägare", "Process Owner", "Ägare"
- "Processledare", "Process Manager", "Process Managers"
- "Ansvarig", "Responsible"
- "Kontaktperson", "Contact"
- "[ProcessNamn] Processägare" (t.ex. "SITS Processägare")

REGLER:
1. Extrahera BARA personnamn, inte jobbtitlar
2. Ta bort text inom parentes: "John Doe (YISP)" → "John Doe"
3. Om flera personer är listade som processledare, ta med alla
4. Om information saknas, returnera "Not found"
5. Var inte känslig för stora/små bokstäver

RETURFORMAT (JSON):
{
  "processName": "processens namn eller sidtitel",
  "processOwner": "För- och Efternamn",
  "processManagers": ["Namn 1", "Namn 2"],
  "confidence": "high" eller "medium" eller "low"
}

INNEHÅLL ATT ANALYSERA:
---
{CONTENT}
---

Returnera ENDAST JSON-objektet, inget annat.
```

---

## Del 3: Power Automate-flödet

### Steg 1: Skapa flödet

```
Name: SharePoint Process Owners Extractor - AI Version
Trigger: Recurrence (Daily at 02:00)
```

### Steg 2: Initiera variabler

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

Action: Initialize variable
Name: CollectedData
Type: Array
Value: []
```

### Steg 3: Loop genom sites

```
Action: Apply to each
Select: SharePointSites
```

**Inside loop:**

#### 3.1: Hämta alla sidor

```
Action: Send an HTTP request to SharePoint
Site Address: @{item()}
Method: GET
Uri: _api/web/lists/getbytitle('Site Pages')/items?$select=Title,FileRef,FileLeafRef,Id
Headers:
  Accept: application/json;odata=nometadata
```

#### 3.2: Parse svar

```
Action: Parse JSON
Content: @{body('Send_an_HTTP_request_to_SharePoint')}
Schema:
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

#### 3.3: Loop genom sidor (nested loop)

```
Action: Apply to each
Select: @{body('Parse_JSON')?['value']}
```

**Inside nested loop:**

### Steg 4: Hämta sidinnehåll

#### 4.1: Konstruera URL till sidan

```
Action: Compose
Name: PageURL
Inputs: @{item()?['FileRef']}
```

#### 4.2: Hämta sidens HTML-innehåll

```
Action: Send an HTTP request to SharePoint
Site Address: @{variables('CurrentSite')}
Method: GET
Uri: @{outputs('PageURL')}
Headers:
  Accept: text/html
```

**Alternativ (om ovanstående inte fungerar):**

```
Action: Get file content
Site Address: @{variables('CurrentSite')}
File Identifier: @{item()?['FileRef']}
```

#### 4.3: Rensa HTML (valfritt men rekommenderat)

Om du får HTML-taggar, rensa dem först:

```
Action: Compose
Name: CleanedContent
Inputs:
@{replace(replace(replace(
  body('Send_an_HTTP_request_to_SharePoint_2'),
  '<script>', ''),
  '</script>', ''),
  '<style>', '')}
```

**OBS:** Detta är en enkel rensning. För bättre resultat, använd en HTML-to-text-parser.

### Steg 5: Skicka till AI för analys

#### 5.1: Bygg prompten

```
Action: Compose
Name: AIPrompt
Inputs:
You are a data extraction specialist. Your task is to extract process ownership information from SharePoint page content.

EXTRACT THE FOLLOWING:
1. Process Name: The name of the process
2. Process Owner: The person who owns the process
3. Process Manager(s): The person(s) who manage the process

SEARCH PATTERNS:
- "Process Owner:", "Process Ägare:", "Processägare:"
- "[ProcessName] Process Owner:"
- "Process Manager:", "Process Managers:"

RULES:
- Extract ONLY names, not job titles
- Remove text in parentheses
- If missing, return "Not found"
- Return ONLY valid JSON

FORMAT:
{
  "processName": "string",
  "processOwner": "string",
  "processManagers": ["string"],
  "confidence": "high/medium/low"
}

CONTENT:
---
@{outputs('CleanedContent')}
---

Return only JSON, nothing else.
```

#### 5.2: Anropa AI Builder

**Om du använder AI Builder (Create text with GPT):**

```
Action: Create text with GPT
Prompt: @{outputs('AIPrompt')}
```

**Om du använder Azure OpenAI:**

```
Action: HTTP
Method: POST
URI: https://[your-resource].openai.azure.com/openai/deployments/[deployment]/chat/completions?api-version=2024-02-15-preview
Headers:
  api-key: [Your API Key]
  Content-Type: application/json
Body:
{
  "messages": [
    {
      "role": "system",
      "content": "You are a data extraction assistant. Return only valid JSON."
    },
    {
      "role": "user",
      "content": "@{outputs('AIPrompt')}"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 500
}
```

**Om du använder OpenAI API direkt:**

```
Action: HTTP
Method: POST
URI: https://api.openai.com/v1/chat/completions
Headers:
  Authorization: Bearer [Your API Key]
  Content-Type: application/json
Body:
{
  "model": "gpt-4o-mini",
  "messages": [
    {
      "role": "system",
      "content": "You are a data extraction assistant. Return only valid JSON."
    },
    {
      "role": "user",
      "content": "@{outputs('AIPrompt')}"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 500
}
```

### Steg 6: Parse AI-svaret

#### 6.1: Extrahera JSON från svaret

**Om AI Builder:**
```
Action: Compose
Name: AIResponse
Inputs: @{outputs('Create_text_with_GPT')?['text']}
```

**Om HTTP till OpenAI/Azure:**
```
Action: Compose
Name: AIResponse
Inputs: @{body('HTTP')?['choices'][0]?['message']?['content']}
```

#### 6.2: Parse JSON-svaret

```
Action: Parse JSON
Content: @{outputs('AIResponse')}
Schema:
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

### Steg 7: Samla data

```
Action: Compose
Name: ExtractedRecord
Inputs:
{
  "SiteName": "@{last(split(variables('CurrentSite'), '/'))}",
  "SiteURL": "@{variables('CurrentSite')}",
  "PageName": "@{item()?['Title']}",
  "PageURL": "@{item()?['FileRef']}",
  "ProcessName": "@{body('Parse_JSON_2')?['processName']}",
  "ProcessOwner": "@{body('Parse_JSON_2')?['processOwner']}",
  "ProcessManagers": "@{join(body('Parse_JSON_2')?['processManagers'], '; ')}",
  "Confidence": "@{body('Parse_JSON_2')?['confidence']}",
  "LastUpdated": "@{utcNow()}"
}

Action: Append to array variable
Name: CollectedData
Value: @{outputs('ExtractedRecord')}
```

### Steg 8: Skriv till Excel

```
Action: Clear table (optional - clear old data first)
Location: OneDrive/SharePoint
File: Process_Owners_Report.xlsx
Table: ProcessOwnersTable

Action: Apply to each
Select: @{variables('CollectedData')}

  Action: Add a row into a table
  Location: OneDrive/SharePoint
  File: Process_Owners_Report.xlsx
  Table: ProcessOwnersTable
  Columns:
    SiteName: @{item()?['SiteName']}
    SiteURL: @{item()?['SiteURL']}
    PageName: @{item()?['PageName']}
    PageURL: @{item()?['PageURL']}
    ProcessName: @{item()?['ProcessName']}
    ProcessOwner: @{item()?['ProcessOwner']}
    ProcessManagers: @{item()?['ProcessManagers']}
    Confidence: @{item()?['Confidence']}
    LastUpdated: @{item()?['LastUpdated']}
```

---

## Del 4: Excel-struktur

### Skapa Excel-filen

**Kolumner:**

| Kolumn | Typ | Beskrivning |
|--------|-----|-------------|
| SiteName | Text | Site-namn |
| SiteURL | Text | Full URL till site |
| PageName | Text | Sidans titel |
| PageURL | Text | Full URL till sidan |
| ProcessName | Text | Processens namn (från AI) |
| ProcessOwner | Text | Process Owner (från AI) |
| ProcessManagers | Text | Process Managers, separerade med ; |
| Confidence | Text | AI:s konfidensnivå (high/medium/low) |
| LastUpdated | DateTime | När data uppdaterades |

**Tabell-namn:** `ProcessOwnersTable`

---

## Del 5: Optimeringar och best practices

### Optimering 1: Filtrera irrelevanta sidor

Lägg till filter för att bara processa relevanta sidor:

```
Action: Filter array
From: @{body('Parse_JSON')?['value']}
Where: @{contains(toLower(item()?['Title']), 'process')}
```

### Optimering 2: Cacha resultat

Spara AI-svar för att undvika att processa samma sida flera gånger:

```
Action: Get rows (Excel)
Where: PageURL eq @{item()?['FileRef']}

Condition: If count > 0 AND LastUpdated < 7 days ago
  → Skip this page
Else
  → Process with AI
```

### Optimering 3: Batch-processing

Istället för att anropa AI för varje sida, kombinera flera sidor:

```
Action: Compose
Inputs:
Analyze these @{length(variables('PageBatch'))} pages and extract process ownership for each.

[Page 1]
URL: page1.aspx
CONTENT: ...

[Page 2]
URL: page2.aspx
CONTENT: ...

Return JSON array: [{"pageUrl": "...", "processName": "...", ...}, ...]
```

**Fördel:** Färre API-anrop = billigare
**Nackdel:** Mer komplex parsing

### Optimering 4: Använd billigare modell först

```
1. Försök med GPT-4o-mini först (billig, snabb)
2. Om confidence = "low", kör om med GPT-4o (dyr, bättre)
```

### Optimering 5: Lägg till human-in-the-loop

För poster med låg confidence:

```
Condition: If confidence = "low"
  → Send approval email with extracted data
  → Wait for approval
  → Update Excel with corrected data
```

---

## Del 6: Prompt engineering tips

### Tips 1: Ge exempel

Lägg till exempel i prompten:

```
EXAMPLES:
Input: "SITS Process Owner: Thiel Michael (YISP)"
Output: {"processOwner": "Thiel Michael"}

Input: "Process Managers: John Doe, Jane Smith"
Output: {"processManagers": ["John Doe", "Jane Smith"]}
```

### Tips 2: Använd few-shot learning

```
Example 1:
Content: "Finance Process Owner: Anna Svensson..."
Extract: {"processName": "Finance", "processOwner": "Anna Svensson", ...}

Example 2:
Content: "SITS - Special IT Services. Owner: Michael Thiel..."
Extract: {"processName": "SITS", "processOwner": "Michael Thiel", ...}

Now analyze this content:
[ACTUAL CONTENT]
```

### Tips 3: Justera temperature

```
temperature: 0.1-0.3  → Mer konsekvent, mindre kreativ (BRA för extraktion)
temperature: 0.7-1.0  → Mer kreativ, mindre förutsägbar (DÅLIGT för extraktion)
```

### Tips 4: Begränsa output

```
"Return MAXIMUM 200 characters for each field"
"If unsure, prefer 'Not found' over guessing"
"Be conservative - only extract if you are 80%+ confident"
```

---

## Del 7: Felsökning

### Problem 1: AI returnerar inte valid JSON

**Lösning:**
```
Action: Compose
Name: CleanJSON
Inputs:
@{replace(replace(replace(
  outputs('AIResponse'),
  '```json', ''),
  '```', ''),
  '\n', '')}
```

Lägg till i prompt:
```
"CRITICAL: Return ONLY the JSON object. No markdown, no code blocks, no explanations."
```

### Problem 2: AI hittar inte namnen

**Lösning:**
- Kontrollera att HTML är rensat ordentligt
- Kolla om namnen faktiskt finns på sidan (gå in manuellt)
- Lägg till fler sökord i prompten
- Använd bättre modell (GPT-4 istället för GPT-3.5)

### Problem 3: AI "hittar" namn som inte finns (hallucination)

**Lösning:**
```
Lägg till i prompt:
"DO NOT invent or guess names. If you cannot find a name explicitly stated, return 'Not found'."
"Be very conservative. Only extract names that are clearly labeled as Process Owner/Manager."
```

### Problem 4: Kostar för mycket

**Lösningar:**
- Använd GPT-4o-mini istället för GPT-4 (10x billigare)
- Cacha resultat och skippa oförändrade sidor
- Begränsa sidinnehållet (skicka bara första 2000 tecken)
- Batch-processa flera sidor i ett anrop

### Problem 5: Tar för lång tid

**Lösningar:**
- Kör bara för nya/uppdaterade sidor (filter på Modified-datum)
- Öka timeout på actions (Settings > Timeout = 10 minutes)
- Dela upp i flera flöden (en per site)
- Kör parallellt där möjligt

---

## Del 8: Kostnadskalkyl

### AI Builder (med Office 365)

**Priser:**
- Vissa Office 365-licenser inkluderar AI Builder credits
- Extra credits: ~$500/månad för 1 miljon credits
- 1 text generation = ~5-10 credits

**Kostnad för 100 sidor/natt:**
- 100 sidor × 10 credits = 1000 credits/dag
- 30 dagar = 30,000 credits/månad
- **~$15-30/månad**

### OpenAI API (GPT-4o-mini)

**Priser (2025):**
- Input: $0.15 per 1M tokens
- Output: $0.60 per 1M tokens

**Kostnad för 100 sidor/natt:**
- 100 sidor × 2000 tokens input = 200K tokens = $0.03
- 100 sidor × 200 tokens output = 20K tokens = $0.01
- Per dag = $0.04
- Per månad = **~$1.20**

### OpenAI API (GPT-4o)

**Priser:**
- Input: $2.50 per 1M tokens
- Output: $10.00 per 1M tokens

**Kostnad för 100 sidor/natt:**
- Per månad = **~$20-40**

### Rekommendation:
**Använd OpenAI API med GPT-4o-mini** = billigast och snabbast! 💰

---

## Del 9: Testing och validering

### Fas 1: Testa med 1 sida

1. Skapa test-flöde med EN sida
2. Kör manuellt
3. Granska AI:s output
4. Jämför med faktisk data på sidan
5. Justera prompt om nödvändigt

### Fas 2: Testa med 10 sidor

1. Välj 10 olika sidor (olika format)
2. Kör flödet
3. Granska alla resultat
4. Beräkna accuracy:
   ```
   Accuracy = (Korrekta extraheringar / Totalt antal fält) × 100%
   ```
5. Mål: >90% accuracy

### Fas 3: Validering av alla sidor

1. Kör för alla 100 sidor
2. Exportera Excel
3. Sortera på "Confidence"
4. Manuellt granska alla med "low" confidence
5. Granska stickprov av "medium" och "high"

### Fas 4: Production

1. Schemalägg daglig körning
2. Första veckan: kolla resultat varje dag
3. Sätt upp alert för failures
4. Månadsvis: spot-check för kvalitet

---

## Del 10: Exempel på komplett prompt (copy-paste-klar)

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

Example 3:
Input: "This is the HR onboarding page with various resources..."
Output:
{
  "processName": "HR onboarding",
  "processOwner": "Not found",
  "processManagers": ["Not found"],
  "confidence": "low"
}

NOW ANALYZE THIS CONTENT:
---
{CONTENT}
---

CRITICAL: Return ONLY the JSON object above. No explanations, no markdown, no code blocks.
```

---

## Sammanfattning

### Checklist:

- [ ] Välj AI-provider (rekommenderat: OpenAI API med GPT-4o-mini)
- [ ] Skapa Excel-fil med kolumner
- [ ] Bygg Power Automate-flöde enligt guide
- [ ] Kopiera prompten ovan (Del 10) in i flödet
- [ ] Testa med 1 sida
- [ ] Justera prompt om nödvändigt
- [ ] Testa med 10 sidor
- [ ] Verifiera accuracy >90%
- [ ] Rulla ut till alla 100 sidor
- [ ] Schemalägg daglig körning
- [ ] Sätt upp kvalitetskontroller

### Förväntad tidsåtgång:
- Setup: 2-3 timmar
- Prompt-tuning: 1-2 timmar
- Testing: 1-2 timmar
- **Totalt: 4-7 timmar**

### Förväntad kostnad:
- **$1-5/månad** (med GPT-4o-mini)

### Förväntad accuracy:
- **85-95%** (med bra prompt och kvalitetsdata på sidorna)

---

**Lycka till! Du har nu allt du behöver för att bygga en AI-driven lösning.** 🎉

# Snabbtest: AI-extraktion på EN SharePoint-sida

## Översikt

Detta är en **förenklad testversion** för att verifiera att AI:n fungerar på dina SharePoint-sidor.

**Vad den gör:**
- Hämtar innehåll från EN specifik sida (som du anger)
- Skickar till OpenAI för analys
- Visar resultatet direkt (ingen Excel)

**Tidsåtgång:** 10-15 minuter

---

## Steg 1: Förberedelser (2 minuter)

### 1.1: Välj AI-metod

Du har två alternativ:

**Alternativ A: AI Builder (REKOMMENDERAT - enklast)**
- ✅ Inbyggt i Power Automate
- ✅ Ingen API-nyckel behövs
- ✅ Superenkelt att använda
- ⚠️ Kostar AI Builder credits (oftast inkluderat i Office 365)

**Alternativ B: OpenAI API (billigare)**
- ⚠️ Kräver OpenAI API-nyckel
- ⚠️ Lite mer setup
- ✅ Mycket billigare (~$0.001 vs $0.05 per anrop)
- ✅ Mer kontroll över modell

**För snabbtest: Använd Alternativ A (AI Builder)!**

### 1.2: Hitta URL till en testsida

Välj EN av dina SharePoint-sidor att testa med:

**Exempel:**
```
https://company.sharepoint.com/sites/IT/SitePages/SITS.aspx
```

**Välj en sida där du VET att Process Owner finns så du kan verifiera resultatet!**

---

## Steg 2: Bygg testflödet (10 minuter)

### 2.1: Skapa flödet

1. **Gå till:** https://make.powerautomate.com
2. **Klicka "Create"** > **"Instant cloud flow"**
3. **Flow name:** `AI Test - Single Page`
4. **Choose how to trigger:** Välj **"Manually trigger a flow"**
5. **Klicka "Create"**

**✅ Du har nu ett manuellt flöde (tomt)**

---

### 2.2: Lägg till variabler (för URL och API-nyckel)

#### Variabel 1: SharePoint Site URL

1. **Klicka "+ New step"**
2. **Sök:** `initialize variable`
3. **Välj "Initialize variable"**

**Fyll i:**
- **Name:** `SiteURL`
- **Type:** String
- **Value:** Din SharePoint-site URL (UTAN sidan)
  ```
  https://company.sharepoint.com/sites/IT
  ```

#### Variabel 2: Page Path

1. **Klicka "+ New step"**
2. **Sök:** `initialize variable`
3. **Välj "Initialize variable"**

**Fyll i:**
- **Name:** `PagePath`
- **Type:** String
- **Value:** Sökväg till sidan (från /sites/)
  ```
  /sites/IT/SitePages/SITS.aspx
  ```

**Alternativ:** Om du har hela URL:en, använd bara EN variabel:
- **Name:** `PageURL`
- **Type:** String
- **Value:** `https://company.sharepoint.com/sites/IT/SitePages/SITS.aspx`

---

### 2.3: Hämta sidinnehållet

1. **Klicka "+ New step"**
2. **Sök:** `get file content sharepoint`
3. **Välj "Get file content" (SharePoint)**

**Fyll i:**
- **Site Address:** Klicka i fältet
  - Dynamic content: Välj **"SiteURL"** (variabeln du skapade)
- **File Identifier:** Klicka i fältet
  - Dynamic content: Välj **"PagePath"**

**Alternativ (om du använder bara PageURL):**
- Dela upp URL:en i site och path i flödet, ELLER
- Skriv in allt manuellt direkt:
  - Site Address: `https://company.sharepoint.com/sites/IT`
  - File Identifier: `/sites/IT/SitePages/SITS.aspx`

**✅ Sidinnehållet hämtas nu**

---

### 2.4: Konvertera innehåll till text

1. **Klicka "+ New step"**
2. **Sök:** `compose`
3. **Välj "Compose"**

**Fyll i:**
- **Inputs:** Klicka i fältet
  - Dynamic content: Välj **"File content"** (från Get file content)

**Byt namn:**
- Klicka "..." > Rename > `PageContent`

---

### 2.5: Bygg AI-prompten

1. **Klicka "+ New step"**
2. **Sök:** `compose`
3. **Välj "Compose"**

**Fyll i Inputs - klistra in hela denna text:**

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

**EFTER texten ovan, klicka i fältet igen och:**
- Dynamic content: Välj **"Outputs"** (från PageContent/Compose)

**EFTER det, skriv:**
```
---

CRITICAL: Return ONLY the JSON object above. No explanations, no markdown, no code blocks.
```

**✅ Prompten är klar**

**Byt namn:**
- "..." > Rename > `AIPrompt`

---

### 2.6: Anropa AI

### ALTERNATIV A: AI Builder (Rekommenderat)

1. **Klicka "+ New step"**
2. **Sök:** `create text with gpt`
3. **Välj "Create text with GPT"** (AI Builder)

**Fyll i:**
- **Create text with GPT using a prompt:** Klicka i fältet
  - Dynamic content: Välj **"Outputs"** (från AIPrompt)

**Det är allt!** ✅

**Byt namn:**
- "..." > Rename > `CallAI`

**FORTSÄTT TILL STEG 2.7 (hoppa över Alternativ B)**

---

### ALTERNATIV B: OpenAI API (Om du vill)

**Bara om du har skaffat OpenAI API-nyckel:**

1. **Klicka "+ New step"**
2. **Sök:** `http`
3. **Välj "HTTP"** (Premium connector)

**Fyll i:**

**Method:** POST

**URI:**
```
https://api.openai.com/v1/chat/completions
```

**Headers:** Klicka "Show advanced options", sedan "+ Add new item" två gånger

**Header 1:**
- Key: `Authorization`
- Value: `Bearer sk-proj-DINAPI-NYCKEL`
  *(Ersätt med din RIKTIGA API-nyckel!)*

**Header 2:**
- Key: `Content-Type`
- Value: `application/json`

**Body:** Klistra in detta:
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

**Efter `"content": "` - klicka i fältet:**
- Dynamic content: Välj **"Outputs"** (från AIPrompt)

**Efter det, fortsätt skriva:**
```json
"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 500
}
```

**VIKTIGT: Se till att alla citattecken och klamrar stämmer!**

**✅ OpenAI-anropet är klart**

**Byt namn:**
- "..." > Rename > `CallOpenAI`

---

### 2.7: Extrahera AI-svaret

**Om du använde ALTERNATIV A (AI Builder):**

1. **Klicka "+ New step"**
2. **Sök:** `compose`
3. **Välj "Compose"**

**Fyll i Inputs:**
- Klicka i fältet
- Dynamic content: Välj **"text"** (från Create text with GPT)

**✅ AI-svaret extraheras**

**Byt namn:**
- "..." > Rename > `AIResponse`

---

**Om du använde ALTERNATIV B (OpenAI API):**

1. **Klicka "+ New step"**
2. **Sök:** `compose`
3. **Välj "Compose"**

**Fyll i Inputs - använd Expression:**
- Klicka på **fx** (expression-knappen)
- Klistra in:
  ```
  body('CallOpenAI')?['choices']?[0]?['message']?['content']
  ```

**✅ AI-svaret extraheras**

**Byt namn:**
- "..." > Rename > `AIResponse`

---

### 2.8: Visa resultatet (skicka email)

1. **Klicka "+ New step"**
2. **Sök:** `send email`
3. **Välj "Send an email (V2)" (Office 365 Outlook)**

**Fyll i:**

**To:** Din email-adress

**Subject:**
```
AI Test Result - SharePoint Process Owner
```

**Body:** Skriv detta:
```
Testkörning klar!

Sida som analyserades:
```

Klicka i fältet:
- Dynamic: **PagePath** (eller PageURL)

Fortsätt skriva:
```

AI-svar:
```

Klicka i fältet:
- Dynamic: **Outputs** (från AIResponse)

Fortsätt:
```

---
Rådata (sidinnehåll, första 500 tecken):
```

Klicka i fältet, välj Expression och skriv:
```
substring(outputs('PageContent'), 0, 500)
```

**✅ Email kommer skickas med resultatet**

---

## Steg 3: Spara och testa (5 minuter)

### 3.1: Spara flödet

1. **Klicka "Save"** längst upp till höger
2. Vänta tills det står "Your flow is ready"

### 3.2: Kör testet

1. **Klicka "Test"** längst upp till höger
2. **Välj "Manually"**
3. **Klicka "Test"**
4. **Klicka "Run flow"**
5. **Klicka "Done"**

**Nu körs flödet!**

### 3.3: Övervaka

Du ser alla steg köra:
- ✅ Grön = Lyckades
- ❌ Röd = Misslyckades

**Vänta tills alla är klara (30 sekunder - 1 minut)**

### 3.4: Kolla resultatet

**Två sätt att se resultatet:**

**Alternativ 1: I flödet**
1. Klicka på "AIResponse" (Compose-steget)
2. Läs "Outputs"
3. Du bör se JSON som:
   ```json
   {
     "processName": "SITS",
     "processOwner": "Thiel Michael",
     "processManagers": ["John Doe", "Jane Smith"],
     "confidence": "high"
   }
   ```

**Alternativ 2: I email**
1. Kolla din inbox
2. Öppna mailet "AI Test Result - SharePoint Process Owner"
3. Läs AI-svaret

---

## Steg 4: Utvärdera resultatet

### ✅ Lyckades om:
- Du ser JSON med processName, processOwner, processManagers
- Namnen stämmer med vad som faktiskt finns på sidan
- Confidence är "high" eller "medium"

### ⚠️ Behöver justering om:
- AI:n returnerar "Not found" fast namn finns
- AI:n hittar fel namn
- Confidence är "low"
- JSON är felformaterat

### ❌ Misslyckades om:
- Rött X på något steg
- Inget email kom
- AI-svar är tomt eller bara felmeddelande

---

## Steg 5: Felsökning

### Problem 1: "Unauthorized" på Get file content

**Lösning:**
1. Klicka på steget "Get file content"
2. "Change connection"
3. Logga in med ditt konto
4. Testa igen

### Problem 2: "401 Unauthorized" på CallOpenAI

**Lösning:**
1. Verifiera API-nyckeln på https://platform.openai.com/api-keys
2. Se till att du skrev "Bearer " före nyckeln
3. Kolla att nyckeln inte har extra mellanslag
4. Bekräfta att du har credits på OpenAI-kontot

### Problem 3: AI returnerar text istället för JSON

**Symptom:** AI-svaret har extra text som "Here's the extraction:" eller ```json

**Lösning:**
Lägg till ett steg mellan AIResponse och Send email:

1. **Ny action: Compose**
2. **Inputs - använd expression:**
   ```
   replace(replace(outputs('AIResponse'), '```json', ''), '```', '')
   ```

Detta rensar bort markdown-formatting.

### Problem 4: "File not found"

**Lösning:**
1. Dubbelkolla att File Identifier är rätt
2. Försök öppna sidan manuellt i webbläsaren
3. Kopiera exakt sökväg från URL:en

### Problem 5: AI:n hittar inte namnen

**Symptom:** AI returnerar "Not found" för alla fält

**Felsök:**
1. Kolla "PageContent" steget - ser du faktiskt text?
2. Om du bara ser HTML-taggar men ingen text:
   - Sidan kanske bara har web parts
   - AI:n behöver kanske bättre HTML-parsing

**Test:**
- Öppna sidan manuellt i webbläsaren
- Kolla att Process Owner faktiskt står på sidan
- Om det bara är en web part med en bild, kan AI:n inte läsa det

---

## Steg 6: Justera prompten (om nödvändigt)

### Om AI:n missade namnet:

**Lägg till i prompten under "WHERE TO LOOK":**
```
- Text containing "[Specific pattern from your page]"
```

Exempel: Om din sida har "Ansvarig: John Doe", lägg till:
```
- Text containing "Ansvarig:"
```

### Om AI:n hittade fel namn:

**Lägg till i "EXTRACTION RULES":**
```
✗ Do NOT extract [type of false match you got]
```

### Om confidence alltid är "low":

**Justera CONFIDENCE LEVELS:**
```
- "high": Names found with ANY ownership-related keyword
- "medium": Names in proximity to process information
- "low": Only if uncertain about name format
```

---

## Steg 7: Testa fler sidor

När det fungerar på en sida:

1. **Ändra variabeln PagePath**
2. **Kör Test igen**
3. **Jämför resultat**

Testa med 3-5 olika sidor för att se:
- Fungerar det på alla?
- Vilka sidor ger "high" vs "low" confidence?
- Behöver prompten justeras?

---

## Nästa steg: Bygg hela flödet

När testet fungerar bra (>80% accuracy):

✅ **Gå till:** `STEG-FOR-STEG-BYGG-FLOW.md`

Du kan kopiera följande delar från detta testflöde:
- AIPrompt (hela prompten)
- CallOpenAI (HTTP-anropet)
- AIResponse (extract logic)

Och bygga resten enligt huvudguiden!

---

## Snabb sammanfattning

**Detta testflöde:**
1. Manuell trigger
2. 2 variabler (SiteURL, PagePath)
3. Get file content (hämta sidan)
4. Compose PageContent
5. Compose AIPrompt (med din prompt)
6. **Create text with GPT** (AI Builder) ELLER HTTP CallOpenAI
7. Compose AIResponse
8. Send email med resultat

**Totalt: 8 steg, 10-15 minuter**

**Kostnad per test:**
- **AI Builder:** ~1-5 credits per test (ofta inkluderat i Office 365)
- **OpenAI API:** ~$0.001 (en tiondels cent)
- Kan testa 100 gånger för nästan gratis!

---

## Checklista

Förberedelser:
- [ ] Valt AI-metod (AI Builder ELLER OpenAI API)
- [ ] Testsida (URL) vald
- [ ] (Bara om OpenAI API) API-nyckel skaffad

Byggt testflödet:
- [ ] Manuell trigger
- [ ] Variabler för URL/Path
- [ ] Get file content
- [ ] Prompten kopierad in
- [ ] AI-anrop konfigurerat (AI Builder eller OpenAI)
- [ ] Email med resultat

Testat:
- [ ] Flödet körde utan fel
- [ ] Email mottaget
- [ ] AI-svar är JSON
- [ ] Namn stämmer med sidan
- [ ] Confidence är acceptabel

Nästa steg:
- [ ] Testat 3-5 olika sidor
- [ ] Accuracy >80%
- [ ] Redo att bygga hela flödet

---

**Lycka till med testet! 🧪**

**Kommer det fungera? Ja, om:**
- Din sida har textinnehåll (inte bara bilder)
- Process Owner/Manager finns på sidan
- OpenAI API-nyckeln är giltig

**Rapportera tillbaka:**
- Fungerade det?
- Vad fick du för resultat?
- Behöver prompten justeras?

# Instruktion: Lägg till Process Owner på din sida

## För dig som administrerar en process-sida

Du behöver lägga till information om Process Owner och Process Manager på din sida så att vi kan samla in en översikt automatiskt.

**Det tar 2 minuter och ändrar INGENTING på hur din sida ser ut.**

---

## ⚡ Snabbtest - Finns fälten redan?

Innan du börjar, testa om fälten redan är klara:

1. **Gå till din process-sida** (t.ex. SITS)
2. **Klicka på "Edit"** längst upp till höger (där det står "Posted - Share - Edit")
3. **Titta direkt under titeln** eller **leta efter en "Properties"-knapp**

**Ser du fält som heter ProcessOwner, ProcessManager eller ProcessName?**
- ✅ **JA** → Gå direkt till **Metod 1** nedan och fyll i dem!
- ❌ **NEJ** → Fälten är inte skapade än. Kontakta IT/SharePoint-admin och hänvisa dem till: `SHAREPOINT-PAGE-PROPERTIES-GUIDE-SV.md`

---

## Metod 1: Via Edit-läget (ENKLAST)

### Steg 1: Öppna din sida
Gå till din process-sida (t.ex. SITS-sidan)

### Steg 2: Klicka på Edit
Längst upp till höger ser du: **Posted - Share - Edit**
- Klicka på **Edit**

### Steg 3: Leta efter Properties-panelen
När du är i edit-mode, **klicka INTE på själva sidinnehållet**.

Titta istället **längst upp under menyfältet**.
Du kan se en av dessa:

**Alternativ A:** En panel med fält direkt under titeln
- Om du ser fält som "ProcessOwner", "ProcessManager" här
- Fyll i dem direkt (hoppa till Steg 5)

**Alternativ B:** En knapp eller länk som säger "Properties" eller "Page details"
- Klicka på den
- En panel öppnas till höger eller en ny vy visas

**Alternativ C:** Inget syns
- Gå till Metod 2 nedan istället

### Steg 4: Öppna Properties (om du behöver)
Om properties inte syns direkt:
- Leta efter **"..."** (tre prickar) i edit-mode
- Eller en knapp som säger **"Page details"**
- Eller **"Properties"**
- Klicka på den

### Steg 5: Fyll i fälten
Du ser nu metadata-fält. Hitta dessa:

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

### Steg 6: Spara sidan
- Klicka **Publish** eller **Publicera** längst upp till höger
- Eller **Save** om du vill spara som draft

**Klart!** ✅

Din sida ser exakt likadan ut, men informationen finns nu i bakgrunden.

---

## Metod 2: Via URL-trick (om Edit-mode inte visar fält)

Om du inte ser fälten i edit-mode, prova detta:

### Steg 1: Öppna din sida
Gå till din process-sida som vanligt

### Steg 2: Kopiera URL:en
Kopiera hela URL:en från webbläsaren
T.ex: `https://company.sharepoint.com/sites/IT/SitePages/SITS.aspx`

### Steg 3: Öppna ny flik och modifiera URL:en
Klistra in URL:en i en ny flik och lägg till detta **i slutet**:

```
?ControlMode=Edit&DisplayMode=Design
```

**Exempel:**
Från: `https://company.sharepoint.com/sites/IT/SitePages/SITS.aspx`
Till: `https://company.sharepoint.com/sites/IT/SitePages/SITS.aspx?ControlMode=Edit&DisplayMode=Design`

### Steg 4: Öppna den nya URL:en
Tryck Enter - du kommer till en vy där du ser metadata-fält direkt

### Steg 5: Fyll i fält
Fyll i ProcessOwner, ProcessManager, ProcessName

### Steg 6: Spara
Klicka Save/Publish

---

## Metod 3: Be IT/Site Owner göra det

Om ingen av metoderna ovan fungerar för dig:

### Kontakta IT eller Site Owner
De har tillgång till Site Pages-biblioteket där de kan fylla i fälten åt dig direkt.

**Ge dem denna information:**
- Sidans namn (t.ex. "SITS.aspx")
- ProcessOwner: [Namnet]
- ProcessManager: [Namnet/Namnen]
- ProcessName: [t.ex. "SITS"]

De kan fylla i det på några sekunder från biblioteket.

---

## Metod 4: Test om fälten finns (för felsökning)

Om du är osäker på om fälten ProcessOwner/ProcessManager finns:

### Steg 1: Klicka Edit på din sida

### Steg 2: Högerklicka var som helst på sidan

### Steg 3: Välj "View Page Source" eller tryck F12

### Steg 4: Sök efter (Ctrl+F)
Sök efter: `ProcessOwner`

**Om du hittar det:** Fältet finns! Använd Metod 2 (URL-trick)
**Om du INTE hittar det:** Fältet är inte skapat än - kontakta IT/Site Owner

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

### När du klickar på Edit längst upp:

```
┌─────────────────────────────────────────────┐
│  SITS - Special IT Services                 │
│  Posted - Share - Edit   ← KLICKA PÅ EDIT  │
└─────────────────────────────────────────────┘
```

### I Edit-mode, leta efter fält under titeln:

**Alternativ A - Fälten syns direkt:**
```
┌─────────────────────────────────────────────┐
│  [Publish] [Save as draft]                  │
│  ──────────────────────────────────────     │
│  SITS - Special IT Services                 │
│                                              │
│  ProcessOwner: [Välj person]     ← FYLL HÄR │
│  ProcessManager: [Välj person]   ← FYLL HÄR │
│  ProcessName: [________]         ← FYLL HÄR │
│  ──────────────────────────────────────     │
│  [Sidinnehåll här...]                        │
└─────────────────────────────────────────────┘
```

**Alternativ B - Fälten finns i "Properties" eller "Page details":**
```
┌─────────────────────────────────────────────┐
│  [Publish] [...] [Properties] ← KLICKA HÄR  │
└─────────────────────────────────────────────┘
```

Då öppnas en panel till höger:
```
┌────────────────────────────┐
│  Properties        [X]     │
│  ─────────────────────────│
│  ProcessOwner: [____]     │  ← FYLL I
│  ProcessManager: [____]   │  ← FYLL I
│  ProcessName: [____]      │  ← FYLL I
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

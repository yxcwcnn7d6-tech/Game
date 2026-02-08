# Digitala AI-Partiet

Sveriges första AI-drivna politiska parti — ett multi-agent system där varje ministerpost
i regeringen representeras av en egen AI-agent med unik personlighet, expertis och politisk prioritering.

## Arkitektur

```
political-ai-party/
├── __main__.py          # Startpunkt
├── pyproject.toml       # Projektconfig
├── core/
│   ├── minister.py      # Basklassen Minister med LLM-integration
│   ├── government.py    # Orkestrator: debatter, omröstningar, krismöten
│   └── cli.py           # Interaktivt CLI
└── agents/
    └── ministers.py      # 12 ministerprofiler med unika personligheter
```

## Ministrar

| Post | Kodnamn | Domän |
|------|---------|-------|
| Statsminister | AI-1 'Ledaren' | Övergripande politik och samordning |
| Finansminister | AI-2 'Räknaren' | Ekonomi, budget, skatter |
| Utrikesminister | AI-3 'Diplomaten' | Utrikespolitik, diplomati |
| Justitieminister | AI-4 'Rättvisaren' | Rättsväsende, lagstiftning |
| Försvarsminister | AI-5 'Väktaren' | Försvar, cybersäkerhet |
| Socialminister | AI-6 'Omtänkaren' | Vård, omsorg, socialpolitik |
| Utbildningsminister | AI-7 'Mentorn' | Skola, forskning, utbildning |
| Miljö- och klimatminister | AI-8 'Gröna' | Klimat, miljö, hållbarhet |
| Näringsminister | AI-9 'Innovatören' | Näringsliv, innovation |
| Arbetsmarknadsminister | AI-10 'Matcharen' | Arbetsmarknad, integration |
| Infrastrukturminister | AI-11 'Byggaren' | Transport, digital infrastruktur |
| Kulturminister | AI-12 'Skaparen' | Kultur, medier, demokrati |

## Installation

```bash
pip install anthropic
```

## Användning

```bash
# Starta interaktivt CLI
python political-ai-party

# Eller direkt
python political-ai-party/__main__.py
```

### Kommandon

| Kommando | Beskrivning |
|----------|-------------|
| `ministrar` | Lista alla ministrar och deras ansvarsområden |
| `fråga <minister> <fråga>` | Ställ en fråga direkt till en minister |
| `auto <fråga>` | Automatisk routing till rätt minister(ar) |
| `debatt <ämne>` | Starta en strukturerad debatt med relevanta ministrar |
| `rösta <förslag>` | Alla ministrar röstar om ett förslag |
| `kris <situation>` | Krismöte — alla ministrar ger input, PM fattar beslut |
| `nollställ` | Rensa alla konversationshistorik |

### Exempel

```
AI-Partiet> debatt Ska Sverige införa 6 timmars arbetsdag?

AI-Partiet> rösta Höja skatten på AI-genererad inkomst med 15%

AI-Partiet> fråga Finansminister Hur finansierar vi en grön omställning?

AI-Partiet> kris Cyberattack mot svenska myndigheter

AI-Partiet> auto Hur ska Sverige hantera bostadskrisen?
```

## Kräver

- Python 3.10+
- `ANTHROPIC_API_KEY` miljövariabel

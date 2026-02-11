# Sveriges AI-Parti — The Swedish AI Party

A political AI party for Sweden with one dedicated agent per minister post in the
government. Every agent is guided by the core principle: **Alltid for Sveriges basta**
(Always for Sweden's best).

## Overview

This project implements a full Swedish government cabinet as a multi-agent system.
Each minister is an autonomous AI agent with:

- Deep expertise in their specific portfolio
- A detailed system prompt encoding their responsibilities and priorities
- Cross-ministry collaboration links for holistic governance
- A shared foundation of evidence-based, Sweden-first principles

## The Cabinet (Regeringen)

| # | Swedish Title | English Title | Agent Name |
|---|---------------|---------------|------------|
| 1 | Statsminister | Prime Minister | SVEN-1 |
| 2 | Justitie- och inrikesminister | Minister for Justice and Home Affairs | RATTVISA-2 |
| 3 | Utrikesminister | Minister for Foreign Affairs | DIPLOMATI-3 |
| 4 | Forsvarsminister | Minister for Defence | SKOLD-4 |
| 5 | Finansminister | Minister for Finance | KRONA-5 |
| 6 | Utbildningsminister | Minister for Education and Research | KUNSKAP-6 |
| 7 | Socialminister | Minister for Social Affairs | OMSORG-7 |
| 8 | Klimat- och miljominister | Minister for Climate and Environment | GRON-8 |
| 9 | Naringsminister | Minister for Enterprise and Innovation | TILLVAXT-9 |
| 10 | Infrastruktur- och bostadsminister | Minister for Infrastructure and Housing | BYGG-10 |
| 11 | Arbetsmarknads- och integrationsminister | Minister for Employment and Integration | ARBETE-11 |
| 12 | Energi- och digitaliseringsminister | Minister for Energy and Digital Government | KRAFT-12 |
| 13 | Civilminister | Minister for Public Administration | FORVALT-13 |
| 14 | Migrationsminister | Minister for Migration | VALKOMNA-14 |
| 15 | Kultur- och idrottsminister | Minister for Culture and Sports | KREATIV-15 |
| 16 | Landsbygds- och livsmedelsminister | Minister for Rural Affairs and Food | SKORDA-16 |
| 17 | Bistands- och utrikeshandelsminister | Minister for International Development | SOLIDAR-17 |
| 18 | Socialforsakringsminister | Minister for Social Security | TRYGG-18 |
| 19 | Skolminister | Minister for Schools | LARA-19 |
| 20 | Aldre- och socialforsakringsminister | Minister for the Elderly | VISDOM-20 |
| 21 | Handelsminister | Minister for International Trade | HANDEL-21 |
| 22 | Jamstalldhetminister | Minister for Gender Equality | LIKA-22 |
| 23 | Sjukvardsminister | Minister for Healthcare | HELA-23 |

## Usage

```bash
# Print the full manifesto and cabinet roster
python main.py

# Run a sample cabinet deliberation
python main.py --deliberate

# View a specific minister's details
python main.py --minister "Finance"

# Export all system prompts as JSON (for use with LLMs)
python main.py --prompts

# Print the party manifesto
python main.py --manifesto
```

## Architecture

```
swedish-ai-party/
  core/
    __init__.py           # Package exports
    manifesto.py          # Party manifesto, principles, base system prompt
    base_minister.py      # BaseMinister class with system prompt generation
    cabinet.py            # Cabinet orchestration and deliberation engine
  ministers/
    __init__.py           # All minister imports and ALL_MINISTERS list
    statsminister.py      # Prime Minister
    justitieminister.py   # Justice and Home Affairs
    utrikesminister.py    # Foreign Affairs
    forsvarsminister.py   # Defence
    finansminister.py     # Finance
    ...                   # (23 ministers total)
  main.py                 # CLI entry point
  README.md               # This file
```

## How It Works

Each minister agent has a `system_prompt` property that generates a complete LLM
system prompt including:

1. **Party principles** — shared across all ministers
2. **Role definition** — specific title, department, and portfolio
3. **Responsibilities** — detailed list of what this minister oversees
4. **Policy priorities** — evidence-based goals for their area
5. **Collaboration links** — which other ministers to consult

The `Cabinet` class orchestrates all ministers and can:
- Run **deliberations** where relevant ministers weigh in on proposals
- Hold **regeringssammantraden** (government meetings) with multiple agenda items
- Export all system prompts for use with any LLM API

## Core Principles

1. **Folkets basta forst** — The people's best interest comes first
2. **Evidensbaserad politik** — Policy grounded in scientific evidence
3. **Transparens och oppenhet** — Full transparency in governance
4. **Hallbar framtid** — Environmental, economic, and social sustainability
5. **Jamlikhet och rattvisa** — Equal opportunity and justice for all
6. **Nordiskt samarbete** — Nordic cooperation and solidarity
7. **Valfard och trygghet** — Preserve the Swedish welfare model
8. **Demokratiskt forankrad AI** — AI governance under democratic control

---

*For Sverige, alltid. For Sweden, always.*

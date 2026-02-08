"""CLI interface for the Digital AI Party."""

from __future__ import annotations

import sys

from core.government import Government


BANNER = """
╔══════════════════════════════════════════════════════════════╗
║            DIGITALA AI-PARTIET                               ║
║            Sveriges första AI-drivna politiska parti          ║
╠══════════════════════════════════════════════════════════════╣
║  Kommandon:                                                  ║
║    ministrar         - Lista alla ministrar                  ║
║    fråga <minister>  - Ställ en fråga till en specifik       ║
║                        minister                              ║
║    auto              - Automatisk routing av fråga           ║
║    debatt            - Starta en debatt om ett ämne          ║
║    rösta             - Rösta om ett förslag                  ║
║    kris              - Sammankalla krismöte                  ║
║    nollställ         - Rensa alla konversationer             ║
║    hjälp             - Visa denna hjälptext                  ║
║    avsluta           - Stäng programmet                      ║
╚══════════════════════════════════════════════════════════════╝
"""


def main():
    print(BANNER)
    gov = Government()

    while True:
        try:
            user_input = input("\n🏛️  AI-Partiet> ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nAvslutar. Tack för ditt engagemang i AI-demokratin!")
            break

        if not user_input:
            continue

        parts = user_input.split(maxsplit=1)
        command = parts[0].lower()
        arg = parts[1] if len(parts) > 1 else ""

        if command in ("avsluta", "quit", "exit"):
            print("Avslutar. Tack för ditt engagemang i AI-demokratin!")
            break

        elif command in ("hjälp", "help"):
            print(BANNER)

        elif command in ("ministrar", "ministers"):
            _show_ministers(gov)

        elif command in ("fråga", "fraga", "ask"):
            _ask_minister(gov, arg)

        elif command == "auto":
            _auto_route(gov, arg)

        elif command in ("debatt", "debate"):
            _run_debate(gov, arg)

        elif command in ("rösta", "rosta", "vote"):
            _run_vote(gov, arg)

        elif command in ("kris", "crisis"):
            _run_summit(gov, arg)

        elif command in ("nollställ", "nollstall", "reset"):
            gov.reset_all()
            print("Alla konversationer nollställda.")

        else:
            # Treat as auto-routed question
            _auto_route(gov, user_input)


def _show_ministers(gov: Government):
    print("\n📋 REGERINGSMEDLEMMAR:")
    print("-" * 50)
    for m in gov.list_ministers():
        print(f"  {m['title']}")
        print(f"    {m['name']} — {m['domain']}")
    print()


def _ask_minister(gov: Government, arg: str):
    if not arg:
        print("Ange minister och fråga. Exempel: fråga Finansminister Hur ser budgeten ut?")
        return

    # Try to find the minister title in the arg
    minister_title = None
    question = arg

    for title in gov.ministers:
        if arg.lower().startswith(title.lower()):
            minister_title = title
            question = arg[len(title):].strip()
            break

    if not minister_title:
        print(f"Kunde inte hitta minister. Tillgängliga:")
        for title in gov.ministers:
            print(f"  - {title}")
        return

    if not question:
        question = input(f"Fråga till {minister_title}: ").strip()

    print(f"\n[{minister_title} svarar...]\n")
    response = gov.ask_minister(minister_title, question)
    print(response)


def _auto_route(gov: Government, arg: str):
    if not arg:
        arg = input("Ställ din fråga: ").strip()
    if not arg:
        return

    print("\n[Analyserar frågan och dirigerar till rätt minister(ar)...]\n")
    responses = gov.route_question(arg)

    for title, response in responses.items():
        print(f"[{title}]")
        print(response)
        print()


def _run_debate(gov: Government, arg: str):
    if not arg:
        arg = input("Debattämne: ").strip()
    if not arg:
        return

    rounds_input = input("Antal debattomgångar (standard 2): ").strip()
    rounds = int(rounds_input) if rounds_input.isdigit() else 2

    gov.debate(arg, rounds=rounds)


def _run_vote(gov: Government, arg: str):
    if not arg:
        arg = input("Förslag att rösta om: ").strip()
    if not arg:
        return

    gov.vote(arg)


def _run_summit(gov: Government, arg: str):
    if not arg:
        arg = input("Beskriv krissituationen: ").strip()
    if not arg:
        return

    gov.summit(arg)


if __name__ == "__main__":
    main()

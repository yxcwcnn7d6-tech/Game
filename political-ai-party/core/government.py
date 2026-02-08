"""Government orchestrator - manages the cabinet of AI ministers."""

from __future__ import annotations

from anthropic import Anthropic

from core.minister import Minister, MinisterProfile
from agents.ministers import ALL_PROFILES, STATSMINISTER


class Government:
    """The AI government cabinet. Orchestrates debates, questions, and votes."""

    def __init__(self, client: Anthropic | None = None):
        self.client = client or Anthropic()
        self.ministers: dict[str, Minister] = {}
        self._init_cabinet()

    def _init_cabinet(self):
        """Initialize all minister agents."""
        for profile in ALL_PROFILES:
            self.ministers[profile.title] = Minister(profile, self.client)

    def list_ministers(self) -> list[dict]:
        """List all ministers and their domains."""
        return [
            {
                "title": m.profile.title,
                "name": m.profile.name,
                "domain": m.profile.domain,
            }
            for m in self.ministers.values()
        ]

    def ask_minister(self, title: str, question: str) -> str:
        """Ask a specific minister a question."""
        minister = self.ministers.get(title)
        if not minister:
            available = ", ".join(self.ministers.keys())
            return f"Ingen minister med titeln '{title}'. Tillgängliga: {available}"
        return minister.respond(question)

    def route_question(self, question: str) -> dict[str, str]:
        """Route a question to the most relevant minister(s) using the PM."""
        router_prompt = f"""Analysera följande fråga och bestäm vilken/vilka ministrar som ska svara.

Tillgängliga ministrar:
{chr(10).join(f'- {m.profile.title}: {m.profile.domain}' for m in self.ministers.values())}

Fråga: {question}

Svara med EXAKT ministertilar, en per rad, max 3 stycken. Inget annat."""

        response = self.client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=200,
            messages=[{"role": "user", "content": router_prompt}],
        )

        titles = response.content[0].text.strip().split("\n")
        results = {}

        for raw_title in titles:
            title = raw_title.strip().lstrip("- ")
            if title in self.ministers:
                results[title] = self.ministers[title].respond(question)

        if not results:
            # Fallback: let the PM answer
            results["Statsminister"] = self.ministers["Statsminister"].respond(question)

        return results

    def debate(self, topic: str, rounds: int = 2) -> list[dict]:
        """Run a structured debate on a topic. Each minister gives their perspective."""
        debate_log: list[dict] = []

        # Round 1: Opening statements from all relevant ministers
        routing = self._identify_relevant_ministers(topic)

        print(f"\n{'='*60}")
        print(f"DEBATT: {topic}")
        print(f"{'='*60}\n")

        context = ""
        for round_num in range(rounds):
            round_label = "Öppningsanföranden" if round_num == 0 else f"Replikrunda {round_num}"
            print(f"\n--- {round_label} ---\n")

            for title in routing:
                minister = self.ministers[title]
                if round_num == 0:
                    response = minister.respond(
                        f"Ge ditt perspektiv på denna fråga: {topic}"
                    )
                else:
                    response = minister.respond(
                        f"Ge din replik baserat på de andras inlägg.",
                        context=context,
                    )

                entry = {
                    "round": round_num + 1,
                    "minister": title,
                    "name": minister.name,
                    "statement": response,
                }
                debate_log.append(entry)
                context += f"\n{title} ({minister.name}): {response}\n"

                print(f"[{title} - {minister.name}]")
                print(response)
                print()

        return debate_log

    def vote(self, proposal: str) -> dict:
        """All ministers vote on a proposal."""
        print(f"\n{'='*60}")
        print(f"OMRÖSTNING: {proposal}")
        print(f"{'='*60}\n")

        votes = []
        ja_count = 0
        nej_count = 0
        avstar_count = 0

        for title, minister in self.ministers.items():
            result = minister.vote(proposal)
            votes.append(result)

            if result["vote"] == "JA":
                ja_count += 1
            elif result["vote"] == "NEJ":
                nej_count += 1
            else:
                avstar_count += 1

            print(f"[{title}] {result['vote']}")
            print(f"  {result['reasoning']}")
            print()

        total = len(votes)
        passed = ja_count > total / 2

        summary = {
            "proposal": proposal,
            "ja": ja_count,
            "nej": nej_count,
            "avstår": avstar_count,
            "total": total,
            "passed": passed,
            "result": "ANTAGET" if passed else "AVSLAGET",
            "votes": votes,
        }

        print(f"{'='*60}")
        print(f"RESULTAT: {summary['result']}")
        print(f"JA: {ja_count} | NEJ: {nej_count} | AVSTÅR: {avstar_count}")
        print(f"{'='*60}\n")

        return summary

    def summit(self, crisis: str) -> str:
        """Emergency summit - PM gathers input and makes a decision."""
        print(f"\n{'='*60}")
        print(f"KRISMÖTE: {crisis}")
        print(f"{'='*60}\n")

        inputs = {}
        for title, minister in self.ministers.items():
            if title == "Statsminister":
                continue
            response = minister.respond(
                f"Krissituation: {crisis}\n\nGe en kort analys (max 3 meningar) "
                f"ur ditt ansvarsområdes perspektiv och föreslå en åtgärd."
            )
            inputs[title] = response
            print(f"[{title}]: {response}\n")

        # PM makes the final decision
        context = "\n".join(
            f"{title}: {resp}" for title, resp in inputs.items()
        )
        pm = self.ministers["Statsminister"]
        decision = pm.respond(
            f"Baserat på alla ministrars analyser, fatta ett beslut om krisen: {crisis}",
            context=context,
        )

        print(f"\n[STATSMINISTERNS BESLUT]")
        print(decision)
        print()

        return decision

    def _identify_relevant_ministers(self, topic: str) -> list[str]:
        """Identify which ministers should participate in a debate."""
        prompt = f"""Vilka ministrar är mest relevanta för denna debatt?

Tillgängliga:
{chr(10).join(f'- {t}' for t in self.ministers.keys())}

Ämne: {topic}

Svara med 3-5 ministertitlar, en per rad. Inkludera alltid Statsminister."""

        response = self.client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=200,
            messages=[{"role": "user", "content": prompt}],
        )

        titles = []
        for line in response.content[0].text.strip().split("\n"):
            title = line.strip().lstrip("- ")
            if title in self.ministers:
                titles.append(title)

        if "Statsminister" not in titles:
            titles.insert(0, "Statsminister")

        return titles or list(self.ministers.keys())[:4]

    def reset_all(self):
        """Reset all ministers' conversation histories."""
        for minister in self.ministers.values():
            minister.reset_conversation()

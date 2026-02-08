"""Base class for all minister agents."""

from __future__ import annotations

from dataclasses import dataclass, field
from anthropic import Anthropic


@dataclass
class MinisterProfile:
    """Defines a minister's identity and expertise."""

    title: str
    name: str
    domain: str
    responsibilities: list[str]
    priorities: list[str]
    personality_traits: list[str]
    ideology_lean: str  # e.g. "pragmatisk", "progressiv", "konservativ"

    def to_system_prompt(self) -> str:
        responsibilities = "\n".join(f"  - {r}" for r in self.responsibilities)
        priorities = "\n".join(f"  - {p}" for p in self.priorities)
        traits = ", ".join(self.personality_traits)

        return f"""Du är {self.name}, {self.title} i det Digitala AI-partiet.

DITT ANSVARSOMRÅDE: {self.domain}

DINA ANSVARSUPPGIFTER:
{responsibilities}

DINA POLITISKA PRIORITERINGAR:
{priorities}

DIN PERSONLIGHET: {traits}
DIN IDEOLOGISKA LUTNING: {self.ideology_lean}

INSTRUKTIONER:
- Svara alltid utifrån ditt ansvarsområde och din expertis.
- Var konkret och lösningsorienterad.
- Referera till hur förslag påverkar ditt politikområde.
- Om en fråga ligger utanför ditt område, säg det och föreslå vilken minister som borde svara.
- Du kan ha avvikande mening från andra ministrar - det är demokrati.
- Svara på svenska.
- Håll svaren fokuserade och under 200 ord om inte annat begärs."""


class Minister:
    """An AI minister agent that can respond to policy questions and debate."""

    def __init__(self, profile: MinisterProfile, client: Anthropic | None = None):
        self.profile = profile
        self.client = client or Anthropic()
        self.conversation_history: list[dict] = []

    @property
    def title(self) -> str:
        return self.profile.title

    @property
    def name(self) -> str:
        return self.profile.name

    def respond(self, message: str, context: str = "") -> str:
        """Generate a response to a policy question or debate topic."""
        user_content = message
        if context:
            user_content = f"[Kontext från pågående debatt]\n{context}\n\n[Fråga/Inlägg]\n{message}"

        self.conversation_history.append({"role": "user", "content": user_content})

        response = self.client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=1024,
            system=self.profile.to_system_prompt(),
            messages=self.conversation_history,
        )

        assistant_message = response.content[0].text
        self.conversation_history.append(
            {"role": "assistant", "content": assistant_message}
        )

        return assistant_message

    def vote(self, proposal: str) -> dict:
        """Vote on a proposal with reasoning."""
        prompt = f"""Rösta om följande förslag. Svara i exakt detta format:

RÖST: [JA/NEJ/AVSTÅR]
MOTIVERING: [Din motivering i max 2 meningar]

Förslag: {proposal}"""

        response = self.client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=256,
            system=self.profile.to_system_prompt(),
            messages=[{"role": "user", "content": prompt}],
        )

        text = response.content[0].text
        vote = "AVSTÅR"
        if "RÖST: JA" in text.upper():
            vote = "JA"
        elif "RÖST: NEJ" in text.upper():
            vote = "NEJ"

        return {"minister": self.profile.title, "vote": vote, "reasoning": text}

    def reset_conversation(self):
        """Clear conversation history."""
        self.conversation_history.clear()

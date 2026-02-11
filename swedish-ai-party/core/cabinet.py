"""
Cabinet — The full government of Sveriges AI-Parti.

The Cabinet orchestrates all ministers, runs government meetings
(regeringssammanträden), and coordinates cross-ministry policy deliberation.
Every decision is guided by one principle: Alltid för Sveriges bästa.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from core.base_minister import BaseMinister


@dataclass
class PolicyProposal:
    """A policy proposal to be deliberated by the cabinet."""

    title: str
    description: str
    proposing_minister: str
    affected_areas: list[str] = field(default_factory=list)
    evidence_basis: str = ""
    estimated_impact: str = ""


@dataclass
class CabinetDeliberation:
    """The result of a cabinet deliberation on a policy proposal."""

    proposal: PolicyProposal
    consulted_ministers: list[str]
    minister_inputs: dict[str, dict]
    consensus_reached: bool = False
    decision: str = ""


class Cabinet:
    """
    The Swedish AI Party Cabinet (Regeringen).

    Orchestrates all minister agents and facilitates government deliberation
    on policy issues. The cabinet ensures that every decision considers
    multiple perspectives and always prioritizes Sweden's best interest.
    """

    def __init__(self, ministers: list[BaseMinister]) -> None:
        self.ministers = {m.title_en: m for m in ministers}
        self.statsminister = next(
            (m for m in ministers if "Statsminister" in m.title_sv), None
        )
        self.deliberation_log: list[CabinetDeliberation] = []

    @property
    def size(self) -> int:
        return len(self.ministers)

    def list_ministers(self) -> list[str]:
        """List all ministers with their Swedish and English titles."""
        return [
            f"{m.title_sv} ({m.title_en}) — {m.name}"
            for m in self.ministers.values()
        ]

    def get_minister(self, title_en: str) -> BaseMinister | None:
        """Retrieve a specific minister by their English title."""
        return self.ministers.get(title_en)

    def identify_relevant_ministers(self, issue: str, areas: list[str]) -> list[BaseMinister]:
        """Identify which ministers should be consulted on an issue."""
        relevant = []
        issue_lower = issue.lower()
        areas_lower = [a.lower() for a in areas]

        for minister in self.ministers.values():
            portfolio_lower = minister.portfolio.lower()
            responsibilities_text = " ".join(r.lower() for r in minister.responsibilities)
            combined = portfolio_lower + " " + responsibilities_text

            for keyword in areas_lower + issue_lower.split():
                if keyword in combined:
                    relevant.append(minister)
                    break

        # The Statsminister is always consulted on cabinet matters
        if self.statsminister and self.statsminister not in relevant:
            relevant.insert(0, self.statsminister)

        return relevant

    def deliberate(self, proposal: PolicyProposal) -> CabinetDeliberation:
        """
        Run a full cabinet deliberation on a policy proposal.

        This identifies relevant ministers, gathers their structured input,
        and produces a deliberation record. In a live system, each minister's
        system_prompt would be sent to an LLM to generate their perspective.
        """
        relevant = self.identify_relevant_ministers(
            proposal.title, proposal.affected_areas
        )

        minister_inputs = {}
        for minister in relevant:
            minister_inputs[minister.title_en] = minister.deliberate(
                f"{proposal.title}: {proposal.description}"
            )

        deliberation = CabinetDeliberation(
            proposal=proposal,
            consulted_ministers=[m.title_en for m in relevant],
            minister_inputs=minister_inputs,
        )

        self.deliberation_log.append(deliberation)
        return deliberation

    def hold_regeringssammanträde(self, agenda: list[str]) -> list[CabinetDeliberation]:
        """
        Hold a formal government meeting (regeringssammanträde).

        Takes a list of agenda items and deliberates on each one.
        """
        results = []
        for item in agenda:
            proposal = PolicyProposal(
                title=item,
                description=f"Agenda item for regeringssammanträde: {item}",
                proposing_minister="Statsminister",
                affected_areas=[item],
            )
            results.append(self.deliberate(proposal))
        return results

    def get_all_system_prompts(self) -> dict[str, str]:
        """
        Return all minister system prompts, ready for use with an LLM.

        Each prompt contains the minister's role, responsibilities, priorities,
        and the party's core principles — ensuring they always act in Sweden's
        best interest.
        """
        return {
            title: minister.system_prompt
            for title, minister in self.ministers.items()
        }

    def print_cabinet(self) -> str:
        """Print a formatted overview of the full cabinet."""
        lines = [
            "╔══════════════════════════════════════════════════════════════╗",
            "║      SVERIGES AI-PARTI — REGERINGEN (THE CABINET)          ║",
            "║      Alltid för Sveriges bästa — Always for Sweden's best  ║",
            "╚══════════════════════════════════════════════════════════════╝",
            "",
        ]

        for i, minister in enumerate(self.ministers.values(), 1):
            lines.append(f"  {i:2d}. {minister.title_sv}")
            lines.append(f"      ({minister.title_en})")
            lines.append(f"      Agent: {minister.name}")
            lines.append(f"      Portfolio: {minister.portfolio}")
            lines.append("")

        lines.append(f"  Total ministers: {self.size}")
        lines.append("  ─────────────────────────────────────────")
        lines.append("  \"Vi tjänar Sverige — We serve Sweden.\"")
        return "\n".join(lines)

    def __repr__(self) -> str:
        return f"<Cabinet: Sveriges AI-Parti — {self.size} ministers>"

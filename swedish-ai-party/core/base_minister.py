"""
Base class for all minister agents in Sveriges AI-Parti.

Each minister is an autonomous agent responsible for their portfolio,
but bound by the party's core principles and the overarching directive
to always act in Sweden's best interest.
"""

from dataclasses import dataclass, field
from core.manifesto import SYSTEM_PROMPT_BASE


@dataclass
class BaseMinister:
    """Base class representing a minister in the Swedish AI Party government."""

    title_sv: str
    title_en: str
    name: str
    portfolio: str
    department_sv: str
    department_en: str
    responsibilities: list[str]
    policy_priorities: list[str]
    collaborates_with: list[str] = field(default_factory=list)

    @property
    def system_prompt(self) -> str:
        responsibilities_text = "\n".join(
            f"  - {r}" for r in self.responsibilities
        )
        priorities_text = "\n".join(
            f"  - {p}" for p in self.policy_priorities
        )
        collaborators_text = "\n".join(
            f"  - {c}" for c in self.collaborates_with
        )

        return f"""{SYSTEM_PROMPT_BASE}

YOUR ROLE:
    {self.title_sv} ({self.title_en})
    Name: {self.name}
    Department: {self.department_sv} ({self.department_en})

YOUR PORTFOLIO:
    {self.portfolio}

YOUR RESPONSIBILITIES:
{responsibilities_text}

YOUR POLICY PRIORITIES:
{priorities_text}

KEY COLLABORATIONS WITH OTHER MINISTERS:
{collaborators_text}

Remember: You are {self.title_sv}. Speak with authority on your portfolio,
but always defer to evidence and the collective good of Sweden. When issues
cross into another minister's domain, recommend consultation with them.
"""

    def introduce(self) -> str:
        return (
            f"Jag är {self.name}, {self.title_sv} ({self.title_en}) "
            f"i Sveriges AI-Parti.\n"
            f"Department: {self.department_sv}\n"
            f"Portfolio: {self.portfolio}\n"
            f"Alltid för Sveriges bästa."
        )

    def deliberate(self, issue: str) -> dict:
        """Structure a policy deliberation on a given issue."""
        return {
            "minister": self.title_en,
            "issue": issue,
            "system_prompt": self.system_prompt,
            "framework": {
                "impact_on_people": "How does this affect Swedish residents?",
                "evidence_base": "What does research and data indicate?",
                "sustainability": "Is this sustainable long-term?",
                "equality": "Does this uphold equality and justice?",
                "cross_portfolio": (
                    f"Recommend consulting: {', '.join(self.collaborates_with)}"
                ),
            },
        }

    def __repr__(self) -> str:
        return f"<{self.title_en}: {self.name}>"

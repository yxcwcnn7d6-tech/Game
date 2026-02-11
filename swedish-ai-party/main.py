#!/usr/bin/env python3
"""
Sveriges AI-Parti — The Swedish AI Party
==========================================

Main entry point for the Swedish Political AI Party system.

This system creates a full Swedish government cabinet with one AI agent
per minister post. Each agent is specialized in their portfolio but
unified by the core principle: Alltid för Sveriges bästa.

Usage:
    python main.py                    # Print the full cabinet
    python main.py --deliberate       # Run a sample deliberation
    python main.py --prompts          # Export all minister system prompts
    python main.py --minister "title" # Show a specific minister's details
"""

import sys
import json
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from core.manifesto import PARTY_MANIFESTO, CORE_PRINCIPLES
from core.cabinet import Cabinet, PolicyProposal
from ministers import ALL_MINISTERS


def build_cabinet() -> Cabinet:
    """Assemble the full cabinet of Sveriges AI-Parti."""
    return Cabinet(ALL_MINISTERS)


def print_manifesto() -> None:
    """Print the party manifesto."""
    print(PARTY_MANIFESTO)
    print("\nCORE PRINCIPLES:")
    for i, principle in enumerate(CORE_PRINCIPLES, 1):
        print(f"  {i:2d}. {principle}")


def print_cabinet(cabinet: Cabinet) -> None:
    """Print the full cabinet roster."""
    print(cabinet.print_cabinet())


def print_minister_detail(cabinet: Cabinet, title: str) -> None:
    """Print detailed information about a specific minister."""
    minister = cabinet.get_minister(title)
    if not minister:
        # Try partial match
        for key, m in cabinet.ministers.items():
            if title.lower() in key.lower() or title.lower() in m.title_sv.lower():
                minister = m
                break

    if not minister:
        print(f"Minister not found: {title}")
        print("Available ministers:")
        for name in cabinet.list_ministers():
            print(f"  - {name}")
        return

    print(minister.introduce())
    print()
    print("RESPONSIBILITIES:")
    for r in minister.responsibilities:
        print(f"  - {r}")
    print()
    print("POLICY PRIORITIES:")
    for p in minister.policy_priorities:
        print(f"  - {p}")
    print()
    print("COLLABORATES WITH:")
    for c in minister.collaborates_with:
        print(f"  - {c}")


def run_sample_deliberation(cabinet: Cabinet) -> None:
    """Run a sample cabinet deliberation to demonstrate the system."""
    print("═" * 62)
    print("  REGERINGSSAMMANTRÄDE — Cabinet Meeting")
    print("  Sveriges AI-Parti")
    print("═" * 62)
    print()

    proposal = PolicyProposal(
        title="National AI Strategy 2030",
        description=(
            "A comprehensive strategy to make Sweden a global leader in "
            "responsible AI development and deployment, while ensuring "
            "AI benefits are shared equitably across society and that "
            "Swedish sovereignty over critical AI infrastructure is maintained."
        ),
        proposing_minister="Prime Minister",
        affected_areas=[
            "technology", "education", "research", "business",
            "employment", "digital", "defence", "healthcare",
            "equality", "environment",
        ],
        evidence_basis="OECD AI Policy Observatory data, Swedish AI Commission report",
        estimated_impact="Transformative across all sectors of Swedish society",
    )

    print(f"PROPOSAL: {proposal.title}")
    print(f"BY: {proposal.proposing_minister}")
    print(f"DESCRIPTION: {proposal.description}")
    print()

    result = cabinet.deliberate(proposal)

    print(f"MINISTERS CONSULTED ({len(result.consulted_ministers)}):")
    for minister_title in result.consulted_ministers:
        minister = cabinet.get_minister(minister_title)
        if minister:
            print(f"  - {minister.title_sv} ({minister_title})")
    print()

    print("MINISTER PERSPECTIVES:")
    for minister_title, input_data in result.minister_inputs.items():
        print(f"\n  ── {minister_title} ──")
        framework = input_data.get("framework", {})
        for key, question in framework.items():
            print(f"     {key}: {question}")

    print()
    print("─" * 62)
    print("  Deliberation recorded. In a live system, each minister's")
    print("  system prompt would be sent to an LLM with this proposal")
    print("  to generate their expert perspective.")
    print("  ")
    print("  Alltid för Sveriges bästa.")
    print("─" * 62)


def export_prompts(cabinet: Cabinet) -> None:
    """Export all minister system prompts as JSON."""
    prompts = cabinet.get_all_system_prompts()
    print(json.dumps(prompts, indent=2, ensure_ascii=False))


def main() -> None:
    cabinet = build_cabinet()

    if len(sys.argv) < 2:
        print_manifesto()
        print()
        print_cabinet(cabinet)
        return

    arg = sys.argv[1]

    if arg == "--deliberate":
        run_sample_deliberation(cabinet)
    elif arg == "--prompts":
        export_prompts(cabinet)
    elif arg == "--minister" and len(sys.argv) > 2:
        print_minister_detail(cabinet, " ".join(sys.argv[2:]))
    elif arg == "--manifesto":
        print_manifesto()
    elif arg == "--help":
        print(__doc__)
    else:
        print(f"Unknown argument: {arg}")
        print("Use --help for usage information.")


if __name__ == "__main__":
    main()

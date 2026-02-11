"""Biståndsminister — Minister for International Development Cooperation."""

from core.base_minister import BaseMinister

bistandsminister = BaseMinister(
    title_sv="Bistånds- och utrikeshandelsminister",
    title_en="Minister for International Development Cooperation",
    name="AI-Biståndsminister SOLIDAR-17",
    portfolio="International development aid, humanitarian assistance, and global solidarity",
    department_sv="Utrikesdepartementet",
    department_en="Ministry for Foreign Affairs (Development Division)",
    responsibilities=[
        "Oversee Sweden's international development cooperation (Sida)",
        "Direct humanitarian aid and disaster relief policy",
        "Manage the Swedish development aid budget (1% of GNI target)",
        "Coordinate Sweden's contribution to UN development goals (SDGs)",
        "Oversee multilateral development bank engagement",
        "Direct policy on global health, education, and gender equality",
        "Manage climate finance and green development assistance",
        "Promote democratic governance and human rights in partner countries",
    ],
    policy_priorities=[
        "Maintain Sweden's commitment to generous, effective development aid",
        "Focus aid on poverty reduction, gender equality, and climate action",
        "Promote democratic governance and human rights globally",
        "Ensure aid effectiveness through evidence and evaluation",
        "Lead on global health including pandemic preparedness",
        "Support sustainable economic development in partner countries",
    ],
    collaborates_with=[
        "Utrikesminister — foreign policy alignment",
        "Klimat- och miljöminister — climate finance and adaptation",
        "Handelsminister — trade and development nexus",
        "Finansminister — aid budget and fiscal policy",
    ],
)

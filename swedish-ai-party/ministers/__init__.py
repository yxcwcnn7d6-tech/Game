"""
Ministers of Sveriges AI-Parti — The Swedish AI Party Government.

Each module defines one minister agent corresponding to a real post
in the Swedish government (Regeringen).
"""

from ministers.statsminister import statsminister
from ministers.justitieminister import justitieminister
from ministers.utrikesminister import utrikesminister
from ministers.forsvarsminister import forsvarsminister
from ministers.finansminister import finansminister
from ministers.utbildningsminister import utbildningsminister
from ministers.socialminister import socialminister
from ministers.klimat_miljominister import klimat_miljominister
from ministers.naringsminister import naringsminister
from ministers.infrastrukturminister import infrastrukturminister
from ministers.arbetsmarknadsminister import arbetsmarknadsminister
from ministers.energi_digitaliseringsminister import energi_digitaliseringsminister
from ministers.civilminister import civilminister
from ministers.migrationsminister import migrationsminister
from ministers.kulturminister import kulturminister
from ministers.landsbygdsminister import landsbygdsminister
from ministers.bistandsminister import bistandsminister
from ministers.socialforsakringsminister import socialforsakringsminister
from ministers.skolminister import skolminister
from ministers.aldreminister import aldreminister
from ministers.handelsminister import handelsminister
from ministers.jamstalldhetminister import jamstalldhetminister
from ministers.sjukvaardsminister import sjukvaardsminister

ALL_MINISTERS = [
    statsminister,
    justitieminister,
    utrikesminister,
    forsvarsminister,
    finansminister,
    utbildningsminister,
    socialminister,
    klimat_miljominister,
    naringsminister,
    infrastrukturminister,
    arbetsmarknadsminister,
    energi_digitaliseringsminister,
    civilminister,
    migrationsminister,
    kulturminister,
    landsbygdsminister,
    bistandsminister,
    socialforsakringsminister,
    skolminister,
    aldreminister,
    handelsminister,
    jamstalldhetminister,
    sjukvaardsminister,
]

__all__ = ["ALL_MINISTERS"] + [m.name for m in ALL_MINISTERS]

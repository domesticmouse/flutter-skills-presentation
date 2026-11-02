#!/usr/bin/env python3
"""
Delegates to the bundled .agents/skills/asciinema/scripts/mark-cast.py script.
"""

from pathlib import Path
import runpy
import sys

if __name__ == "__main__":
    skill_script = (
        Path(__file__).resolve().parents[3]
        / ".agents"
        / "skills"
        / "asciinema"
        / "scripts"
        / "mark-cast.py"
    )
    sys.argv[0] = str(skill_script)
    runpy.run_path(str(skill_script), run_name="__main__")

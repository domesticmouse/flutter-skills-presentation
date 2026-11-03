#!/usr/bin/env python3
"""
Delegates to the bundled .agents/skills/asciinema/scripts/mark-cast.py script.
"""

import runpy
import sys
from pathlib import Path

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

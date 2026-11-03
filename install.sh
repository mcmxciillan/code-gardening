#!/usr/bin/env bash
set -e

echo "🌱 Installing Code Gardening Skills..."

# Target skill directories for Antigravity / Gemini CLI / Claude Code
TARGET_DIR="${HOME}/.gemini/config/skills"
mkdir -p "${TARGET_DIR}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for skill in greenfield-architecture deforestation bushog bonsai seed-catalog survey tidy; do
  if [ -d "${SCRIPT_DIR}/skills/${skill}" ]; then
    echo "  -> Installing skill: ${skill}..."
    mkdir -p "${TARGET_DIR}/${skill}"
    cp -r "${SCRIPT_DIR}/skills/${skill}/"* "${TARGET_DIR}/${skill}/"
  fi
done

echo "✅ All Code Gardening skills installed successfully to ${TARGET_DIR}!"
echo ""
echo "Available Skills in your Agent Environment:"
echo "  🌿 greenfield-architecture : Upfront discovery & Day-1 deep module design"
echo "  🌲 /deforestation          : Multi-agent legacy codebase de-spaghettiing"
echo "  🚜 /bushog                 : 1..N subagent bug batch clearing & test anchors"
echo "  🪴 /bonsai                 : Surgical code pruning, 12->3 line compression & 1MB->10KB dependency diet"
echo "  📖 /seed-catalog           : Shared vocabulary (GLOSSARY.md), semantic renames & core docs"
echo "  🔍 /survey                 : PR generator & 0-trust adversarial code reviewer"
echo "  🧹 /tidy                   : Release merge, issue closure & deploy verification"

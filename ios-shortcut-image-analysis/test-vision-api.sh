#!/bin/bash
# =============================================================================
# test-vision-api.sh
#
# Testskript for att validera Anthropic Vision API-anropet innan du bygger
# iOS Shortcuten. Kör detta lokalt för att verifiera att din API-nyckel
# fungerar och att bildanalysen ger rätt typ av svar.
#
# Användning:
#   export ANTHROPIC_API_KEY="din-api-nyckel"
#   ./test-vision-api.sh bild.jpg "Beskriv vad du ser i bilden"
#   ./test-vision-api.sh bild.png "Vilka ingredienser finns i denna maträtt?"
#
# Stödda format: JPEG, PNG, GIF, WebP
# =============================================================================

set -euo pipefail

# --- Konfiguration ---
API_URL="https://api.anthropic.com/v1/messages"
MODEL="claude-sonnet-4-20250514"
MAX_TOKENS=1024

# --- Validera input ---
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    echo "FEL: Sätt ANTHROPIC_API_KEY först:"
    echo "  export ANTHROPIC_API_KEY=\"din-api-nyckel\""
    exit 1
fi

if [ $# -lt 1 ]; then
    echo "Användning: $0 <bildfil> [prompt]"
    echo "Exempel:    $0 foto.jpg \"Vad visar denna bild?\""
    exit 1
fi

IMAGE_FILE="$1"
PROMPT="${2:-Analysera denna bild och beskriv vad du ser.}"

if [ ! -f "$IMAGE_FILE" ]; then
    echo "FEL: Filen '$IMAGE_FILE' hittades inte."
    exit 1
fi

# --- Detektera MIME-typ ---
case "${IMAGE_FILE,,}" in
    *.jpg|*.jpeg) MEDIA_TYPE="image/jpeg" ;;
    *.png)        MEDIA_TYPE="image/png" ;;
    *.gif)        MEDIA_TYPE="image/gif" ;;
    *.webp)       MEDIA_TYPE="image/webp" ;;
    *)
        echo "FEL: Format stöds ej. Använd JPEG, PNG, GIF eller WebP."
        exit 1
        ;;
esac

echo "Bild:   $IMAGE_FILE ($MEDIA_TYPE)"
echo "Prompt: $PROMPT"
echo "Modell: $MODEL"
echo "---"

# --- Base64-koda bilden ---
BASE64_IMAGE=$(base64 -w 0 "$IMAGE_FILE" 2>/dev/null || base64 -i "$IMAGE_FILE" 2>/dev/null)

# --- Bygg JSON-payload ---
JSON_PAYLOAD=$(cat <<ENDJSON
{
    "model": "${MODEL}",
    "max_tokens": ${MAX_TOKENS},
    "messages": [
        {
            "role": "user",
            "content": [
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "${MEDIA_TYPE}",
                        "data": "${BASE64_IMAGE}"
                    }
                },
                {
                    "type": "text",
                    "text": "${PROMPT}"
                }
            ]
        }
    ]
}
ENDJSON
)

# --- Skicka API-anrop ---
echo "Skickar till Anthropic API..."
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
    "${API_URL}" \
    -H "Content-Type: application/json" \
    -H "x-api-key: ${ANTHROPIC_API_KEY}" \
    -H "anthropic-version: 2023-06-01" \
    -d "${JSON_PAYLOAD}")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" != "200" ]; then
    echo "FEL: API svarade med HTTP $HTTP_CODE"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
    exit 1
fi

# --- Extrahera och visa svaret ---
echo "=== SVAR ==="
echo "$BODY" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for block in data.get('content', []):
    if block.get('type') == 'text':
        print(block['text'])
" 2>/dev/null || echo "$BODY"

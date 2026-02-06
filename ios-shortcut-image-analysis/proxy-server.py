"""
proxy-server.py - Enkel proxy-server for iOS Shortcut bildanalys.

Kör denna server lokalt eller på en VPS om du inte vill lagra din
Anthropic API-nyckel direkt i iOS Shortcuten. Shortcuten skickar
bilden till denna server som i sin tur pratar med Anthropic.

Användning:
    export ANTHROPIC_API_KEY="din-api-nyckel"
    python3 proxy-server.py                          # port 8080
    python3 proxy-server.py --port 9000              # valfri port
    python3 proxy-server.py --auth-token hemligt123  # med autentisering

iOS Shortcut pekar sedan mot:
    http://din-server:8080/analyze

Krav:
    pip install anthropic
"""

import argparse
import json
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler

try:
    import anthropic
except ImportError:
    print("Installera anthropic-paketet: pip install anthropic")
    sys.exit(1)


class AnalyzeHandler(BaseHTTPRequestHandler):
    """Hanterar POST /analyze med bild och prompt."""

    def do_POST(self):
        if self.path != "/analyze":
            self._respond(404, {"error": "Inte hittad. Använd POST /analyze"})
            return

        # Valfri token-autentisering
        if self.server.auth_token:
            auth = self.headers.get("Authorization", "")
            expected = f"Bearer {self.server.auth_token}"
            if auth != expected:
                self._respond(401, {"error": "Ogiltig eller saknad Authorization-header"})
                return

        # Läs request body
        content_length = int(self.headers.get("Content-Length", 0))
        if content_length == 0:
            self._respond(400, {"error": "Tom request body"})
            return

        body = self.rfile.read(content_length)

        try:
            data = json.loads(body)
        except json.JSONDecodeError:
            self._respond(400, {"error": "Ogiltig JSON"})
            return

        # Validera fält
        image_base64 = data.get("image")
        prompt = data.get("prompt", "Beskriv vad du ser i bilden.")
        media_type = data.get("media_type", "image/jpeg")
        model = data.get("model", "claude-sonnet-4-20250514")
        max_tokens = data.get("max_tokens", 1024)

        if not image_base64:
            self._respond(400, {"error": "Fältet 'image' (base64) saknas"})
            return

        # Anropa Anthropic API
        try:
            client = anthropic.Anthropic()  # Använder ANTHROPIC_API_KEY env
            message = client.messages.create(
                model=model,
                max_tokens=max_tokens,
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "image",
                                "source": {
                                    "type": "base64",
                                    "media_type": media_type,
                                    "data": image_base64,
                                },
                            },
                            {
                                "type": "text",
                                "text": prompt,
                            },
                        ],
                    }
                ],
            )

            # Extrahera textsvar
            result_text = ""
            for block in message.content:
                if block.type == "text":
                    result_text += block.text

            self._respond(200, {
                "result": result_text,
                "model": message.model,
                "usage": {
                    "input_tokens": message.usage.input_tokens,
                    "output_tokens": message.usage.output_tokens,
                },
            })

        except anthropic.AuthenticationError:
            self._respond(401, {"error": "Ogiltig Anthropic API-nyckel"})
        except anthropic.RateLimitError:
            self._respond(429, {"error": "Rate limit nådd, försök igen om en stund"})
        except anthropic.APIError as e:
            self._respond(502, {"error": f"Anthropic API-fel: {str(e)}"})

    def do_GET(self):
        """Hälsosida för att verifiera att servern körs."""
        if self.path == "/health":
            self._respond(200, {"status": "ok"})
        else:
            self._respond(200, {
                "service": "iOS Shortcut Bildanalys Proxy",
                "usage": "POST /analyze med JSON: {\"image\": \"base64...\", \"prompt\": \"...\"}",
            })

    def _respond(self, status, data):
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False).encode("utf-8"))

    def log_message(self, format, *args):
        """Enklare loggning."""
        print(f"[{self.log_date_time_string()}] {args[0]}")


def main():
    parser = argparse.ArgumentParser(description="Proxy-server för iOS bildanalys")
    parser.add_argument("--port", type=int, default=8080, help="Port (standard: 8080)")
    parser.add_argument("--auth-token", type=str, default=None,
                        help="Valfri Bearer-token för autentisering")
    args = parser.parse_args()

    import os
    if not os.environ.get("ANTHROPIC_API_KEY"):
        print("VARNING: ANTHROPIC_API_KEY är inte satt!")
        print("  export ANTHROPIC_API_KEY=\"din-api-nyckel\"")
        sys.exit(1)

    server = HTTPServer(("0.0.0.0", args.port), AnalyzeHandler)
    server.auth_token = args.auth_token

    token_info = f" (auth-token: {args.auth_token[:4]}...)" if args.auth_token else ""
    print(f"Proxy-server startad på port {args.port}{token_info}")
    print(f"Endpoint: http://0.0.0.0:{args.port}/analyze")
    print("Tryck Ctrl+C för att stoppa.")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStoppar servern.")
        server.server_close()


if __name__ == "__main__":
    main()

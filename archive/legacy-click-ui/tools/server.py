import json
from http.server import HTTPServer, SimpleHTTPRequestHandler
import urllib.request
import urllib.error
import base64

class Handler(SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path == "/proxy":
            try:
                # ---- Read incoming expression ----
                length = int(self.headers["Content-Length"])
                expr = self.rfile.read(length).decode().strip()

                print("\n==== Incoming Expression ====")
                print(expr)
                print("=============================\n")

                # ---- Encode for VM ----
                expr_b64 = base64.b64encode(expr.encode()).decode()

                payload = json.dumps({
                    "jsonrpc": "2.0",
                    "id": 1,
                    "method": "abci_query",
                    "params": {
                        "path": "vm/qeval",
                        "data": expr_b64,
                        "prove": False
                    }
                }).encode()

                print("Sending payload to VM...")
                print(payload)

                # ---- Send request to gnodev ----
                req = urllib.request.Request(
                    "http://127.0.0.1:26657",
                    data=payload,
                    method="POST",
                    headers={"Content-Type": "application/json"}
                )

                with urllib.request.urlopen(req) as resp:
                    result_bytes = resp.read()

                print("\n==== Raw VM Response ====")
                print(result_bytes)
                print("=========================\n")

                # ---- Parse JSON safely ----
                try:
                    result_json = json.loads(result_bytes)
                except Exception as parse_error:
                    print("JSON parsing failed!")
                    print(parse_error)
                    raise parse_error

                # ---- Return success ----
                self.send_response(200)
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps(result_json).encode())

            except Exception as e:
                # ---- Catch ALL errors here ----
                print("\n!!!! ERROR IN PROXY !!!!")
                print(e)
                print("========================\n")

                self.send_response(500)
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode())

        else:
            self.send_error(404, "Not found")

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()


server = HTTPServer(("127.0.0.1", 3000), Handler)
print("Server running at http://localhost:3000")
server.serve_forever()

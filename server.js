const http = require("http");
const fs = require("fs");
const path = require("path");

const HOST = "localhost";
const PORT = 3000;
const GNODEV_URL = "http://127.0.0.1:26657";
const ROOT_DIR = __dirname;

const MIME_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".txt": "text/plain; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".svg": "image/svg+xml",
};

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Access-Control-Allow-Origin": "*",
  });
  res.end(JSON.stringify(payload));
}

function collectBody(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.setEncoding("utf8");

    req.on("data", (chunk) => {
      body += chunk;
    });

    req.on("end", () => resolve(body));
    req.on("error", reject);
  });
}

function serveFile(req, res) {
  const requestPath = req.url === "/" ? "/index.html" : req.url;
  const filePath = path.normalize(path.join(ROOT_DIR, decodeURIComponent(requestPath)));

  if (!filePath.startsWith(ROOT_DIR)) {
    res.writeHead(403, { "Content-Type": "text/plain; charset=utf-8" });
    res.end("Forbidden");
    return;
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      const statusCode = err.code === "ENOENT" ? 404 : 500;
      res.writeHead(statusCode, { "Content-Type": "text/plain; charset=utf-8" });
      res.end(statusCode === 404 ? "Not found" : "Internal server error");
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    res.writeHead(200, {
      "Content-Type": MIME_TYPES[ext] || "application/octet-stream",
      "Cache-Control": "no-store",
    });
    res.end(data);
  });
}

async function handleProxy(req, res) {
  try {
    const expr = (await collectBody(req)).trim();

    console.log("\n==== Incoming Expression ====");
    console.log(expr);
    console.log("=============================\n");

    const payload = JSON.stringify({
      jsonrpc: "2.0",
      id: 1,
      method: "abci_query",
      params: {
        path: "vm/qeval",
        data: Buffer.from(expr, "utf8").toString("base64"),
        prove: false,
      },
    });

    console.log("Sending payload to VM...");
    console.log(payload);

    const vmResponse = await fetch(GNODEV_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: payload,
    });

    const responseText = await vmResponse.text();

    console.log("\n==== Raw VM Response ====");
    console.log(responseText);
    console.log("=========================\n");

    let resultJson;
    try {
      resultJson = JSON.parse(responseText);
    } catch (parseError) {
      console.log("JSON parsing failed!");
      console.log(parseError);
      throw parseError;
    }

    sendJson(res, vmResponse.ok ? 200 : 500, resultJson);
  } catch (error) {
    console.log("\n!!!! ERROR IN PROXY !!!!");
    console.log(error);
    console.log("========================\n");

    sendJson(res, 500, { error: error.message || String(error) });
  }
}

const server = http.createServer(async (req, res) => {
  if (req.method === "OPTIONS") {
    res.writeHead(200, {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    });
    res.end();
    return;
  }

  if (req.method === "POST" && req.url === "/proxy") {
    await handleProxy(req, res);
    return;
  }

  if (req.method === "GET") {
    serveFile(req, res);
    return;
  }

  res.writeHead(405, { "Content-Type": "text/plain; charset=utf-8" });
  res.end("Method not allowed");
});

server.listen(PORT, HOST, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});

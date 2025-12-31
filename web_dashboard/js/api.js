const API_BASE = "http://localhost:5000";

async function apiGet(url) {
  const res = await fetch(`${API_BASE}${url}`);
  return res.json();
}

async function apiPost(url, body) {
  const res = await fetch(`${API_BASE}${url}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  });
  return res.json();
}

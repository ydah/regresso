const listEl = document.getElementById("results-list");
const refreshBtn = document.getElementById("refresh");
const detailTitle = document.getElementById("detail-title");
const detailMeta = document.getElementById("detail-meta");
const detailSummary = document.getElementById("detail-summary");
const detailDiffs = document.getElementById("detail-diffs");
const filterPath = document.getElementById("filter-path");
const filterType = document.getElementById("filter-type");
const statTotal = document.getElementById("stat-total");
const statPassed = document.getElementById("stat-passed");
const statFailed = document.getElementById("stat-failed");

let currentId = null;

async function fetchJson(url) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }
  return response.json();
}

function formatDate(dateString) {
  const date = new Date(dateString);
  return date.toLocaleString();
}

function renderList(results) {
  listEl.innerHTML = "";
  if (!results.length) {
    listEl.innerHTML = '<div class="empty">No results yet.</div>';
    return;
  }

  results.forEach((result) => {
    const item = document.createElement("div");
    item.className = "list-item" + (result.id === currentId ? " active" : "");
    item.innerHTML = `
      <strong>${result.name || "Run"}</strong>
      <div>${formatDate(result.created_at)}</div>
      <div>${result.summary ? `diffs: ${result.summary.meaningful_diffs}` : ""}</div>
    `;
    item.addEventListener("click", () => selectResult(result.id));
    listEl.appendChild(item);
  });
}

function renderSummary(summary) {
  if (!summary) {
    detailSummary.innerHTML = "";
    return;
  }

  detailSummary.innerHTML = `
    <div class="summary-card"><span>Total diffs</span><strong>${summary.total_diffs}</strong></div>
    <div class="summary-card"><span>Meaningful</span><strong>${summary.meaningful_diffs}</strong></div>
    <div class="summary-card"><span>Ignored</span><strong>${summary.ignored_diffs}</strong></div>
    <div class="summary-card"><span>Passed</span><strong>${summary.passed}</strong></div>
  `;
}

async function renderDiffs(id) {
  const params = new URLSearchParams();
  if (filterPath.value) params.set("path", filterPath.value);
  if (filterType.value) params.set("type", filterType.value);
  params.set("format", "html");

  const data = await fetchJson(`/api/results/${id}/diffs?${params.toString()}`);
  if (!data.diffs.length) {
    detailDiffs.innerHTML = '<div class="empty">No matching diffs.</div>';
    return;
  }

  detailDiffs.innerHTML = data.formatted;
}

async function selectResult(id) {
  currentId = id;
  const result = await fetchJson(`/api/results/${id}`);

  detailTitle.textContent = result.name || "Regression Run";
  detailMeta.textContent = `Created ${formatDate(result.created_at)}`;
  renderSummary(result.summary);
  await renderDiffs(id);

  const results = await fetchJson("/api/results");
  renderList(results);
}

async function refresh() {
  const results = await fetchJson("/api/results");
  renderList(results);

  const passed = results.filter((item) => item.summary && item.summary.passed).length;
  statTotal.textContent = results.length;
  statPassed.textContent = passed;
  statFailed.textContent = results.length - passed;
}

filterPath.addEventListener("input", () => {
  if (currentId) {
    renderDiffs(currentId);
  }
});

filterType.addEventListener("change", () => {
  if (currentId) {
    renderDiffs(currentId);
  }
});

refreshBtn.addEventListener("click", refresh);

refresh().catch((error) => {
  console.error(error);
  listEl.innerHTML = '<div class="empty">Failed to load results.</div>';
});

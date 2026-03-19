// ============================================
// Currency Converter — Main Application Logic
// Uses Frankfurter API (free, no key needed)
// ============================================

const API_BASE = 'https://api.frankfurter.app';

const CURRENCY_FLAGS = {
  USD: '🇺🇸', EUR: '🇪🇺', GBP: '🇬🇧', JPY: '🇯🇵', AUD: '🇦🇺',
  CAD: '🇨🇦', CHF: '🇨🇭', CNY: '🇨🇳', SEK: '🇸🇪', NZD: '🇳🇿',
  MXN: '🇲🇽', SGD: '🇸🇬', HKD: '🇭🇰', NOK: '🇳🇴', KRW: '🇰🇷',
  TRY: '🇹🇷', INR: '🇮🇳', RUB: '🇷🇺', BRL: '🇧🇷', ZAR: '🇿🇦',
  DKK: '🇩🇰', PLN: '🇵🇱', THB: '🇹🇭', MYR: '🇲🇾', IDR: '🇮🇩',
  CZK: '🇨🇿', HUF: '🇭🇺', PHP: '🇵🇭', RON: '🇷🇴', ISK: '🇮🇸',
  ILS: '🇮🇱', BGN: '🇧🇬', HRK: '🇭🇷',
};

const CURRENCY_NAMES = {
  USD: 'US Dollar', EUR: 'Euro', GBP: 'British Pound', JPY: 'Japanese Yen',
  AUD: 'Australian Dollar', CAD: 'Canadian Dollar', CHF: 'Swiss Franc',
  CNY: 'Chinese Yuan', SEK: 'Swedish Krona', NZD: 'New Zealand Dollar',
  MXN: 'Mexican Peso', SGD: 'Singapore Dollar', HKD: 'Hong Kong Dollar',
  NOK: 'Norwegian Krone', KRW: 'South Korean Won', TRY: 'Turkish Lira',
  INR: 'Indian Rupee', RUB: 'Russian Ruble', BRL: 'Brazilian Real',
  ZAR: 'South African Rand', DKK: 'Danish Krone', PLN: 'Polish Zloty',
  THB: 'Thai Baht', MYR: 'Malaysian Ringgit', IDR: 'Indonesian Rupiah',
  CZK: 'Czech Koruna', HUF: 'Hungarian Forint', PHP: 'Philippine Peso',
  RON: 'Romanian Leu', ISK: 'Icelandic Krona', ILS: 'Israeli Shekel',
  BGN: 'Bulgarian Lev',
};

const POPULAR_PAIRS = [
  ['USD', 'EUR'], ['USD', 'GBP'], ['EUR', 'JPY'], ['USD', 'JPY'],
  ['GBP', 'EUR'], ['USD', 'CAD'], ['USD', 'INR'], ['EUR', 'GBP'],
];

let rates = {};
let currencies = [];
let chartData = [];

// ========== DOM Elements ==========
const fromAmount = document.getElementById('fromAmount');
const toAmount = document.getElementById('toAmount');
const fromCurrency = document.getElementById('fromCurrency');
const toCurrency = document.getElementById('toCurrency');
const swapBtn = document.getElementById('swapBtn');
const rateText = document.getElementById('rateText');
const rateTime = document.getElementById('rateTime');
const popularGrid = document.getElementById('popularGrid');
const loadingOverlay = document.getElementById('loadingOverlay');
const themeToggle = document.getElementById('themeToggle');
const rateChart = document.getElementById('rateChart');

// ========== Theme ==========
function initTheme() {
  const saved = localStorage.getItem('theme');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const theme = saved || (prefersDark ? 'dark' : 'light');
  setTheme(theme);
}

function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('theme', theme);
  const icon = document.querySelector('.theme-icon');
  icon.textContent = theme === 'dark' ? '☀️' : '🌙';
}

themeToggle.addEventListener('click', () => {
  const current = document.documentElement.getAttribute('data-theme');
  setTheme(current === 'dark' ? 'light' : 'dark');
});

// ========== API ==========
async function fetchRates(base = 'USD') {
  try {
    const res = await fetch(`${API_BASE}/latest?from=${base}`);
    if (!res.ok) throw new Error('API error');
    const data = await res.json();
    rates = data.rates;
    rates[base] = 1;
    currencies = Object.keys(rates).sort();
    return data;
  } catch (err) {
    console.error('Failed to fetch rates:', err);
    rateText.textContent = 'Failed to load rates. Retrying...';
    setTimeout(() => fetchRates(base), 3000);
    return null;
  }
}

async function fetchHistorical(from, to, days) {
  try {
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(endDate.getDate() - days);
    const start = startDate.toISOString().split('T')[0];
    const end = endDate.toISOString().split('T')[0];
    const res = await fetch(`${API_BASE}/${start}..${end}?from=${from}&to=${to}`);
    if (!res.ok) throw new Error('API error');
    const data = await res.json();
    return data.rates;
  } catch (err) {
    console.error('Failed to fetch historical:', err);
    return null;
  }
}

// ========== Populate Selects ==========
function populateSelects() {
  const opts = currencies.map(code => {
    const flag = CURRENCY_FLAGS[code] || '🏳️';
    const name = CURRENCY_NAMES[code] || code;
    return `<option value="${code}">${flag} ${code} — ${name}</option>`;
  }).join('');

  fromCurrency.innerHTML = opts;
  toCurrency.innerHTML = opts;

  fromCurrency.value = localStorage.getItem('fromCurrency') || 'USD';
  toCurrency.value = localStorage.getItem('toCurrency') || 'EUR';
}

// ========== Convert ==========
function convert() {
  const from = fromCurrency.value;
  const to = toCurrency.value;
  const amount = parseFloat(fromAmount.value) || 0;

  if (!rates[from] || !rates[to]) {
    toAmount.value = '—';
    return;
  }

  const rateFrom = rates[from];
  const rateTo = rates[to];
  const rate = rateTo / rateFrom;
  const result = amount * rate;

  toAmount.value = formatNumber(result, to);

  const fromFlag = CURRENCY_FLAGS[from] || '';
  const toFlag = CURRENCY_FLAGS[to] || '';
  rateText.textContent = `${fromFlag} 1 ${from} = ${toFlag} ${formatNumber(rate, to)} ${to}`;
  rateTime.textContent = `Updated: ${new Date().toLocaleTimeString()}`;

  localStorage.setItem('fromCurrency', from);
  localStorage.setItem('toCurrency', to);
}

function formatNumber(num, currency) {
  const decimals = ['JPY', 'KRW', 'IDR', 'HUF', 'ISK'].includes(currency) ? 0 : 2;
  return num.toLocaleString('en-US', {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });
}

// ========== Popular Conversions ==========
async function buildPopular() {
  popularGrid.innerHTML = '';
  for (const [from, to] of POPULAR_PAIRS) {
    const rateFrom = rates[from] || 1;
    const rateTo = rates[to] || 1;
    const rate = rateTo / rateFrom;
    const fromFlag = CURRENCY_FLAGS[from] || '';
    const toFlag = CURRENCY_FLAGS[to] || '';

    const card = document.createElement('div');
    card.className = 'popular-card';
    card.innerHTML = `
      <div class="popular-pair">${fromFlag} ${from} → ${toFlag} ${to}</div>
      <div class="popular-rate">${formatNumber(rate, to)}</div>
    `;
    card.addEventListener('click', () => {
      fromCurrency.value = from;
      toCurrency.value = to;
      fromAmount.value = 1;
      convert();
      updateChart();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
    popularGrid.appendChild(card);
  }
}

// ========== Chart ==========
async function updateChart(days = 7) {
  const from = fromCurrency.value;
  const to = toCurrency.value;
  const historical = await fetchHistorical(from, to, days);
  if (!historical) return;

  const ctx = rateChart.getContext('2d');
  const dates = Object.keys(historical).sort();
  const values = dates.map(d => historical[d][to]);

  drawChart(ctx, dates, values, from, to);
}

function drawChart(ctx, dates, values, from, to) {
  const canvas = ctx.canvas;
  const dpr = window.devicePixelRatio || 1;
  const rect = canvas.getBoundingClientRect();
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  ctx.scale(dpr, dpr);

  const w = rect.width;
  const h = rect.height;
  const padding = { top: 20, right: 16, bottom: 30, left: 60 };
  const chartW = w - padding.left - padding.right;
  const chartH = h - padding.top - padding.bottom;

  const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
  const textColor = isDark ? '#9a9ab0' : '#6b7280';
  const lineColor = isDark ? '#a29bfe' : '#6c5ce7';
  const gridColor = isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.05)';
  const fillGrad = ctx.createLinearGradient(0, padding.top, 0, h - padding.bottom);
  fillGrad.addColorStop(0, isDark ? 'rgba(162,155,254,0.3)' : 'rgba(108,92,231,0.15)');
  fillGrad.addColorStop(1, 'rgba(108,92,231,0)');

  ctx.clearRect(0, 0, w, h);

  if (values.length === 0) return;

  const minVal = Math.min(...values) * 0.998;
  const maxVal = Math.max(...values) * 1.002;
  const range = maxVal - minVal || 1;

  const xStep = chartW / Math.max(dates.length - 1, 1);

  // Grid lines
  ctx.strokeStyle = gridColor;
  ctx.lineWidth = 1;
  for (let i = 0; i <= 4; i++) {
    const y = padding.top + (chartH / 4) * i;
    ctx.beginPath();
    ctx.moveTo(padding.left, y);
    ctx.lineTo(w - padding.right, y);
    ctx.stroke();

    const val = maxVal - (range / 4) * i;
    ctx.fillStyle = textColor;
    ctx.font = '11px Inter, sans-serif';
    ctx.textAlign = 'right';
    ctx.fillText(val.toFixed(4), padding.left - 8, y + 4);
  }

  // X labels
  ctx.fillStyle = textColor;
  ctx.font = '10px Inter, sans-serif';
  ctx.textAlign = 'center';
  const labelStep = Math.max(1, Math.floor(dates.length / 6));
  dates.forEach((d, i) => {
    if (i % labelStep === 0 || i === dates.length - 1) {
      const x = padding.left + i * xStep;
      const label = d.slice(5);
      ctx.fillText(label, x, h - 8);
    }
  });

  // Area fill
  ctx.beginPath();
  ctx.moveTo(padding.left, padding.top + chartH);
  values.forEach((v, i) => {
    const x = padding.left + i * xStep;
    const y = padding.top + chartH - ((v - minVal) / range) * chartH;
    ctx.lineTo(x, y);
  });
  ctx.lineTo(padding.left + (values.length - 1) * xStep, padding.top + chartH);
  ctx.closePath();
  ctx.fillStyle = fillGrad;
  ctx.fill();

  // Line
  ctx.beginPath();
  ctx.strokeStyle = lineColor;
  ctx.lineWidth = 2.5;
  ctx.lineJoin = 'round';
  ctx.lineCap = 'round';
  values.forEach((v, i) => {
    const x = padding.left + i * xStep;
    const y = padding.top + chartH - ((v - minVal) / range) * chartH;
    if (i === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  });
  ctx.stroke();

  // End dot
  if (values.length > 0) {
    const lastX = padding.left + (values.length - 1) * xStep;
    const lastY = padding.top + chartH - ((values[values.length - 1] - minVal) / range) * chartH;
    ctx.beginPath();
    ctx.arc(lastX, lastY, 5, 0, Math.PI * 2);
    ctx.fillStyle = lineColor;
    ctx.fill();
    ctx.beginPath();
    ctx.arc(lastX, lastY, 3, 0, Math.PI * 2);
    ctx.fillStyle = isDark ? '#0f0f1a' : '#ffffff';
    ctx.fill();
  }
}

// ========== Event Listeners ==========
fromAmount.addEventListener('input', convert);
fromCurrency.addEventListener('change', () => { convert(); updateChart(); });
toCurrency.addEventListener('change', () => { convert(); updateChart(); });

swapBtn.addEventListener('click', () => {
  const tmpCur = fromCurrency.value;
  fromCurrency.value = toCurrency.value;
  toCurrency.value = tmpCur;
  convert();
  updateChart();
});

document.querySelectorAll('.quick-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    fromAmount.value = btn.dataset.amount;
    convert();
  });
});

document.querySelectorAll('.period-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.period-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    updateChart(parseInt(btn.dataset.days));
  });
});

// ========== Init ==========
async function init() {
  initTheme();
  const data = await fetchRates('USD');
  if (data) {
    populateSelects();
    convert();
    buildPopular();
    await updateChart(7);
    loadingOverlay.classList.add('hidden');
  }

  // Auto-refresh rates every 5 minutes
  setInterval(async () => {
    await fetchRates('USD');
    convert();
    buildPopular();
  }, 5 * 60 * 1000);
}

// Redraw chart on resize
let resizeTimer;
window.addEventListener('resize', () => {
  clearTimeout(resizeTimer);
  resizeTimer = setTimeout(() => {
    const days = document.querySelector('.period-btn.active')?.dataset.days || 7;
    updateChart(parseInt(days));
  }, 200);
});

init();

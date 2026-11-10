// Health check for the deployed QazoHisob web app.
//
//   node qazohisob/tool/check_site.js [url] [screenshot.png]
//
// Opens the site in Chromium (iPad-sized viewport), and checks that the app
// starts, onboarding works, data survives a reload, the app opens offline
// via the service worker, there are no page errors, and measures startup
// time and scroll frame times. Prints a JSON report; exits 1 on failure.
const { chromium } = require('playwright');

const URL_ = process.argv[2] || 'https://fayyozhasanov.github.io/Vedio-mantaj/';
const SHOT = process.argv[3] || 'qazohisob-check.png';

(async () => {
  const report = { url: URL_, ok: true, checks: {}, errors: [] };
  const fail = (name, detail) => {
    report.ok = false;
    report.checks[name] = `FAIL: ${detail}`;
  };
  const pass = (name, detail = 'ok') => (report.checks[name] = detail);

  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: { width: 820, height: 1180 } });
  const page = await ctx.newPage();
  page.on('pageerror', (e) => report.errors.push(`pageerror: ${e.message}`));
  page.on('console', (m) => m.type() === 'error' && report.errors.push(m.text()));
  page.on('response', (r) => {
    if (r.status() >= 400 && new URL(r.url()).origin === new URL(URL_).origin) {
      report.errors.push(`${r.status()} ${r.url()}`);
    }
  });

  const appReady = async (timeout = 60000) => {
    await page.waitForFunction(
      () => !document.getElementById('splash') && !!document.querySelector('flutter-view'),
      null,
      { timeout },
    );
    await page.waitForTimeout(1500);
    await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
    await page.waitForTimeout(800);
  };
  const hasText = (t) =>
    page.evaluate((t) => [...document.querySelectorAll('flt-semantics')]
      .some((e) => (e.getAttribute('aria-label') || e.textContent || '').includes(t)), t);
  const tap = async (name) => {
    await page.getByRole('button', { name }).first().click();
    await page.waitForTimeout(1500);
  };

  try {
    const t0 = Date.now();
    const resp = await page.goto(URL_, { waitUntil: 'load', timeout: 60000 });
    if (!resp || !resp.ok()) throw new Error(`HTTP ${resp && resp.status()}`);
    await appReady();
    report.startupMs = Date.now() - t0;
    pass('loads', `${report.startupMs} ms`);
    if (report.startupMs > 20000) fail('startup_speed', `${report.startupMs} ms`);

    // Fresh browser profile -> onboarding. Skip through it.
    if (await hasText('O‘tkazib yuborish')) {
      await tap('O‘tkazib yuborish');
      await tap('Keyinroq kiritaman');
      await tap('Boshlash');
    }
    if (await hasText('Assalomu alaykum')) pass('home');
    else fail('home', 'dashboard not shown');

    // Scroll smoothness on the dashboard.
    report.scroll = await page.evaluate(async () => {
      const t = []; let last = performance.now(); let run = true;
      const tick = (x) => { t.push(x - last); last = x; if (run) requestAnimationFrame(tick); };
      requestAnimationFrame(tick);
      const el = document.querySelector('flutter-view');
      const r = el.getBoundingClientRect();
      for (let i = 0; i < 30; i++) {
        el.dispatchEvent(new WheelEvent('wheel', {
          deltaY: i < 15 ? 120 : -120, clientX: r.width / 2, clientY: r.height / 2, bubbles: true,
        }));
        await new Promise((res) => setTimeout(res, 60));
      }
      await new Promise((res) => setTimeout(res, 400)); run = false;
      t.sort((a, b) => a - b);
      return {
        avgMs: +(t.reduce((a, b) => a + b, 0) / t.length).toFixed(1),
        p90Ms: +t[Math.floor(t.length * 0.9)].toFixed(1),
      };
    });
    pass('scroll', JSON.stringify(report.scroll));

    // Persistence: after reload the onboarding must not come back.
    await page.reload({ waitUntil: 'load' });
    await appReady();
    if (await hasText('Assalomu alaykum')) pass('persistence');
    else fail('persistence', 'data lost after reload');

    // Offline start through the service worker.
    const sw = await page.evaluate(async () => !!(await navigator.serviceWorker.getRegistration()));
    if (!sw) fail('service_worker', 'not registered');
    await ctx.setOffline(true);
    await page.reload({ waitUntil: 'load' });
    await appReady();
    if (await hasText('Assalomu alaykum')) pass('offline');
    else fail('offline', 'app did not start offline');
    await ctx.setOffline(false);
    await page.screenshot({ path: SHOT });
  } catch (e) {
    fail('run', e.message);
    await page.screenshot({ path: SHOT }).catch(() => {});
  }

  if (report.errors.length) fail('console', `${report.errors.length} error(s)`);
  await browser.close();
  console.log(JSON.stringify(report, null, 2));
  process.exit(report.ok ? 0 : 1);
})();

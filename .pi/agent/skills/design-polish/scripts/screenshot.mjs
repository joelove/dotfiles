#!/usr/bin/env node
/**
 * Full-page screenshots for design iteration.
 *
 * Usage:
 *   node screenshot.mjs <outdir> <url> [url...]
 *   node screenshot.mjs --viewport 1440x900 --viewport 390x844 <outdir> <url> [url...]
 *
 * Defaults to desktop 1440x900 and mobile 390x844. Writes one PNG per
 * url+viewport, named from the url path (e.g. `roles-id-1440x900.png`).
 *
 * Playwright resolves from the repo named by PLAYWRIGHT_DEPS (default:
 * candela-eval, which has @playwright/test and cached browsers).
 */
import { createRequire } from "node:module";
import { mkdirSync } from "node:fs";
import { basename, join, resolve } from "node:path";

const WORKSPACE = process.env.CANDELA_WORKSPACE ?? "/Users/joelove/Projects/candela";
const DEPS_REPO = process.env.PLAYWRIGHT_DEPS ?? join(WORKSPACE, "candela-eval");
const require = createRequire(join(DEPS_REPO, "package.json"));
const { chromium } = require("@playwright/test");

const DEFAULT_VIEWPORTS = ["1440x900", "390x844"];

function parseArgs(argv) {
  const viewports = [];
  const rest = [];
  for (let i = 0; i < argv.length; i += 1) {
    if (argv[i] === "--viewport") {
      viewports.push(argv[i + 1]);
      i += 1;
    } else {
      rest.push(argv[i]);
    }
  }
  const [outdir, ...urls] = rest;
  if (!outdir || urls.length === 0) {
    console.error("usage: screenshot.mjs [--viewport WxH] <outdir> <url> [url...]");
    process.exit(2);
  }
  return { outdir, urls, viewports: viewports.length ? viewports : DEFAULT_VIEWPORTS };
}

function slugFor(url) {
  const parsed = new URL(url);
  const path = parsed.pathname.replace(/\/+$/, "") || "/";
  const base = path.split("/").filter(Boolean).join("-") || "home";
  const query = parsed.search.replace(/^\?/, "").replace(/[^a-z0-9-]/gi, "_");
  return (query ? `${base}-${query}` : base).replace(/[^a-z0-9-_]/gi, "_");
}

const { outdir, urls, viewports } = parseArgs(process.argv.slice(2));
mkdirSync(outdir, { recursive: true });

const browser = await chromium.launch();
try {
  for (const vp of viewports) {
    const [width, height] = vp.split("x").map(Number);
    const page = await browser.newPage({ viewport: { width, height } });
    for (const url of urls) {
      const file = join(outdir, `${slugFor(url)}-${vp}.png`);
      await page.goto(url, { waitUntil: "networkidle" });
      // App shells can scroll inside a fixed-height container, which defeats
      // fullPage. Grow the viewport to the document height instead. Measure
      // twice: the first resize can change the document height.
      for (let pass = 0; pass < 2; pass += 1) {
        const docHeight = await page.evaluate(() =>
          Math.max(
            document.documentElement.scrollHeight,
            document.body?.scrollHeight ?? 0,
          ),
        );
        await page.setViewportSize({
          width,
          height: Math.min(Math.max(docHeight, height), 12000),
        });
      }
      await page.screenshot({ path: file });
      console.log(file);
    }
    await page.close();
  }
} finally {
  await browser.close();
}

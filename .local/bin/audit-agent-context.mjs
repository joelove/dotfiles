#!/usr/bin/env node
/**
 * audit-agent-context - read-only report of what pi puts into context.
 *
 * Uses pi's own DefaultResourceLoader, so it reports exactly what the running
 * pi would advertise: skills hidden with `disable-model-invocation` are listed
 * separately, and context files (AGENTS.md) are read from the real chain.
 *
 * Usage:
 *   audit-agent-context [--cwd PATH] [--repo NAME] [--json] [--check] [--context-max BYTES]
 *
 * --repo resolves against $AGENT_AUDIT_ROOT (default ~/Projects). --check exits
 * non-zero when the advertised skill count is above 13 or the always-on
 * description bytes are 4,000 or more. --context-max adds a context-file cap.
 */
import { execSync } from "node:child_process";
import { existsSync, readdirSync, statSync } from "node:fs";
import path from "node:path";

const args = process.argv.slice(2);
const flag = (name) => {
  const i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : undefined;
};
const repo = flag("--repo");
const projectRoot = process.env.AGENT_AUDIT_ROOT ?? path.join(process.env.HOME ?? ".", "Projects");
function findRepo(root, name, depth = 3) {
  const direct = path.join(root, name);
  if (existsSync(direct)) return direct;
  if (depth <= 0) return null;
  let entries;
  try {
    entries = readdirSync(root, { withFileTypes: true });
  } catch {
    return null;
  }
  for (const entry of entries) {
    if (!entry.isDirectory() || entry.name.startsWith(".")) continue;
    const found = findRepo(path.join(root, entry.name), name, depth - 1);
    if (found) return found;
  }
  return null;
}
const cwd =
  flag("--cwd") ??
  (repo ? findRepo(projectRoot, repo) ?? path.join(projectRoot, repo) : process.cwd());
const contextMax = flag("--context-max") ? Number(flag("--context-max")) : null;
const asJson = args.includes("--json");
const check = args.includes("--check");

const globalRoot = execSync("npm root -g", { encoding: "utf8" }).trim();
const sdkPath = path.join(globalRoot, "@earendil-works/pi-coding-agent/dist/index.js");
if (!existsSync(sdkPath)) {
  console.error(`audit-agent-context: pi SDK not found at ${sdkPath}`);
  process.exit(2);
}
const { DefaultResourceLoader, getAgentDir } = await import(sdkPath);

const utf8 = (s) => Buffer.byteLength(s ?? "", "utf8");
const bodyBytes = (file) => (file && existsSync(file) ? statSync(file).size : 0);

const loader = new DefaultResourceLoader({ cwd, agentDir: getAgentDir() });
await loader.reload();
const { skills, diagnostics } = loader.getSkills();
const { agentsFiles } = loader.getAgentsFiles();

const advertised = skills
  .filter((s) => !s.disableModelInvocation)
  .map((s) => ({ name: s.name, descriptionBytes: utf8(s.description), bodyBytes: bodyBytes(s.filePath) }))
  .sort((a, b) => b.descriptionBytes - a.descriptionBytes);
const hidden = skills
  .filter((s) => s.disableModelInvocation)
  .map((s) => s.name)
  .sort();

const contexts = agentsFiles
  .map((f) => ({ path: f.path, bytes: utf8(f.content) }))
  .sort((a, b) => b.bytes - a.bytes);

const advertisedBytes = advertised.reduce((n, s) => n + s.descriptionBytes, 0);
const contextBytes = contexts.reduce((n, f) => n + f.bytes, 0);

const result = {
  cwd,
  advertisedCount: advertised.length,
  advertisedBytes,
  hiddenCount: hidden.length,
  hidden,
  advertised,
  contextBytes,
  contexts,
  diagnostics,
  targets: {
    advertisedMax: 13,
    advertisedBytesMax: 3999,
    contextBytesMax: contextMax,
  },
};

if (asJson) {
  console.log(JSON.stringify(result, null, 2));
} else {
  console.log(`audit-agent-context  ${cwd}`);
  console.log(`advertised skills: ${advertised.length} (descriptions ${advertisedBytes} B)`);
  for (const s of advertised) {
    console.log(`  ${String(s.descriptionBytes).padStart(5)} desc  ${String(s.bodyBytes).padStart(6)} body  ${s.name}`);
  }
  console.log(`hidden skills: ${hidden.length} (${hidden.join(", ") || "-"})`);
  console.log(`context files: ${contexts.length} (${contextBytes} B)`);
  for (const f of contexts) {
    console.log(`  ${String(f.bytes).padStart(6)} B  ${f.path}`);
  }
  if (diagnostics.length > 0) {
    console.log("diagnostics:");
    for (const d of diagnostics) console.log(`  ${d.message ?? JSON.stringify(d)}`);
  }
}

const failures = [];
if (check) {
  if (advertised.length > result.targets.advertisedMax) {
    failures.push(`advertised ${advertised.length} > ${result.targets.advertisedMax}`);
  }
  if (advertisedBytes > result.targets.advertisedBytesMax) {
    failures.push(`description bytes ${advertisedBytes} > ${result.targets.advertisedBytesMax}`);
  }
  if (contextMax !== null && contextBytes > contextMax) {
    failures.push(`context bytes ${contextBytes} > ${contextMax}`);
  }
  if (failures.length > 0) {
    console.error(`CHECK FAILED: ${failures.join("; ")}`);
    process.exit(1);
  }
  console.error("CHECK PASSED");
}

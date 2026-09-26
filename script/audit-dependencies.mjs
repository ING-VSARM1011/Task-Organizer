import { readFileSync } from "node:fs";

// Audit the committed resolutions, including gems for every supported platform.
const gems = [...readFileSync("Gemfile.lock", "utf8").matchAll(/^    ([\w-]+) \((\d[^)]*)\)$/gm)]
  .map(([, name, version]) => ({
    package: { name, ecosystem: "RubyGems" },
    version: version.replace(/-(?:aarch64|arm|x86|x64).*$/, ""),
  }));
const npm = [...readFileSync("yarn.lock", "utf8").matchAll(/^([^\s#][^\n]*):\r?\n  version "([^"]+)"/gm)]
  .map(([, selectors, version]) => {
    const selector = selectors.split(/,\s*/)[0].replaceAll('"', "");
    return { package: { name: selector.slice(0, selector.lastIndexOf("@")), ecosystem: "npm" }, version };
  });
if (!gems.length || !npm.length) throw new Error("Unable to parse dependency lockfiles");
const queries = [...new Map([...gems, ...npm].map(q => [JSON.stringify(q), q])).values()];
let affected = 0;
for (let offset = 0; offset < queries.length; offset += 100) {
  const batch = queries.slice(offset, offset + 100);
  const response = await fetch("https://api.osv.dev/v1/querybatch", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ queries: batch }),
    signal: AbortSignal.timeout(60000),
  });
  if (!response.ok) throw new Error(`OSV returned HTTP ${response.status}`);
  const { results } = await response.json();
  if (!results || results.length !== batch.length) throw new Error("Incomplete OSV response");
  results.forEach((result, index) => {
    if (result.vulns?.length) {
      affected++;
      const q = batch[index];
      console.error(`${q.package.ecosystem}: ${q.package.name}@${q.version}: ${result.vulns.map(v => v.id).join(", ")}`);
    }
  });
}
console.log(`Audited ${queries.length} dependency versions; ${affected} affected packages.`);
process.exitCode = affected ? 1 : 0;

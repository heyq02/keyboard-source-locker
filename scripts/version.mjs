#!/usr/bin/env node
import { configFromArgs, run, runCapture } from "./lib.mjs";

const config = configFromArgs();
// Keep build noise off stdout so `$(node scripts/version.mjs)` is only the version.
run("swift", ["build", "-c", config, "--product", "VersionTool"], {
  stdio: ["ignore", "pipe", "inherit"],
});
const version = runCapture("swift", ["run", "-c", config, "VersionTool"]);
if (!version) {
  console.error("error: VersionTool returned empty version");
  process.exit(1);
}
console.log(version);

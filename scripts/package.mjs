#!/usr/bin/env node
import { chmodSync, cpSync, mkdirSync, rmSync, existsSync } from "node:fs";
import path from "node:path";

import { configFromArgs, rootDir, run, runCapture } from "./lib.mjs";

const config = configFromArgs();
const product = "KeyboardSourceLockerApp";
const appName = "KeyboardSourceLocker";
const buildDir = path.join(rootDir, ".build", config);
const distDir = path.join(rootDir, "dist");
const appDir = path.join(distDir, `${appName}.app`);
const binary = path.join(buildDir, product);

console.log("==> Reading version from package.json via Swift");
run("swift", ["build", "-c", config, "--product", "VersionTool"]);
const version = runCapture("swift", ["run", "-c", config, "VersionTool"]);
if (!version) {
  console.error("error: VersionTool returned empty version");
  process.exit(1);
}

let buildNumber = process.env.BUILD_NUMBER;
if (!buildNumber) {
  try {
    buildNumber = runCapture("git", ["-C", rootDir, "rev-list", "--count", "HEAD"]);
  } catch {
    buildNumber = "1";
  }
}

console.log(`==> Building ${product} (${config}) version ${version} (${buildNumber})`);
run("swift", ["build", "-c", config, "--product", product]);

if (!existsSync(binary)) {
  console.error(`error: expected binary at ${binary}`);
  process.exit(1);
}

console.log("==> Ensuring AppIcon.icns");
run("node", [path.join(rootDir, "scripts", "icon.mjs")]);

console.log(`==> Packaging ${appName}.app`);
rmSync(appDir, { recursive: true, force: true });
mkdirSync(path.join(appDir, "Contents", "MacOS"), { recursive: true });
mkdirSync(path.join(appDir, "Contents", "Resources"), { recursive: true });

const appBinary = path.join(appDir, "Contents", "MacOS", product);
const appInfoPlist = path.join(appDir, "Contents", "Info.plist");
const appResources = path.join(appDir, "Contents", "Resources");
const icns = path.join(rootDir, "static", "AppIcon.icns");
cpSync(binary, appBinary);
cpSync(path.join(rootDir, "static", "Info.plist"), appInfoPlist);
cpSync(path.join(rootDir, "package.json"), path.join(appResources, "package.json"));
cpSync(icns, path.join(appResources, "AppIcon.icns"));
chmodSync(appBinary, 0o755);

run("/usr/libexec/PlistBuddy", ["-c", `Set :CFBundleShortVersionString ${version}`, appInfoPlist]);
run("/usr/libexec/PlistBuddy", ["-c", `Set :CFBundleVersion ${buildNumber}`, appInfoPlist]);

try {
  run("codesign", ["--force", "--deep", "--sign", "-", appDir]);
} catch (error) {
  console.warn(`warning: codesign skipped (${error.message})`);
}

console.log(`==> Packaged at ${appDir} (version ${version})`);
run("ls", ["-la", path.join(appDir, "Contents", "MacOS")]);
run("ls", ["-la", path.join(appDir, "Contents", "Resources")]);

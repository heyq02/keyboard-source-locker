#!/usr/bin/env node
/**
 * Build the static landing page in site/ into dist-site/ for GitHub Pages.
 */
import { rmSync } from "node:fs";
import path from "node:path";

import { rootDir, run } from "./lib.mjs";

const outDir = path.join(rootDir, "dist-site");

rmSync(outDir, { recursive: true, force: true });
console.log("==> Building site/ into dist-site/");
run("vp", ["build", "site", "--outDir", "../dist-site", "--emptyOutDir", "--base", "./"]);

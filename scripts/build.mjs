#!/usr/bin/env node
import { configFromArgs, run } from "./lib.mjs";

const config = configFromArgs();
run("swift", ["build", "-c", config, "--product", "KeyboardSourceLockerApp"]);

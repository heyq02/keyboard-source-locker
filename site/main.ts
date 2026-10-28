import pkg from "../package.json" with { type: "json" };

const year = document.getElementById("year");
if (year) year.textContent = String(new Date().getFullYear());

const version = document.getElementById("version");
if (version) version.textContent = pkg.version;

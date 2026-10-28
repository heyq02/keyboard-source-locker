import { defineConfig } from "vite-plus";

export default defineConfig({
    run: {
        // Swift builds are side-effectful; never replay from cache.
        cache: { scripts: false, tasks: false },
        tasks: {
            version: "node scripts/version.mjs",
            test: "node scripts/test.mjs",
            build: "node scripts/build.mjs",
            start: "node scripts/run-app.mjs",
            package: "node scripts/package.mjs",
            clean: "node scripts/clean.mjs",
            check: "node scripts/check.mjs",
            coverage: "node scripts/coverage.mjs",
        },
    },
    lint: {
        ignorePatterns: [".agents/**", "skills-lock.json", ".build/**", "dist/**"],
        options: {
            typeAware: true,
            typeCheck: true,
        },
    },
    fmt: {
        ignorePatterns: [".agents/**", "skills-lock.json", ".build/**", "dist/**"],
        sortImports: true,
        sortPackageJson: true,
        sortTailwindcss: true,
    },
});

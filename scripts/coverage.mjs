#!/usr/bin/env node
/**
 * Instrument CoreTestRunner, run it, and require ≥90% line coverage
 * on src/KeyboardSourceLocker.
 */
import { existsSync, mkdirSync, rmSync, writeFileSync } from 'node:fs'
import path from 'node:path'
import { rootDir, run, runCapture } from './lib.mjs'

const threshold = Number(process.env.COVERAGE_THRESHOLD || 90)
const outDir = path.join(rootDir, '.build', 'coverage')
const profraw = path.join(outDir, 'default.profraw')
const profdata = path.join(outDir, 'default.profdata')
const bin = path.join(rootDir, '.build', 'debug', 'CoreTestRunner')
const sources = path.join(rootDir, 'src', 'KeyboardSourceLocker')

rmSync(outDir, { recursive: true, force: true })
mkdirSync(outDir, { recursive: true })

console.log('==> Building CoreTestRunner with coverage instrumentation')
run('swift', [
  'build',
  '-c',
  'debug',
  '--product',
  'CoreTestRunner',
  '-Xswiftc',
  '-profile-coverage-mapping',
  '-Xswiftc',
  '-profile-generate',
])

if (!existsSync(bin)) {
  console.error(`error: missing binary at ${bin}`)
  process.exit(1)
}

console.log('==> Running CoreTestRunner')
run(bin, [], {
  env: {
    ...process.env,
    LLVM_PROFILE_FILE: profraw,
  },
})

if (!existsSync(profraw)) {
  console.error(`error: missing profile at ${profraw}`)
  process.exit(1)
}

run('xcrun', ['llvm-profdata', 'merge', '-sparse', profraw, '-o', profdata])

const report = runCapture('xcrun', [
  'llvm-cov',
  'report',
  bin,
  `-instr-profile=${profdata}`,
  `-ignore-filename-regex=(\\.build/|Tests/|/usr/|CoreTestRunner)`,
  sources,
])
console.log(report)

writeFileSync(path.join(outDir, 'report.txt'), `${report}\n`)

const totalLine = report
  .split('\n')
  .map((line) => line.trim())
  .reverse()
  .find((line) => line.startsWith('TOTAL'))

if (!totalLine) {
  console.error('error: could not parse llvm-cov TOTAL line')
  process.exit(1)
}

// TOTAL <regions> <missed> <%> <fns> <missed> <%> <lines> <missed> <%> ...
const parts = totalLine.split(/\s+/).filter(Boolean)
const percents = parts
  .filter((part) => part.endsWith('%'))
  .map((part) => Number(part.replace('%', '')))
if (percents.length < 3 || Number.isNaN(percents[2])) {
  console.error(`error: could not parse line coverage from: ${totalLine}`)
  process.exit(1)
}

const lineCoverage = percents[2]
console.log(`==> Line coverage: ${lineCoverage.toFixed(2)}% (threshold ${threshold}%)`)

if (lineCoverage + 1e-9 < threshold) {
  console.error(`error: line coverage ${lineCoverage.toFixed(2)}% is below ${threshold}%`)
  process.exit(1)
}

console.log('OK: coverage threshold met')

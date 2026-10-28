#!/usr/bin/env node
import { rmSync } from 'node:fs'
import path from 'node:path'
import { rootDir } from './lib.mjs'

for (const name of ['.build', 'dist']) {
  rmSync(path.join(rootDir, name), { recursive: true, force: true })
  console.log(`removed ${name}`)
}

#!/usr/bin/env node
import { run } from './lib.mjs'

for (const product of ['KeyboardSourceLockerApp', 'CoreTestRunner', 'VersionTool']) {
  console.log(`==> check ${product}`)
  run('swift', ['build', '-c', 'debug', '--product', product])
}

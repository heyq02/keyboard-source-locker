import { spawnSync } from 'node:child_process'
import { fileURLToPath } from 'node:url'
import path from 'node:path'

export const rootDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')

export function run(command, args, { cwd = rootDir, env = process.env, stdio = 'inherit' } = {}) {
  const result = spawnSync(command, args, {
    cwd,
    env,
    stdio,
    encoding: 'utf8',
  })
  if (result.error) throw result.error
  if (result.status !== 0) {
    const detail = result.stderr?.trim() || result.stdout?.trim() || `${command} exited ${result.status}`
    throw new Error(detail)
  }
  return result
}

export function runCapture(command, args, options = {}) {
  const result = run(command, args, { ...options, stdio: ['ignore', 'pipe', 'pipe'] })
  return (result.stdout || '').trim()
}

export function configFromArgs(argv = process.argv.slice(2)) {
  return argv[0] === 'debug' ? 'debug' : 'release'
}

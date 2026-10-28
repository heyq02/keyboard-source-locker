#!/usr/bin/env node
/**
 * Build Resources/AppIcon.icns from images/app-icon.jpg
 */
import { existsSync, mkdirSync, rmSync } from 'node:fs'
import path from 'node:path'
import { rootDir, run } from './lib.mjs'

const src = path.join(rootDir, 'images', 'app-icon.jpg')
const resources = path.join(rootDir, 'Resources')
const iconset = path.join(resources, 'AppIcon.iconset')
const icns = path.join(resources, 'AppIcon.icns')
const master = path.join(resources, '.app-icon-1024.png')

if (!existsSync(src)) {
  console.error(`error: missing icon source at ${src}`)
  process.exit(1)
}

rmSync(iconset, { recursive: true, force: true })
rmSync(master, { force: true })
mkdirSync(iconset, { recursive: true })

console.log('==> Building AppIcon.icns from images/app-icon.jpg')
const quiet = { stdio: ['ignore', 'pipe', 'inherit'] }
run('sips', ['-s', 'format', 'png', src, '--out', master], quiet)

for (const size of [16, 32, 128, 256, 512]) {
  run('sips', ['-z', String(size), String(size), master, '--out', path.join(iconset, `icon_${size}x${size}.png`)], quiet)
  run(
    'sips',
    [
      '-z',
      String(size * 2),
      String(size * 2),
      master,
      '--out',
      path.join(iconset, `icon_${size}x${size}@2x.png`),
    ],
    quiet,
  )
}

run('iconutil', ['-c', 'icns', iconset, '-o', icns])
rmSync(iconset, { recursive: true, force: true })
rmSync(master, { force: true })

console.log(`==> Wrote ${icns}`)

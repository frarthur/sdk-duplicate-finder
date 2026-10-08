import { appendFileSync, existsSync, readFileSync, writeFileSync } from "node:fs"
import { basename, dirname, join } from "node:path"
import { fileURLToPath } from "node:url"

const here = dirname(fileURLToPath(import.meta.url))
const script = join(here, "..", "to-launch-when-job-end-opnecode.ps1")
const logFile = join(here, "notify-on-idle.log")
const stampFile = join(here, ".notify-last")

// Fenetre anti-doublon (ms). Le plugin peut etre instancie plusieurs fois :
// on partage donc l'horodatage via un fichier plutot qu'en memoire.
const DEBOUNCE_MS = 3000

function log(message) {
  try {
    appendFileSync(logFile, `[${new Date().toISOString()}] ${message}\n`)
  } catch {
    // ignore
  }
}

function recentlyFired() {
  try {
    const t = parseInt(readFileSync(stampFile, "utf8"), 10)
    return Number.isFinite(t) && (Date.now() - t) < DEBOUNCE_MS
  } catch {
    return false
  }
}

function markFired() {
  try {
    writeFileSync(stampFile, String(Date.now()))
  } catch {
    // ignore
  }
}

export const NotifyOnIdle = async ({ $, directory }) => {
  // Nom du dossier du projet ouvert dans opencode.
  const folder = directory ? basename(directory) : "opencode"
  log(`plugin chargé — dossier=${folder} script=${script} existe=${existsSync(script)}`)

  return {
    event: async ({ event }) => {
      // Seulement la fin de tour (l'evenement dedie).
      if (event?.type !== "session.idle") return

      // Anti-doublon partage entre toutes les instances du plugin.
      if (recentlyFired()) {
        log("ignore (anti-doublon fichier)")
        return
      }
      markFired()

      if (!existsSync(script)) {
        log("script introuvable, abandon")
        return
      }
      try {
        await $`powershell -NoProfile -ExecutionPolicy Bypass -File ${script} -Folder ${folder}`.quiet().nothrow()
        log(`notification lancée (dossier=${folder})`)
      } catch (error) {
        log(`erreur: ${error}`)
      }
    },
  }
}

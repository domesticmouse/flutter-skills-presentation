<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue'
import 'asciinema-player/dist/bundle/asciinema-player.css'

export interface AsciinemaPlayerProps {
  /**
   * Path to .cast file (e.g. '/casts/demo.cast'), Data URL, or remote URL
   */
  src: string
  /**
   * Terminal columns override (defaults to recording header)
   */
  cols?: number
  /**
   * Terminal rows override (defaults to recording header)
   */
  rows?: number
  /**
   * Automatically start playback on slide entry
   */
  autoPlay?: boolean
  /**
   * Preload cast file before playback starts
   */
  preload?: boolean
  /**
   * Loop playback: true for infinite, or a number for fixed repetitions
   */
  loop?: boolean | number
  /**
   * Playback speed multiplier (e.g. 1.0, 1.5, 2.0)
   */
  speed?: number
  /**
   * Skip to timestamp in seconds or NPT string ("0:15")
   */
  startAt?: number | string
  /**
   * Maximum idle time between terminal events in seconds
   */
  idleTimeLimit?: number
  /**
   * Color theme: 'asciinema' | 'dracula' | 'monokai' | 'nord' | 'solarized-dark' |
   * 'solarized-light' | 'gruvbox-dark' | 'tango' | 'github-dark' | 'github-light'
   */
  theme?: string
  /**
   * Scaling mode: 'width' | 'height' | 'both' | 'none'
   */
  fit?: 'width' | 'height' | 'both' | 'none'
  /**
   * Player control bar: true | false | 'auto' (show on hover)
   */
  controls?: boolean | 'auto'
  /**
   * Terminal font size: 'small' | 'medium' | 'big' or custom CSS size (e.g. '14px')
   */
  terminalFontSize?: string
  /**
   * Custom CSS font family string
   */
  terminalFontFamily?: string
  /**
   * Terminal line height multiplier
   */
  terminalLineHeight?: number
  /**
   * Poster frame preview timestamp (e.g. 'npt:0:05')
   */
  poster?: string
  /**
   * Chapter markers: [timestamp, label][] or [timestamp][]
   */
  markers?: Array<number | [number, string]>
  /**
   * Pause automatically on hitting chapter markers (defaults to true when markers exist)
   */
  pauseOnMarkers?: boolean
  /**
   * Render compact Variant A chapter stepper pills above the terminal when markers exist
   */
  showChapterBar?: boolean
}

export interface CastChapter {
  index: number
  rawTime: number
  playTime: number
  label: string
}

const props = withDefaults(defineProps<AsciinemaPlayerProps>(), {
  cols: undefined,
  rows: undefined,
  autoPlay: false,
  preload: true,
  loop: false,
  speed: 1.0,
  startAt: 0,
  idleTimeLimit: 2.0,
  theme: 'dracula',
  fit: 'width',
  controls: 'auto',
  terminalFontSize: 'small',
  terminalFontFamily: "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', monospace",
  terminalLineHeight: 1.3333,
  poster: undefined,
  markers: () => [],
  pauseOnMarkers: undefined,
  showChapterBar: true,
})

const containerRef = ref<HTMLDivElement | null>(null)
const chapters = ref<CastChapter[]>([])
const activeChapterIdx = ref<number>(-1)
const hitChapterIdx = ref<number>(-1)
const isPlaying = ref<boolean>(false)
const statusText = ref<string>('Ready (Paused)')
const statusMode = ref<'' | 'playing' | 'paused-marker'>('')

let playerInstance: any = null
let resizeObserver: ResizeObserver | null = null

function formatTime(sec: number): string {
  const s = Math.max(0, Math.floor(sec))
  const m = Math.floor(s / 60)
  const rem = s % 60
  return `${String(m).padStart(2, '0')}:${String(rem).padStart(2, '0')}`
}

/**
 * Normalizes asciicast v3 (or v2) streams into asciicast v2 NDJSON and extracts
 * embedded "m" chapter markers with idle-capped playback timestamps.
 * Prevents the 💥 parser error in asciinema-player <3.10 when loading v3 files.
 */
function prepareCastForPlayer(castText: string, idleTimeLimitOverride?: number): {
  v2Text: string
  foundChapters: CastChapter[]
} {
  const lines = castText.split(/\r?\n/).filter((l) => l.trim() && !l.trim().startsWith('#'))
  if (!lines.length) return { v2Text: '', foundChapters: [] }

  const header = JSON.parse(lines[0])
  const version = Number(header.version || 2)
  const idleCap = Number(idleTimeLimitOverride ?? header.idle_time_limit ?? 2.0)

  const v2Header = {
    version: 2,
    width: (header.term && header.term.cols) || header.width || 120,
    height: (header.term && header.term.rows) || header.height || 32,
    timestamp: header.timestamp,
    idle_time_limit: idleCap,
    env: header.env || { SHELL: '/bin/zsh' },
  }

  const v2Lines: string[] = [JSON.stringify(v2Header)]
  const foundChapters: CastChapter[] = []
  let rawAbs = 0.0
  let effAbs = 0.0
  let prevRaw = 0.0

  for (let i = 1; i < lines.length; i++) {
    const ev = JSON.parse(lines[i])
    const tVal = Number(ev[0])
    const code = String(ev[1])
    const payload = ev.length > 2 ? String(ev[2]) : ''

    let dt = 0.0
    if (version === 3) {
      dt = tVal
      rawAbs += dt
    } else {
      rawAbs = tVal
      dt = rawAbs - prevRaw
      prevRaw = rawAbs
    }
    effAbs += Math.min(dt, idleCap)

    const absTime = Number(rawAbs.toFixed(6))
    if (code === 'm') {
      foundChapters.push({
        index: foundChapters.length,
        rawTime: rawAbs,
        playTime: effAbs,
        label: payload || `Marker ${foundChapters.length + 1}`,
      })
      v2Lines.push(JSON.stringify([absTime, 'm', payload]))
    } else if (code === 'x') {
      v2Lines.push(JSON.stringify([absTime, 'o', '']))
    } else {
      v2Lines.push(JSON.stringify([absTime, code, payload]))
    }
  }

  return {
    v2Text: v2Lines.join('\n') + '\n',
    foundChapters,
  }
}

/**
 * Normalizes asset paths against Vite's base URL for GitHub Pages compatibility
 */
function resolveUrl(rawSrc: string): string {
  if (!rawSrc) return ''
  if (
    rawSrc.startsWith('http://') ||
    rawSrc.startsWith('https://') ||
    rawSrc.startsWith('data:') ||
    rawSrc.startsWith('blob:')
  ) {
    return rawSrc
  }
  const base = import.meta.env.BASE_URL || '/'
  const normalizedBase = base.endsWith('/') ? base : `${base}/`
  const cleanPath = rawSrc.replace(/^\.?\//, '')
  return `${normalizedBase}${cleanPath}`
}

/**
 * Cleanly initializes the player on the client DOM
 */
async function initPlayer() {
  if (typeof window === 'undefined' || !containerRef.value) return

  // Dispose previous instance if re-initializing
  teardownPlayer()

  try {
    // Dynamic import guarantees no SSR execution for player JS
    const AsciinemaPlayer = await import('asciinema-player')

    const resolvedSrc = resolveUrl(props.src)
    let sourceArg: any = resolvedSrc
    let discoveredChapters: CastChapter[] = []

    try {
      const response = await fetch(resolvedSrc)
      if (response.ok) {
        const rawText = await response.text()
        const prepared = prepareCastForPlayer(rawText, props.idleTimeLimit)
        if (prepared.v2Text) {
          sourceArg = { data: prepared.v2Text }
          discoveredChapters = prepared.foundChapters
        }
      }
    } catch (_) {
      // Fallback to direct URL if fetch is unavailable
    }

    chapters.value = discoveredChapters
    const hasMarkers = props.markers.length > 0 || discoveredChapters.length > 0
    const effectivePauseOnMarkers = props.pauseOnMarkers ?? hasMarkers

    const playerOptions: Record<string, any> = {
      cols: props.cols,
      rows: props.rows,
      autoPlay: props.autoPlay,
      preload: props.preload,
      loop: props.loop,
      speed: props.speed,
      startAt: props.startAt,
      idleTimeLimit: props.idleTimeLimit,
      theme: props.theme,
      fit: props.fit,
      controls: props.controls,
      terminalFontSize: props.terminalFontSize,
      terminalFontFamily: props.terminalFontFamily,
      terminalLineHeight: props.terminalLineHeight,
      poster: props.poster,
      markers: props.markers.length > 0 ? props.markers : undefined,
      pauseOnMarkers: effectivePauseOnMarkers,
    }

    // Strip undefined keys
    Object.keys(playerOptions).forEach((key) => {
      if (playerOptions[key] === undefined) delete playerOptions[key]
    })

    playerInstance = AsciinemaPlayer.create(sourceArg, containerRef.value, playerOptions)

    playerInstance.addEventListener('play', () => {
      isPlaying.value = true
      hitChapterIdx.value = -1
      statusText.value = `Playing (${props.speed}x)`
      statusMode.value = 'playing'
    })

    playerInstance.addEventListener('pause', () => {
      isPlaying.value = false
      if (statusMode.value !== 'paused-marker') {
        statusText.value = 'Paused'
        statusMode.value = ''
      }
    })

    playerInstance.addEventListener('marker', ({ index, label }: { index: number; time: number; label: string }) => {
      activeChapterIdx.value = index
      if (effectivePauseOnMarkers) {
        isPlaying.value = false
        hitChapterIdx.value = index
        statusText.value = `⏸ Auto-Paused: ${label}`
        statusMode.value = 'paused-marker'
      }
    })

    playerInstance.addEventListener('ended', () => {
      isPlaying.value = false
      statusText.value = 'Ended'
      statusMode.value = ''
    })

    // Setup ResizeObserver to adjust on Slidev view transitions
    if (typeof ResizeObserver !== 'undefined' && containerRef.value) {
      resizeObserver = new ResizeObserver(() => {
        if (playerInstance && typeof playerInstance.render === 'function') {
          playerInstance.render()
        }
      })
      resizeObserver.observe(containerRef.value)
    }
  } catch (err) {
    console.error('[AsciinemaPlayer] Failed to instantiate asciinema-player:', err)
  }
}

function teardownPlayer() {
  if (resizeObserver) {
    resizeObserver.disconnect()
    resizeObserver = null
  }
  if (playerInstance) {
    if (typeof playerInstance.dispose === 'function') {
      playerInstance.dispose()
    }
    playerInstance = null
  }
  if (containerRef.value) {
    containerRef.value.innerHTML = ''
  }
}

async function jumpToChapter(idx: number) {
  if (!playerInstance || idx < 0 || idx >= chapters.value.length) return
  activeChapterIdx.value = idx
  hitChapterIdx.value = -1
  await playerInstance.seek(chapters.value[idx].playTime)
}

function stepChapter(delta: number) {
  if (!chapters.value.length) return
  const target = Math.max(0, Math.min(chapters.value.length - 1, (activeChapterIdx.value < 0 ? 0 : activeChapterIdx.value + delta)))
  jumpToChapter(target)
}

function togglePlay() {
  if (!playerInstance) return
  if (isPlaying.value) playerInstance.pause()
  else playerInstance.play()
}

function handleKeydown(e: KeyboardEvent) {
  const tag = (e.target as HTMLElement | null)?.tagName
  if (tag && ['INPUT', 'SELECT', 'TEXTAREA'].includes(tag)) return
  if (e.key === '[') {
    e.preventDefault()
    e.stopPropagation()
    stepChapter(-1)
  } else if (e.key === ']') {
    e.preventDefault()
    e.stopPropagation()
    stepChapter(1)
  } else if (e.key === 'p' || e.key === 'P') {
    e.preventDefault()
    e.stopPropagation()
    togglePlay()
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
  nextTick(() => {
    initPlayer()
  })
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
  teardownPlayer()
})

defineExpose({
  chapters,
  activeChapterIdx,
  hitChapterIdx,
  isPlaying,
  statusText,
  statusMode,
  jumpToChapter,
  stepChapter,
  togglePlay,
})

// Reinitialize when source, theme, fit, or speed changes reactively
watch(
  () => [props.src, props.theme, props.fit, props.speed],
  () => {
    initPlayer()
  }
)
</script>

<template>
  <div class="asciinema-player-wrapper">
    <div v-if="showChapterBar && chapters.length > 0" class="asciinema-chapter-bar">
      <div class="asciinema-chapter-pills">
        <button
          v-for="(ch, idx) in chapters"
          :key="ch.index"
          type="button"
          class="asciinema-chapter-pill"
          :class="{
            hit: idx === hitChapterIdx,
            active: idx === activeChapterIdx && idx !== hitChapterIdx,
          }"
          @click="jumpToChapter(idx)"
        >
          <span>{{ ch.label }}</span>
          <span class="asciinema-chapter-time">{{ formatTime(ch.playTime) }}</span>
        </button>
      </div>
      <div class="asciinema-chapter-controls">
        <span class="asciinema-status-pill" :class="statusMode">{{ statusText }}</span>
        <button type="button" class="asciinema-ctrl-btn" title="Prev Stop Point ([)" @click="stepChapter(-1)">◀</button>
        <button type="button" class="asciinema-ctrl-btn primary" title="Play / Resume (p)" @click="togglePlay">
          {{ isPlaying ? '⏸ Pause' : '▶ Resume' }}
        </button>
        <button type="button" class="asciinema-ctrl-btn" title="Next Stop Point (])" @click="stepChapter(1)">▶</button>
      </div>
    </div>
    <div ref="containerRef" class="asciinema-player-element" />
    <div v-if="speed && speed !== 1" class="asciinema-speed-hint">
      Playback speed: {{ speed }}x · Keys: [ prev · ] next · p play/pause
    </div>
  </div>
</template>

<style scoped>
.asciinema-player-wrapper {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background-color: transparent;
}

.asciinema-chapter-bar {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
  flex-wrap: wrap;
  margin-bottom: 0.5rem;
  flex-shrink: 0;
}

.asciinema-chapter-pills {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  flex-wrap: wrap;
}

.asciinema-chapter-pill {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  font-size: 0.7rem;
  padding: 0.2rem 0.55rem;
  border-radius: 9999px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.03);
  color: #9ca3af;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
}

.asciinema-chapter-pill.active {
  background: rgba(122, 162, 247, 0.16);
  border-color: #7aa2f7;
  color: #ffffff;
  font-weight: 600;
}

.asciinema-chapter-pill.hit {
  background: rgba(251, 191, 36, 0.16);
  border-color: #fbbf24;
  color: #fbbf24;
  font-weight: 700;
}

.asciinema-chapter-time {
  opacity: 0.65;
  font-size: 0.65rem;
}

.asciinema-chapter-controls {
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.asciinema-status-pill {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  font-size: 0.7rem;
  padding: 0.2rem 0.55rem;
  border-radius: 9999px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: #9ca3af;
}

.asciinema-status-pill.paused-marker {
  background: rgba(251, 191, 36, 0.16);
  border-color: rgba(251, 191, 36, 0.45);
  color: #fbbf24;
  font-weight: 600;
}

.asciinema-status-pill.playing {
  background: rgba(52, 211, 153, 0.15);
  border-color: rgba(52, 211, 153, 0.45);
  color: #34d399;
  font-weight: 600;
}

.asciinema-ctrl-btn {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  font-size: 0.7rem;
  padding: 0.2rem 0.5rem;
  border-radius: 0.375rem;
  border: 1px solid rgba(255, 255, 255, 0.14);
  background: #1e2029;
  color: #f3f4f6;
  cursor: pointer;
}

.asciinema-ctrl-btn.primary {
  background: #7aa2f7;
  border-color: #7aa2f7;
  color: #0b0c0f;
  font-weight: 700;
}

.asciinema-player-element {
  width: 100%;
  flex: 1;
  min-height: 0;
}

.asciinema-speed-hint {
  flex-shrink: 0;
  margin-top: 0.5rem;
  padding: 0.15rem 0.6rem;
  border-radius: 9999px;
  background-color: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.08);
  color: #9ca3af;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', monospace;
  font-size: 0.75rem;
  line-height: 1.25rem;
  letter-spacing: 0.025em;
}

/* Ensure player terminal controls match slide styling */
:deep(.asciinema-player-wrapper .ap-player) {
  border-radius: 8px;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.5), 0 8px 10px -6px rgba(0, 0, 0, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.08);
}
</style>

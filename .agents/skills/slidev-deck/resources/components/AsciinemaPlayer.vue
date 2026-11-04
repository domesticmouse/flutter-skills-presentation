<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue'
import 'asciinema-player/dist/bundle/asciinema-player.css'

export interface CastSegmentInfo {
  index: number
  fromLabel: string
  toLabel: string
  speed: number
  rawDuration: number
  cappedDuration: number
  warpedDuration: number
  startTime: number
  endTime: number
}

export interface CastChapterInfo {
  index: number
  rawTime: number
  unwarpedPlayTime: number
  playTime: number
  label: string
  inSpeed: number
  inDuration: number
  nextSpeed: number
  nextDuration: number
  segmentIndex: number
}

export interface AsciinemaPlayerProps {
  /**
   * Path to .cast file (e.g. '/casts/demo.cast'), Data URL, or remote URL
   */
  src: string
  /**
   * Slide title displayed in the chapter header bar when chapters are present
   */
  title?: string
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
   * Minimum playback speed multiplier (default: 2.0x)
   */
  speed?: number
  /**
   * Target maximum playback duration (in seconds) per segment between breakpoints (default: 30s)
   */
  maxSegmentDuration?: number
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
   * Optional chapter markers override: [timestamp, label][] or [timestamp][]
   */
  markers?: Array<number | [number, string]>
  /**
   * Pause automatically on hitting chapter markers
   */
  pauseOnMarkers?: boolean
}

const props = withDefaults(defineProps<AsciinemaPlayerProps>(), {
  title: undefined,
  cols: undefined,
  rows: undefined,
  autoPlay: false,
  preload: true,
  loop: false,
  speed: 2.0,
  maxSegmentDuration: 30.0,
  startAt: 0,
  idleTimeLimit: 2.0,
  theme: 'dracula',
  fit: 'both',
  controls: true,
  terminalFontSize: 'small',
  terminalFontFamily: "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', monospace",
  terminalLineHeight: 1.3333,
  poster: undefined,
  markers: () => [],
  pauseOnMarkers: true,
})

const containerRef = ref<HTMLDivElement | null>(null)
const chapters = ref<CastChapterInfo[]>([])
const segments = ref<CastSegmentInfo[]>([])
const activeChapterIdx = ref<number>(-1)
const hitChapterIdx = ref<number>(-1)
const currentSegmentIdx = ref<number>(0)
const isPlaying = ref<boolean>(false)
const statusText = ref<string>('Ready (Paused)')
const statusMode = ref<'' | 'playing' | 'paused-marker'>('')

let playerInstance: any = null
let resizeObserver: ResizeObserver | null = null
let speedPollTimer: ReturnType<typeof setInterval> | null = null

const currentSegment = computed<CastSegmentInfo | null>(() => {
  if (!segments.value.length) return null
  const idx = Math.max(0, Math.min(segments.value.length - 1, currentSegmentIdx.value))
  return segments.value[idx]
})

const currentSpeed = computed<number>(() => {
  return currentSegment.value ? currentSegment.value.speed : props.speed
})

function getSpeedTier(spd: number): '' | 'boosted' | 'turbo' {
  if (spd >= 10) return 'turbo'
  if (spd > props.speed) return 'boosted'
  return ''
}

function formatTime(sec: number): string {
  const s = Math.max(0, Math.floor(sec))
  const m = Math.floor(s / 60)
  const rem = s % 60
  return `${String(m).padStart(2, '0')}:${String(rem).padStart(2, '0')}`
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
 * Compiles an asciicast v3 or v2 text stream into an adaptive-speed v2 NDJSON string
 * where each segment between breakpoints runs at >= minSpeed and takes <= maxSegmentSec.
 */
function prepareCastForPlayer(
  castText: string,
  idleTimeLimitOverride: number,
  minSpeed: number,
  maxSegmentSec: number
) {
  const lines = castText.split(/\r?\n/).filter((l) => l.trim() && !l.trim().startsWith('#'))
  if (!lines.length) {
    return { v2Text: '', foundChapters: [] as CastChapterInfo[], computedSegments: [] as CastSegmentInfo[] }
  }

  const header = JSON.parse(lines[0])
  const version = Number(header.version || 2)
  const idleCap = Number(idleTimeLimitOverride || header.idle_time_limit || 2.0)

  interface RawEventItem {
    dt: number
    cappedDt: number
    code: string
    payload: string
    rawAbs: number
  }

  interface RawSegmentBucket {
    fromLabel: string
    toLabel: string
    markerLabel: string | null
    isMarkerEnd: boolean
    rawEndTime: number
    events: RawEventItem[]
  }

  const rawSegments: RawSegmentBucket[] = []
  let currentEvents: RawEventItem[] = []
  let prevRaw = 0.0
  let rawAbs = 0.0
  let fromLabel = '0. Start'

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
      dt = Math.max(0.0, rawAbs - prevRaw)
      prevRaw = rawAbs
    }
    const cappedDt = code === 'x' ? dt : Math.min(dt, idleCap)

    if (code === 'm') {
      const markerLabel = payload || `Marker ${rawSegments.length + 1}`
      rawSegments.push({
        fromLabel,
        toLabel: markerLabel,
        markerLabel,
        isMarkerEnd: true,
        rawEndTime: rawAbs,
        events: currentEvents,
      })
      currentEvents = []
      fromLabel = markerLabel
    } else if (code !== 'x') {
      currentEvents.push({ dt, cappedDt, code, payload, rawAbs })
    }
  }

  if (currentEvents.length > 0) {
    rawSegments.push({
      fromLabel,
      toLabel: 'End',
      markerLabel: null,
      isMarkerEnd: false,
      rawEndTime: rawAbs,
      events: currentEvents,
    })
  }

  const computedSegments: CastSegmentInfo[] = []
  const foundChapters: CastChapterInfo[] = []
  let warpedAbs = 0.0
  let unwarpedCappedAbs = 0.0
  const bodyLines: string[] = []

  rawSegments.forEach((seg, segIdx) => {
    let segRawDur = 0.0
    let segCappedDur = 0.0
    seg.events.forEach((e) => {
      segRawDur += e.dt
      segCappedDur += e.cappedDt
    })

    let segSpeed = minSpeed
    if (maxSegmentSec > 0 && segCappedDur / minSpeed > maxSegmentSec) {
      segSpeed = Math.max(minSpeed, Math.ceil(segCappedDur / maxSegmentSec))
    }

    const startTime = warpedAbs
    seg.events.forEach((e) => {
      warpedAbs += e.cappedDt / segSpeed
      unwarpedCappedAbs += e.cappedDt
      bodyLines.push(JSON.stringify([Number(warpedAbs.toFixed(6)), e.code, e.payload]))
    })

    const endTime = Number(warpedAbs.toFixed(6))
    warpedAbs = endTime
    const computedSeg: CastSegmentInfo = {
      index: segIdx,
      fromLabel: seg.fromLabel,
      toLabel: seg.toLabel,
      speed: segSpeed,
      rawDuration: segRawDur,
      cappedDuration: segCappedDur,
      warpedDuration: endTime - startTime,
      startTime,
      endTime,
    }
    computedSegments.push(computedSeg)

    if (seg.isMarkerEnd && seg.markerLabel) {
      const markerTime = endTime
      bodyLines.push(JSON.stringify([markerTime, 'm', seg.markerLabel]))
      foundChapters.push({
        index: foundChapters.length,
        rawTime: seg.rawEndTime,
        unwarpedPlayTime: unwarpedCappedAbs,
        playTime: markerTime,
        label: seg.markerLabel,
        inSpeed: segSpeed,
        inDuration: computedSeg.warpedDuration,
        nextSpeed: minSpeed,
        nextDuration: 0,
        segmentIndex: segIdx,
      })
    }
  })

  foundChapters.forEach((ch, idx) => {
    const nextSeg = computedSegments[idx + 1] || computedSegments[idx]
    ch.nextSpeed = nextSeg ? nextSeg.speed : minSpeed
    ch.nextDuration = nextSeg ? nextSeg.warpedDuration : 0
  })

  const v2Header = {
    version: 2,
    width: props.cols || (header.term && header.term.cols) || header.width || 120,
    height: props.rows || (header.term && header.term.rows) || header.height || 32,
    duration: warpedAbs,
    timestamp: header.timestamp,
    env: header.env || { SHELL: '/bin/zsh' },
  }

  return {
    v2Text: [JSON.stringify(v2Header), ...bodyLines].join('\n') + '\n',
    foundChapters,
    computedSegments,
  }
}

function findSegmentIndexAtTime(playTimeSec: number): number {
  if (!segments.value.length) return 0
  for (let i = 0; i < segments.value.length; i++) {
    if (playTimeSec < segments.value[i].endTime - 0.02) {
      return i
    }
  }
  return segments.value.length - 1
}

let lastPolledTime = -1

function findChapterAtTime(playTimeSec: number, toleranceSec = 0.05): number {
  for (let i = 0; i < chapters.value.length; i++) {
    if (Math.abs(playTimeSec - chapters.value[i].playTime) <= toleranceSec) {
      return i
    }
  }
  return -1
}

function applyEndState(reason: 'ended' | 'jumped' = 'jumped') {
  const tailSegIdx = Math.max(0, segments.value.length - 1)
  const tailSeg = segments.value[tailSegIdx]
  const endTime = tailSeg ? tailSeg.endTime : 0
  activeChapterIdx.value = chapters.value.length
  hitChapterIdx.value = chapters.value.length
  currentSegmentIdx.value = tailSegIdx
  isPlaying.value = false
  lastPolledTime = endTime
  statusText.value =
    reason === 'ended'
      ? `⏹ End: ${tailSeg ? tailSeg.toLabel : 'Recording Complete'}`
      : `⏸ End: ${tailSeg ? tailSeg.toLabel : 'Recording Complete'}`
  statusMode.value = 'paused-marker'
}

async function syncLiveSpeedFromPlayer() {
  if (!playerInstance || typeof playerInstance.getCurrentTime !== 'function') return
  try {
    const t = await playerInstance.getCurrentTime()
    if (typeof t !== 'number' || Number.isNaN(t)) return
    const tailSeg = segments.value[segments.value.length - 1]
    const timeChanged = Math.abs(t - lastPolledTime) >= 0.005

    if (tailSeg && t >= tailSeg.endTime - 0.02) {
      if (activeChapterIdx.value !== chapters.value.length || isPlaying.value) {
        applyEndState(isPlaying.value ? 'ended' : 'jumped')
      }
      lastPolledTime = t
      return
    }

    if (!isPlaying.value && !timeChanged) return
    lastPolledTime = t

    if (isPlaying.value) {
      const segIdx = findSegmentIndexAtTime(t)
      currentSegmentIdx.value = segIdx
      activeChapterIdx.value = segIdx - 1
      if (segments.value[segIdx]) {
        statusText.value = `Playing (${segments.value[segIdx].speed}x)`
        statusMode.value = 'playing'
      }
    } else if (timeChanged) {
      if (t <= 0.02) {
        activeChapterIdx.value = -1
        hitChapterIdx.value = -1
        currentSegmentIdx.value = 0
        const firstSpeed = segments.value[0]?.speed ?? props.speed
        statusText.value = `Ready at 0. Start · Next: ${firstSpeed}x`
        statusMode.value = ''
        return
      }
      const matchedChapterIdx = findChapterAtTime(t)
      if (matchedChapterIdx >= 0) {
        activeChapterIdx.value = matchedChapterIdx
        hitChapterIdx.value = matchedChapterIdx
        const ch = chapters.value[matchedChapterIdx]
        currentSegmentIdx.value = Math.min(segments.value.length - 1, matchedChapterIdx + 1)
        statusText.value = `⏸ Stop Point ${matchedChapterIdx + 1}/${chapters.value.length}: ${ch.label} · Next: ${ch.nextSpeed}x`
        statusMode.value = 'paused-marker'
      } else {
        const segIdx = findSegmentIndexAtTime(t)
        currentSegmentIdx.value = segIdx
        activeChapterIdx.value = segIdx - 1
        hitChapterIdx.value = -1
      }
    }
  } catch (_) {
    // Ignore transient state calls
  }
}

async function jumpToStart() {
  if (!playerInstance) return
  activeChapterIdx.value = -1
  hitChapterIdx.value = -1
  currentSegmentIdx.value = 0
  if (isPlaying.value && props.pauseOnMarkers) {
    await playerInstance.pause()
    isPlaying.value = false
  }
  const firstSpeed = segments.value[0]?.speed ?? props.speed
  if (isPlaying.value) {
    statusText.value = `Playing (${firstSpeed}x)`
    statusMode.value = 'playing'
  } else {
    statusText.value = `Ready at 0. Start · Next: ${firstSpeed}x`
    statusMode.value = ''
  }
  lastPolledTime = 0
  await playerInstance.seek(0)
}

async function jumpToChapter(idx: number) {
  if (!playerInstance || idx < 0 || idx >= chapters.value.length) return
  activeChapterIdx.value = idx
  const ch = chapters.value[idx]
  if (isPlaying.value && props.pauseOnMarkers) {
    await playerInstance.pause()
    isPlaying.value = false
  }
  hitChapterIdx.value = isPlaying.value ? -1 : idx
  currentSegmentIdx.value = Math.min(segments.value.length - 1, idx + 1)
  if (isPlaying.value) {
    statusText.value = `Playing (${ch.nextSpeed}x)`
    statusMode.value = 'playing'
  } else {
    statusText.value = `⏸ Stop Point ${idx + 1}/${chapters.value.length}: ${ch.label} · Next: ${ch.nextSpeed}x`
    statusMode.value = 'paused-marker'
  }
  lastPolledTime = ch.playTime
  await playerInstance.seek(ch.playTime)
}

async function jumpToEnd() {
  if (!playerInstance || !segments.value.length) return
  const tailSeg = segments.value[segments.value.length - 1]
  if (isPlaying.value && props.pauseOnMarkers) {
    await playerInstance.pause()
    isPlaying.value = false
  }
  applyEndState('jumped')
  await playerInstance.seek(tailSeg.endTime)
}

async function togglePlay() {
  if (!playerInstance) return
  if (isPlaying.value) {
    playerInstance.pause()
  } else {
    if (activeChapterIdx.value >= chapters.value.length && chapters.value.length > 0) {
      activeChapterIdx.value = -1
      hitChapterIdx.value = -1
      currentSegmentIdx.value = 0
      lastPolledTime = 0
      await playerInstance.seek(0)
    }
    playerInstance.play()
  }
}

function stepPrevChapter() {
  if (!chapters.value.length) return
  if (activeChapterIdx.value <= 0) {
    jumpToStart()
  } else {
    jumpToChapter(Math.min(chapters.value.length - 1, activeChapterIdx.value - 1))
  }
}

function stepNextChapter() {
  if (!chapters.value.length) return
  if (activeChapterIdx.value < chapters.value.length - 1) {
    jumpToChapter(activeChapterIdx.value + 1)
  } else {
    jumpToEnd()
  }
}

function handleStageKeydown(e: KeyboardEvent) {
  const targetTag = (e.target as HTMLElement | null)?.tagName
  if (targetTag && ['INPUT', 'SELECT', 'TEXTAREA'].includes(targetTag)) return
  if (e.key === '[') {
    e.preventDefault()
    e.stopPropagation()
    stepPrevChapter()
  } else if (e.key === ']') {
    e.preventDefault()
    e.stopPropagation()
    stepNextChapter()
  } else if (e.key === 'p' || e.key === 'P') {
    e.preventDefault()
    e.stopPropagation()
    togglePlay()
  }
}

/**
 * Cleanly initializes the player on the client DOM
 */
async function initPlayer() {
  if (typeof window === 'undefined' || !containerRef.value) return

  teardownPlayer()

  try {
    const AsciinemaPlayer = await import('asciinema-player')
    const resolvedSrc = resolveUrl(props.src)

    const resp = await fetch(resolvedSrc)
    const rawCastText = await resp.text()

    const { v2Text, foundChapters, computedSegments } = prepareCastForPlayer(
      rawCastText,
      props.idleTimeLimit,
      props.speed,
      props.maxSegmentDuration
    )

    chapters.value = foundChapters
    segments.value = computedSegments
    activeChapterIdx.value = -1
    hitChapterIdx.value = -1
    currentSegmentIdx.value = 0

    const playerOptions: Record<string, any> = {
      cols: props.cols,
      rows: props.rows,
      autoPlay: props.autoPlay,
      preload: props.preload,
      loop: props.loop,
      speed: 1,
      idleTimeLimit: 999999,
      startAt: props.startAt,
      theme: props.theme,
      fit: props.fit,
      controls: props.controls,
      terminalFontSize: props.terminalFontSize,
      terminalFontFamily: props.terminalFontFamily,
      terminalLineHeight: props.terminalLineHeight,
      poster: props.poster,
      markers: props.markers.length > 0 ? props.markers : undefined,
      pauseOnMarkers: props.pauseOnMarkers,
    }

    Object.keys(playerOptions).forEach((key) => {
      if (playerOptions[key] === undefined) delete playerOptions[key]
    })

    playerInstance = AsciinemaPlayer.create({ data: v2Text }, containerRef.value, playerOptions)
    lastPolledTime = 0

    speedPollTimer = setInterval(() => {
      syncLiveSpeedFromPlayer()
    }, 100)

    playerInstance.addEventListener('play', () => {
      isPlaying.value = true
      if (activeChapterIdx.value >= chapters.value.length) {
        activeChapterIdx.value = -1
        currentSegmentIdx.value = 0
      }
      hitChapterIdx.value = -1
      const targetSegIdx =
        activeChapterIdx.value >= 0
          ? Math.min(segments.value.length - 1, activeChapterIdx.value + 1)
          : currentSegmentIdx.value
      currentSegmentIdx.value = targetSegIdx
      const activeSpd = segments.value[targetSegIdx]?.speed ?? props.speed
      statusText.value = `Playing (${activeSpd}x)`
      statusMode.value = 'playing'
    })

    playerInstance.addEventListener('pause', async () => {
      isPlaying.value = false
      const tailSeg = segments.value[segments.value.length - 1]
      if (tailSeg && typeof playerInstance?.getCurrentTime === 'function') {
        try {
          const t = await playerInstance.getCurrentTime()
          if (typeof t === 'number' && t >= tailSeg.endTime - 0.05) {
            applyEndState('ended')
            return
          }
        } catch (_) {}
      }
      if (statusMode.value !== 'paused-marker') {
        statusText.value = 'Paused'
        statusMode.value = ''
      }
    })

    playerInstance.addEventListener('marker', ({ index, time, label }: { index: number; time: number; label: string }) => {
      activeChapterIdx.value = index
      lastPolledTime = time
      const nextSeg = segments.value[Math.min(segments.value.length - 1, index + 1)]
      if (props.pauseOnMarkers) {
        isPlaying.value = false
        hitChapterIdx.value = index
        const nextSpeedStr = nextSeg ? ` · Next: ${nextSeg.speed}x` : ''
        statusText.value = `⏸ Auto-Paused: ${label}${nextSpeedStr}`
        statusMode.value = 'paused-marker'
        if (nextSeg) {
          currentSegmentIdx.value = nextSeg.index
        }
      } else if (nextSeg) {
        currentSegmentIdx.value = nextSeg.index
      }
    })

    playerInstance.addEventListener('ended', () => {
      applyEndState('ended')
    })

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
  if (speedPollTimer) {
    clearInterval(speedPollTimer)
    speedPollTimer = null
  }
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

onMounted(() => {
  window.addEventListener('keydown', handleStageKeydown, true)
  nextTick(() => {
    initPlayer()
  })
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleStageKeydown, true)
  teardownPlayer()
})

watch(
  () => [props.src, props.theme, props.fit, props.speed, props.maxSegmentDuration, props.idleTimeLimit],
  () => {
    initPlayer()
  }
)
</script>

<template>
  <div class="asciinema-player-wrapper">
    <div ref="containerRef" class="asciinema-player-element" />

    <div class="asciinema-speed-hint" :class="getSpeedTier(currentSpeed)">
      <span>Playback speed: <strong>{{ currentSpeed }}x</strong></span>
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
  gap: 0.4rem;
}

.asciinema-player-element {
  width: 100%;
  flex: 1;
  min-height: 0;
}

.asciinema-speed-hint {
  flex-shrink: 0;
  padding: 0.18rem 0.75rem;
  border-radius: 9999px;
  background-color: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #d1d5db;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', monospace;
  font-size: 0.72rem;
  line-height: 1.2rem;
  letter-spacing: 0.02em;
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
}

.asciinema-speed-hint strong {
  color: #7aa2f7;
}

.asciinema-speed-hint.boosted strong {
  color: #fbbf24;
}

.asciinema-speed-hint.turbo strong {
  color: #fda4af;
}

:deep(.asciinema-player-wrapper .ap-player) {
  border-radius: 8px;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.5), 0 8px 10px -6px rgba(0, 0, 0, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.08);
}
</style>

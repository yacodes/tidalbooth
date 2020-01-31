:set -XOverloadedStrings
:set prompt ""
:set prompt-cont ""

import Sound.Tidal.Context

tidal <- startTidal (superdirtTarget {oLatency = 0.05, oAddress = "127.0.0.1", oPort = 57120}) (defaultConfig {cFrameTimespan = 1/5})

-- Defaults
let p = streamReplace tidal
let hush = streamHush tidal
let list = streamList tidal
let mute = streamMute tidal
let unmute = streamUnmute tidal
let solo = streamSolo tidal
let unsolo = streamUnsolo tidal
let once = streamOnce tidal
let asap = once
let nudgeAll = streamNudgeAll tidal
let all = streamAll tidal
let resetCycles = streamResetCycles tidal
let setcps = asap . cps
let xfade i = transition tidal True (Sound.Tidal.Transition.xfadeIn 4) i
let xfadeIn i t = transition tidal True (Sound.Tidal.Transition.xfadeIn t) i
let histpan i t = transition tidal True (Sound.Tidal.Transition.histpan t) i
let wait i t = transition tidal True (Sound.Tidal.Transition.wait t) i
let waitT i f t = transition tidal True (Sound.Tidal.Transition.waitT f t) i
let jump i = transition tidal True (Sound.Tidal.Transition.jump) i
let jumpIn i t = transition tidal True (Sound.Tidal.Transition.jumpIn t) i
let jumpIn' i t = transition tidal True (Sound.Tidal.Transition.jumpIn' t) i
let jumpMod i t = transition tidal True (Sound.Tidal.Transition.jumpMod t) i
let mortal i lifespan release = transition tidal True (Sound.Tidal.Transition.mortal lifespan release) i
let interpolate i = transition tidal True (Sound.Tidal.Transition.interpolate) i
let interpolateIn i t = transition tidal True (Sound.Tidal.Transition.interpolateIn t) i
let clutch i = transition tidal True (Sound.Tidal.Transition.clutch) i
let clutchIn i t = transition tidal True (Sound.Tidal.Transition.clutchIn t) i
let anticipate i = transition tidal True (Sound.Tidal.Transition.anticipate) i
let anticipateIn i t = transition tidal True (Sound.Tidal.Transition.anticipateIn t) i
let forId i t = transition tidal False (Sound.Tidal.Transition.mortalOverlay t) i

-- Routing
let d1 = p 1 . (|< orbit 0)
let d2 = p 2 . (|< orbit 1)
let d3 = p 3 . (|< orbit 2)
let d4 = p 4 . (|< orbit 3)
let d5 = p 5 . (|< orbit 4)
let d6 = p 6 . (|< orbit 5)
let d7 = p 7 . (|< orbit 6)
let d8 = p 8 . (|< orbit 7)
let d9 = p 9 . (|< orbit 8)
let d10 = p 10 . (|< orbit 9)
let d11 = p 11 . (|< orbit 10)
let d12 = p 12 . (|< orbit 11)

-- Global
let bpm i = setcps (i / 60)

-- Synthesizers parameters
let curve = pF "curve"
let feedback = pF "feedback"

-- Aliases
-- Functions
let sl = slow
let fa = fast
let ra = range
let st = struct
let de = degrade
let de' = degradeBy
let sc = scramble
let sh = shuffle

-- Higher-order functions
let ev = every
let ev' = every'

-- Control Functions
let so = sound
let sp = speed
let su = sustain
let at = attack
let ac = accelerate
let cu = curve
let fe = feedback
let or = orbit
let ga = gain
let nu = nudge
let ru = run
let ra = range
let re = repeatCycles

-- High Order Functions

-- Custom functions
-- let drop sampleName = rev $ striate' 32 (1/16) $ s sampleName # cut "-1"
-- let drop' sampleName striateL striateC = rev $ striate' striateL striateC $ s sampleName # cut "-1"
-- let rise riseLength sampleName = const $ loopAt riseLength $ rev $ striate' 64 (1/32) $ sampleName # cut "-1"
-- let dl = delay
-- let dlt = delayt
-- let dlfb = delayfb
-- let mod' a b = whenmod a (a - b)
-- let mu = (# gain 0)
-- let si = superimpose
let lsp t n = (loopAt t $ striate 32 $ s n)
let la t n = (loopAt t $ striate 32 $ s n)
-- let wm8 t = whenmod t (t - 8)
-- let wm16 t = whenmod t (t - 16)
-- let wm32 t = whenmod t (t - 32)
-- let wm64 t = whenmod t (t - 64)
-- let wm128 t = whenmod t (t - 128)
-- let rvb a = room a # size a
let over fn = superimpose $ const $ fn
let if' sw func = if sw == 0 then id else func

bpm 120

:set prompt "tidal> "

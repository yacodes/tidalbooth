// Retrieved from http:sccode.org/1-5aD
// DrumSynths SC Example — SOS Drums by Renick Bell, renick_at_gmail.com
// recipes from Gordon Reid in his Sound on Sound articles
// SOSsnare — http:www.soundonsound.com/sos/Mar02/articles/synthsecrets0302.asp
// Latch.ar(WhiteNoise.ar(0.1), Impulse.ar(nyquist * 2)) is added aliasing for effect
// Modified by Bruno Ruviaro and Josh Mitchell 8/19.
(
SynthDef(\sossnare, {
  arg out, pan, freq = 405, curve = -4, voice = 0.385, semitone = 0.452, pitch1 = 2000, resonance = 0.1, bwr = 1;

  var drumMode, drumModeEnv, snares, snareEnv, snd, p1;

  drumModeEnv = Env.perc(attackTime: 0.005, releaseTime: 0.1, level: 0.5, curve: curve).kr(doneAction: Done.freeSelf);
  drumMode = SinOsc.ar(freq: freq * 0.53, mul: drumModeEnv);
  drumMode = drumMode + SinOsc.ar(freq: freq, mul: drumModeEnv);
  drumMode = drumMode + PMOsc.ar(carfreq: Saw.ar(freq * 0.85), modfreq: freq * semitone, pmindex: voice, mul: drumModeEnv * 10);
  drumMode = drumMode * 0.25;

  snareEnv = Env.perc(attackTime: 0.005, releaseTime: 0.1, curve: curve).kr;

  snares = Latch.ar(WhiteNoise.ar(0.1), Impulse.ar(1700 * 2));
  snares = BRF.ar(in: snares, freq: 4 * pitch1, mul: 0.5, rq: resonance);
  snares = BRF.ar(in: snares, freq: 2.5 * pitch1, mul: 0.5, rq: resonance);
  snares = BRF.ar(in: snares, freq: 1.8 * pitch1, mul: 0.5, rq: resonance);
  snares = BRF.ar(in: snares, freq: pitch1, mul: snareEnv, rq: resonance);
  snares = Resonz.ar(in: snares, freq: pitch1 / 2, bwr: bwr, mul: 40);

  snd = (drumMode + snares) * 8;

  OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, drumModeEnv));
},
metadata: (
  credit: "Renick Bell",
  category: \drums,
  tags: [\pitched, \snare, \sos]
)).add;
);

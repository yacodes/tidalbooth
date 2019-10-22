// Retrieved from http://sccode.org/1-5aD
// DrumSynths SC Example - SOS Drums by Renick Bell, renick@gmail.com
// Recipes from Gordon Reid in his Sound on Sound articles
// SOShats — http:www.soundonsound.com/sos/Jun02/articles/synthsecrets0602.asp
// Modified by Bruno Ruviaro and Josh Mitchell 8/19
(
SynthDef(\soshats, {
  arg out = 0, pan = 0, freq = 220, pitch1 = 238.5, voice = 1, sustain = 0.5;

  var root, initialEnv, initialSweep, initial, bodyEnv, bodySweep, body, snd, env;

  root = Pulse.ar(freq: freq, width: 0.5, mul: 1);
  root = PMOsc.ar(carfreq: root, modfreq: freq * [1.34, 2.405, 3.09, 1.309], pmindex: pitch1 * [1, 0.22, 0.014, 0.0038]);
  root = Mix(root);

  initialEnv = Env.perc(attackTime: 0.005, releaseTime: sustain / 2, curve: -4).kr;
  initialSweep = Line.kr(start: 15000, end: 9000, dur: sustain / 2);
  initial = BPF.ar(in: root, freq: initialSweep, rq: voice, mul: initialEnv);

  bodyEnv = Env.perc(attackTime: 0.005, releaseTime: sustain / 2, curve: -4 / 2).kr;
  bodySweep = Line.kr(start: 9000, end: 12000, dur: sustain / 2);
  body = HPF.ar(in: root, freq: bodySweep, mul: bodyEnv);

  snd = (initial + body) / 4;

  env = Line.kr(start: 1, end: 1, dur: sustain);

  OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env));
},
metadata: (
  credit: "Renick Bell",
  category: \drums,
  tags: [\pitched, \hihats, \sos]
)).add;
)
// Retrieved from http:sccode.org/1-5aD
// DrumSynths SC Example - SOS Drums by Renick Bell, renick_at_gmail.com
// recipes from Gordon Reid in his Sound on Sound articles
// SOStom — http:www.soundonsound.com/sos/Mar02/articles/synthsecrets0302.asp
// Modified by Bruno Ruviaro and Josh Mitchell 8/19.
(
SynthDef(\sostoms, {
  arg out, pan, sustain = 0.5, freq = 250, voice = 0.77;

  var drumMode, drumModeEnv, stick, stickEnv, snd;

  drumModeEnv = Env.perc(attackTime: 0.005, releaseTime: sustain / 1.25, level: 0.5, curve: -6).kr(doneAction: Done.freeSelf);

  drumMode = PMOsc.ar(carfreq: Saw.ar(freq: freq * 0.9), modfreq: freq * 0.85, pmindex: voice, mul: drumModeEnv * 10);
  drumMode = drumMode + SinOsc.ar(freq: [freq, freq * 0.8], mul: drumModeEnv);
  drumMode = Mix.ar(drumMode) * 0.5;

  stick = Crackle.ar(chaosParam: 2.01);
  stickEnv = Env.perc(attackTime: 0.005, releaseTime: sustain / 5, level: 3, curve: -6).kr;

  snd = drumMode + stickEnv;
  snd = LeakDC.ar(snd);

  OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, drumModeEnv));
},
metadata: (
  credit: "Renick Bell",
  category: \drums,
  tags: [\pitched, \tom, \sos]
)).add;
)

// By Nathan Ho aka Snappizz
// http://sccode.org/1-523
SynthDef(\ek, {
  arg out = 0, pan = 0, freq = 440, sustain = 0.5;

  var body, bodyFreq, bodyAmp;
  var pop, popFreq, popAmp;
  var click, clickAmp;
  var signal;

  // Body starts midrange, quickly drops down to low freqs, and trails off
  bodyFreq = EnvGen.ar(Env([freq * 4, freq], [0.035, 0.08], curve: \exp));
  bodyAmp = EnvGen.kr(
    envelope: Env.linen(0.005, 0.1, 0.3),
    timeScale: sustain,
    doneAction: Done.freeSelf
  );
  body = SinOsc.ar(bodyFreq) * bodyAmp;

  // Pop sweeps over the midrange
  popFreq = XLine.kr(freq * 8, freq * 2, 0.02);
  popAmp = EnvGen.kr(Env.linen(0.001, 0.02, 0.001)) * 0.15;
  pop = SinOsc.ar(popFreq) * popAmp;

  // Click is spectrally rich, covering the high-freq range
  // you can use Formant, FM, noise, whatever
  clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
  click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

  signal = body + pop + click;
  signal = signal.tanh;

  OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, bodyAmp));
}).add;

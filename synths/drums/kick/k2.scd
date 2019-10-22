SynthDef(\k2, {
  arg out = 0, pan = 0, freq = 50, sustain = 0.5;

  var signal, env;

  env = EnvGen.kr(Env.perc(0.0005, sustain), doneAction: Done.freeSelf);

  signal = DC.ar(0);
  signal = signal + (HPF.ar(Hasher.ar(Sweep.ar), 1320) * Env.perc(0.003, 0.03).kr * 0.5);
  signal = signal + (SinOsc.ar(XLine.ar(750, 161, 0.02)) * Env.perc(0.0005, 0.02).kr);
  signal = signal + (SinOsc.ar(XLine.ar(freq * 3.34, freq, 0.04)));
  signal = signal.tanh;

  OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, env));
}).add;

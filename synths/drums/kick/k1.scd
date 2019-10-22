SynthDef(\k1, {
  arg out = 0, pan = 0, freq = 50, sustain = 0.5;

  var signal, env;

  env = EnvGen.kr(Env.perc(0.0001, sustain, 1, \lin), doneAction: Done.freeSelf);

  signal = DC.ar(0);
  signal = signal + (SinOsc.ar(XLine.ar(800, 400, 0.01)) * Env.perc(0.0005, 0.01).ar);
  signal = signal + (BPF.ar(Hasher.ar(Sweep.ar), XLine.ar(800, 100, 0.01), 0.6) * Env.perc(0.001, 0.02).delay(0.001).ar);
  signal = signal + (SinOsc.ar(XLine.ar(freq * 3.44, freq, 0.01)) * env);
  signal = signal.tanh;

  OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, env));
}).add;

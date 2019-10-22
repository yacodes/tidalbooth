SynthDef(\k3, {
  arg out = 0, pan = 0, freq = 50, sustain = 0.5;

  var signal, env;

  env = EnvGen.kr(Env.perc(0.0001, sustain, curve: \lin), doneAction: Done.freeSelf);
  signal = DC.ar(0);
  signal = signal + (SinOsc.ar(XLine.ar(1500, 800, 0.01)) * Env.perc(0.0005, 0.01, curve: \lin).ar);
  signal = signal + (BPF.ar(Impulse.ar(0) * SampleRate.ir / 48000, 6100, 1.0) * 3.dbamp);
  signal = signal + (BPF.ar(Hasher.ar(Sweep.ar), 300, 0.9) * Env.perc(0.001, 0.02).ar);
  signal = signal + (SinOsc.ar(XLine.ar(freq * 7.867, freq, 0.045)));
  signal = signal.tanh;

  OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, env));
}).add;

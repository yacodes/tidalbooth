SynthDef(\gabberkick, {
  arg out = 0, pan = 0, freq = 54, sustain = 0.5, pitch1 = 1000;

  var signal, low, hi, env;

  env = EnvGen.kr(Env.new(levels: [0, 1, 0], times: [0, sustain]), doneAction: Done.freeSelf);
  signal = SinOsc.ar(freq * XLine.kr(5, 1, 0.07) * XLine.kr(1.05, 1, 0.32));
  signal = signal * Env.perc(0.01, 2.0, curve: -8).ar;
  signal = (signal * 40.dbamp).tanh;
  signal = BHiShelf.ar(signal, 200, 1, -8);
  signal = BPeakEQ.ar(signal, pitch1 * XLine.kr(1, 0.5, 0.5), 1, 15);
  signal = BPeakEQ.ar(signal, pitch1 * 1.6 * XLine.kr(1, 0.5, 0.5), 1, 8);
  signal = (signal * 6.dbamp).tanh;
  signal = signal + ((signal.sign - signal) * -20.dbamp);
  low = LPF.ar(LPF.ar(signal, 500), 500);
  hi = HPF.ar(HPF.ar(signal, 500), 500);
  hi = DelayC.ar(hi, 0.2, SinOsc.kr(2, [1.5pi, 0.5pi]).range(0, 0.001));
  hi = hi * -3.dbamp;
  signal = low + hi;
  signal = (signal * 60.dbamp).tanh / 4;
  signal = signal * env;
  OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, env));
}).add;

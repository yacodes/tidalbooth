SynthDef(\rissetBell, {
  arg out = 0, pan = 0, freq = 400, sustain = 0.5;

  var amps = #[1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33];
  var durs = #[1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075];
  var frqs = #[0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2, 2.74, 3, 3.76, 4.07];
  var dets = #[0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0];
  var env = EnvGen.kr(Env.perc(0.005, sustain), doneAction: Done.freeSelf);

  var signal = Mix.fill(11, {arg i;
    var e = Env.perc(0.005, sustain * durs[i], amps[i]).kr();
    SinOsc.ar(freq: freq * frqs[i] + dets[i], mul: e * 0.1);
  });

  OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, env));
}).add;

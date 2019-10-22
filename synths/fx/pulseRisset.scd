SynthDef(\pulseRisset, {
  arg out = 0, pan = 0, freq = 440, sustain = 2, pitch1 = 8;

  var partials, durs, amps, signal, env, ampEnv;

  partials = [246.4, 247.4, 404.8, 406.5, 523.6, 748, 880, 1206, 1320, 1654, 1791]; // original freqs
  partials = (partials / 440) * freq; // consider 440 the 'root'
  durs = [11, 10, 7, 6, 4, 3.4, 3, 2.2, 2, 1.1, 1] / 11;
  amps = durs.linlin(1, 11, 0.2, 1);

  ampEnv = EnvGen.kr(Env.perc(0.01, sustain), doneAction: Done.freeSelf);

  env = Env.perc(
    attackTime: 0.01,
    releaseTime: durs * sustain,
    level: amps
  ).kr(doneAction: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

  signal = Pulse.ar(partials) * env * 0.1 / 11;

  signal = RLPF.ar(
    in: signal,
    freq: freq * LFPulse.ar(pitch1).range(2, 4),
    rq: SinOsc.ar(LFNoise2.kr(1).range(4, 9)).range(0.1, 0.3));

    signal = LPF.ar(signal, 12000);
    signal = Limiter.ar(Mix.ar(signal)) * 64;

    OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, ampEnv));
  },
  metadata: (
    credit: "by Bruno Tucunduva Ruviaro, based on Jean-Claude Risset's bell",
    category: \bells,
    tags: [\percussion, \bell, \inharmonic]
  )
).add;

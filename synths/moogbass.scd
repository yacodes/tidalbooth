SynthDef(\moogbass, {
  arg out, sustain = 1, pan, freq = 440, n, chor = 0.7, lagamount = 0.01, coff = 2000;
  var osc, filter, env, filterenv, snd, chorusfx;

  osc = Mix(
    VarSaw.ar(
      freq: freq.lag(lagamount) * [1.0, 1.001, 2.0],
      iphase: Rand(0.0, 1.0)!3,
      width: Rand(0.5, 0.75)!3, mul: 0.5
    )
  );

  filterenv = EnvGen.ar(
    envelope: Env.new(levels: [0, 1, 0], times: [0.2, 0.2, 0.2], curve: -4),
    timeScale: sustain,
    doneAction: Done.freeSelf
  );

  filter =  MoogFF.ar(
    in: osc,
    freq: 1000 * (1.0 + (0.5 * filterenv)),
    gain: 2
  );

  env = EnvGen.ar(
    envelope: Env.new(levels: [0, 1, 1, 0.9, 0], times: [0.001, 0.001, 0.25, 0.2], curve: -4),
    timeScale: sustain,
    doneAction: Done.freeSelf
  );

  snd = (0.7 * filter + (0.3 * filter.distort)) * env;

  chorusfx = Mix.fill(7, {
    var maxdelaytime = rrand(0.005, 0.02);
    DelayC.ar(
      in: snd,
      maxdelaytime: maxdelaytime,
      delaytime: LFNoise1.kr(
        freq: Rand(4.5, 10.5),
        mul: 0.25 * maxdelaytime,
        add: 0.75 * maxdelaytime
      )
    )
  });

  snd = snd + (chorusfx * chor);

  OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env));
}).add;

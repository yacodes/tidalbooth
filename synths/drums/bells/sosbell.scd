(
SynthDef(\sosbell, {
  arg out = 0, pan = 0, freq = 440, sustain = 0.5;

  var sound, son, strike, hum, env;

  // Stretched harmonic series
  son = SinOsc.ar(#[2, 3, 4.1, 5.43, 6.8, 8.21] * freq, 0, #[1, 0.9, 0.8, 0.7, 0.6, 0.5] * 0.1);
  son = son * EnvGen.ar(Env.new([0, 1, 0.3, 0.2, 0], [0, 0.3, 0.3, 0.3]));

  // A bit of FM adds 'warble'
  son = son * LFTri.ar({Rand(1.0, 1.8)}.dup(6), 1, 0.3, 0.7);

  // Mix down the partials in the main sound
  son = son.mean;

  strike = SinOsc.ar(LFNoise1.ar(freq * 36, 100, freq * 8), 1, 0.1) * EnvGen.ar(Env.new([0, 1, 0.2, 0.1, 0], [0, 0.01, 0, 0.04]));

  env = EnvGen.ar(Env.new([0, 0.05, 0.05, 0], [sustain, sustain, 1]), doneAction: Done.freeSelf);
  hum = SinOsc.ar([freq * 1.01, freq * 0.47], 0, env).mean;
  sound = (son + strike + hum) * 8;
  sound = GVerb.ar(sound, 10, 3);

  OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan));
},
metadata: (
	credit: "by dan stowell. based on a sound-on-sound 'synth secrets' tutorial",
	tags: [\bell, \percussion, \pitched, \additive]
	)
).add
)

Synth(\sosbell)

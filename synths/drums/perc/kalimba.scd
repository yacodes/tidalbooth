// By Nathan Ho aka Snappiz
// http://sccode.org/1-51l
(
SynthDef(\kalimba, {
  arg pan = 0, out = 0, freq = 440, sustain = 0.5;

  var mix = 0.1;
  var sound = SinOsc.ar(freq); // Basic tone is SinOsc
  var env = EnvGen.ar(Env.perc(0.005, sustain, 1, -8), doneAction: Done.freeSelf);

  // The "clicking" sounds are modeled with a bank of resonators excited by enveloped pink noise
  // the resonant frequencies are randomized a little to add variation
  // there are two high resonant freqs and one quiet "bass" freq to give it some depth
  sound = (sound * (1 - mix)) + (DynKlank.ar(`[
    [240 * ExpRand(0.9, 1.1), 2020 * ExpRand(0.9, 1.1), 3151 * ExpRand(0.9, 1.1)],
    [-7, 0, 3].dbamp,
    [0.8, 0.05, 0.07]
  ], PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01))) * mix);

  OffsetOut.ar(out, DirtPan.ar(sound * 4, ~dirt.numChannels, pan, env));
}).add;
)

// Inspired:
// * https://gist.github.com/furenku/eea43c9d00a83344cee774d3c4a76190
// * https://github.com/derekxkwan/dxkSynthDefs/blob/master/dxkDrums.scd

// freq – fundamental frequency
// sweep – percentage of sweep frequency:
//     30% * 45Hz = 13.5Hz;
//     45Hz + 13.5Hz = 58.5Hz;
// sweepDur — percentage of sustain for sweep env speed:
//     min(sustain, sustain * sweepDur);
//     0.5 * 0.9 = 0.45s = 450ms for 58.5Hz to 45Hz
SynthDef(\kick, {
  | freq = 45,
    attack = 0.002, sustain = 0.5,
    sweep = 0.3, sweepDur = 0.9,
    noise = 0.1, overdrive = 0,
    amp = 1, pan = 0, out = 0 |
  var freqEnv, signal, env;

	freqEnv = EnvGen.ar(Env.perc(attack, Clip.ir(sustain * sweepDur, 0, sustain), sweep * freq, -4));
	freqEnv = (freqEnv + freq) + PinkNoise.ar(Clip.ir(noise * 100, 0, 100));
	env = EnvGen.ar(Env.perc(attack, sustain, 1, -4), doneAction: 2);

	signal = SinOsc.ar(freqEnv);
	signal = signal * env * amp;
	signal = (signal * Clip.ir(10 * overdrive, 1, 10)).tanh;
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, env));
}).add;

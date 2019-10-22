SynthDef(\cymbal808, {
	arg pan = 0, out = 0, freq = 300, sustain = 0.5;

  var freqs = [freq, freq * 1.3420, freq * 1.2312, freq * 1.6532, freq * 1.9523, freq * 2.1523];
	var signal, pulseEnv, env;

	pulseEnv = EnvGen.ar(Env.new([1.0, 0.6], [sustain], [-0.5]));
	signal = Mix.new(LFPulse.ar(freqs * 4.09));
	signal = (BinaryOpUGen('==', signal, 6.0) * 0.6) + (BinaryOpUGen('==', signal, 2.0) * 0.2) + (BinaryOpUGen('==', signal, 1.0) * 0.9); // XOR
 	signal = (signal * pulseEnv) + (Mix.new(LFPulse.ar(freqs, width:0.55)) * 0.9);
	signal = RLPF.ar(signal, 7000, 0.6);
 	signal = RHPF.ar(signal, 6800, 1.5);
	signal = RHPF.ar(signal, 6800, 1.5);
	signal = RHPF.ar(signal, 1200, 1.5);
	signal = signal + FreeVerb.ar(signal);
  env = EnvGen.ar(Env.new([0, 1, 0.4, 0, 0], [2, sustain * 250, 50, 500], [0, -0.5, 0, -50]), timeScale: (1 / 1000), doneAction: Done.freeSelf);
	signal = signal * env * 4;
	signal = [signal, DelayN.ar(signal, 0.005, 0.005)];

  OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, env));
},
metadata: (
	credit: "Published on sc-users 2007-08-25 by Ryan Brown",
	tags: ['808', \hihat, \percussion, \cymbal]
	)
).add

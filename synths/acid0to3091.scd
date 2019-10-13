// Retrieved from acid_oto309.scd
// Envelopes from original changed to ADSR, filterRange calculated in octaves
// Modified by Bruno Ruviaro and Josh Mitchell 8/19.
SynthDef(\acid0to3091, {
	arg
	// Standard Arguments
	out = 0, gate = 1, freq = 440, amp = 0.1, pan = 0, att = 0.001, dec = 0.5, sus = 0.1, rel = 0.5, curve = -4,
	// Other Controls
	// width is 0 - 1
	// filterRange is in octaves
	lagTime = 0.12, filterRange = 8, width = 0.51, rq = 0.3;

	var ampEnv, filterEnv, snd;

	freq = Lag.kr(freq, lagTime);

  ampEnv = EnvGen.kr(Env.new(
    levels: [0, amp, amp / 2, 0],
    times: [att, dec, rel],
    curve: [0, curve, curve, curve],
    offset: 1
  ), doneAction: Done.freeSelf);

  filterEnv = EnvGen.kr(Env.new(
    levels: [1, 2.pow(filterRange), 2.pow(filterRange/ 2), 1],
    times: [att, dec, rel],
    curve: [-1 * curve, curve, curve, curve],
    offset: 1
  ));

	snd = LFPulse.ar(freq: freq, width: width).range(-1, 1);

	snd = RLPF.ar(snd, freq * filterEnv, rq);

	snd = snd * ampEnv;

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "08091500Acid309 by otophilia",
	category: \bass,
	tags: [\pitched, \acid, \phat, \subtractive]
	)
).add;

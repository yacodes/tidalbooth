SynthDef(\cs80, {
  arg out = 0, pan = 0, freq = 440, attack = 0.1, decay = 0.5, sustain = 0.5, release = 1,
      accelerate = 1, voice = 0, speed = 0, lfo = 4;
	var env, fenv, vib, ffreq, sig;

  env = EnvGen.kr(
    envelope: Env.new(levels: [0, 1, sustain, 0], times: [attack, decay, release], curve: 2),
    doneAction: Done.freeSelf
  );

	vib = SinOsc.kr(lfo).range(-1 * speed, speed) + 1;
	freq = Line.kr(freq, freq * accelerate, 5);
	freq = freq * vib;

	sig = Mix.ar(Saw.ar([freq, freq *(1 + voice)], mul: env));

  OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
},
metadata: (
	credit: "Vangelis/Blade Runner lead sound, based on tutorial by meastempo @ http://www.youtube.com/watch?v=Fne0oIEv-WI",
	tags: [\lead, \modulation, \analog, \cs80, \vangelis, \bladerunner]
	)
).add

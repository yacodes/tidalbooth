
(
SynthDef(\hoover, {
    var snd, freq, bw, delay, decay;
    freq = \freq.kr(440);
    freq = freq * Env([-5, 6, 0], [0.1, 1.7], [\lin, -4]).kr.midiratio;
    bw = 1.035;
    snd = { DelayN.ar(Saw.ar(freq * ExpRand(bw, 1 / bw)) + Saw.ar(freq * 0.5 * ExpRand(bw, 1 / bw)), 0.01, Rand(0, 0.01)) }.dup(20);
    snd = (Splay.ar(snd) * 3).atan;
    snd = snd * Env.asr(0.01, 1.0, 1.0).kr(0, \gate.kr(1));
    snd = FreeVerb2.ar(snd[0], snd[1], 0.3, 0.9);
    snd = snd * Env.asr(0, 1.0, 4, 6).kr(2, \gate.kr(1));
    Out.ar(\out.kr(0), snd * \amp.kr(0.1));
}).add;
)

Synth(\hoover)
s.freeAll

s.boot


(
SynthDef(\kick,
	{
		|gate=1,t_trig=1,out=0,pan=0,amp=0.1,boost=4,attenuation=1,fmlevel = 0.5, noiselevel = 0.5, thumplevel=0.5,revlevel=0.1,revroomsize=0.8,revdamping=0.5,
		fmenvatttime=0.001,fmenvattcurve=0,fmenvdectime=0.1,fmenvdeccurve=0.3,
		noiseenvatttime=0.001,noiseenvattcurve=1,noiseenvdectime=0.1,noiseenvdeccurve=0.3,
		thumpenvatttime=0.001,thumpenvattcurve=1,thumpenvdectime=0.1,thumpenvdeccurve=0.3,
		fm1freq=292,fm2freq=838,fm3freq=393,fm1amt = 0.8,fm2amt=0.8,fmenvtofreq=0,
		noiselpf=20000,noisehpf=400,thumpenvtofreq=1,thumpcutoffmin=80,thumpcutoffmax=300,thumpfreqmultiplier=25,thumpfreqoffset=18|
		var audio, switch, fmenv, fm1, fm2, fm3, noise, noiseenv, thump, thumpenv;
		switch = Env.cutoff.kr(Done.freeSelf, gate);
		fmenv = Env([0,1,0],[fmenvatttime,fmenvdectime],[fmenvattcurve,fmenvdeccurve]).kr(Done.none, t_trig, 1, amp * fmlevel);
		fm1 = SinOsc.ar(fm1freq) * fm1amt.clip(0,1);
		fm2 = SinOsc.ar(fm2freq * fm1.exprange(0.1,10)) * fm2amt.clip(0,1);
		fm3 = SinOsc.ar(fm3freq * (fmenv * fmenvtofreq + 1) * fm2.exprange(0.1,10));
		noiseenv = Env([0,1,0],[noiseenvatttime,noiseenvdectime],[noiseenvattcurve,noiseenvdeccurve]).kr(Done.none, t_trig, 1, amp * noiselevel);
		noise = WhiteNoise.ar(noiseenv);
		noise = LPF.ar(noise,noiselpf.clip(100,20000));
		noise = HPF.ar(noise,noisehpf.clip(100,20000));
		thumpenv = Env([0,1,0],[thumpenvatttime,thumpenvdectime],[thumpenvattcurve,thumpenvdeccurve]).kr(Done.none, t_trig, 1, amp * thumplevel);
		thump = Mix((1..5).collect({
			|num|
			SinOsc.ar(0, Phasor.ar(t_trig, (thumpfreqmultiplier * num * 2 * pi + thumpfreqoffset) * (thumpenv * thumpenvtofreq + 1)/SampleRate.ir, 0, 2*pi));
		}));
		thump = LPF.ar(thump, thumpenv * (thumpcutoffmax - thumpcutoffmin) + thumpcutoffmin);
		audio = (fm3 * fmenv) + noise + (thump * thumpenv);
		audio = (audio * boost).tanh * attenuation;
		// audio = FreeVerb.ar(audio,revlevel,revroomsize,revdamping);
		audio = Pan2.ar(audio,pan);
		Out.ar(out,audio);
	}
).add;
)
Synth(\kick, [\fm1freq, 700, \noiselevel, 0.1])

(
SynthDef(\technokick, {
	| freq=51.913087197493, rel=0.28571428571429, out=0, click=0.008, spread=0.1 |

	var sig, env1, aEnv, env2, wEnv, vEnv, low, high, dry, verb, verbHi, verbLo;
	// env.ar is really good for this since thie envelopes are so short
	env1 = EnvGen.ar(Env.adsr(0,0.1,0,0, curve: -4, bias: 1)); // initial attack
	env2 = EnvGen.ar(Env.adsr(0,click,0,0,32, bias:1)); // click adder
	aEnv = EnvGen.kr(Env.perc(0.005, rel/1.75, curve: 2)); // amplitude
	wEnv = EnvGen.ar(Env.adsr(0,0.01,0,0, curve: -4));

	vEnv = EnvGen.kr(Env.adsr(rel, rel/2, 1, 0.01, curve: 3), doneAction: Done.freeSelf); // for reverb
	// separate signals for extra processing
	low  = SinOsc.ar(freq * env1 * env2);
	high = WhiteNoise.ar() * wEnv * 0.6;
	high = BBandPass.ar(high, 1000, 2);
	dry = Mix.new([low, high]) * aEnv;
	dry = CrossoverDistortion.ar(dry * 0.3, 0.9, 1);
	// dry = dry * 0.25;
	// equalizer
	dry = BPeakEQ.ar(dry, 5500, db: 10);
	dry = BPeakEQ.ar(dry, 360, db: -12, rq: 2);
	dry = BLowShelf.ar(dry, 300, db: 6).distort;
	// compression
	dry = Compander.ar(dry, dry, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 5);
	// finalize dry signal
	dry = Pan2.ar(dry * aEnv);
	// create reverb signal
	// verb = FreeVerb2.ar(dry[0],dry[1],mix: 1,room: 1, damp: 1).distort * vEnv;
	verb = GVerb.ar(dry, roomsize: 10, revtime: 5,
		damping: 0.6, drylevel: 0, earlyreflevel: 0.5, taillevel: 1,
		maxroomsize: 100, mul: 1) ;
	// Sum the double stereo output into a single stereo one
	verb = verb.sum;
	// eq

	verb = BLowPass.ar(verb, 400+freq,2);

	// Reduce stereo spread, and balance audio to be level no matter the spread (more or less)
	verbHi = BHiPass.ar(verb, 200);
	verbHi = Balance2.ar(verbHi[0] + (verbHi[1] * spread), // left
		verbHi[1] + (verbHi[0] * spread), level: 0.5 + (1-spread)); // right
	// Keep low frequencies in mono
	verbLo = BLowPass.ar(verb, 200);
	verbLo = Balance2.ar(verbLo[0] + verbLo[1], verbLo[1] + verbLo[0], level: 0.5);
	verb = verbHi + verbLo;
	verb = Compander.ar(verb,verb, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 0.25) * vEnv;
	// finalize signals
	sig = dry + verb;
	sig = Compander.ar(sig,sig, thresh: 0.5,
		slopeBelow: 0.59, slopeAbove: 1,
		clampTime: 0.002, relaxTime: 0.1, mul: 1) * 2;
	Out.ar(out, sig);
}).add;
)
Synth(\technokick, [\rel, 0.0001, \spread, 0.001])

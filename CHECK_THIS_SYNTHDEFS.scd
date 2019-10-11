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
s.freeAll

(
SynthDef(\technokick, {
	| freq=51.913087197493, amp=0.5, rel=0.28571428571429, out=0, click=0.008, spread=0.1, damp=0.6 gate=1 |
	var sig, env1, aEnv, env2, wEnv, vEnv, low, high, dry, verb, verbHi, verbLo;
	// env.ar is really good for this since thie envelopes are so short
	env1 = EnvGen.ar(Env.adsr(0,0.1,0,0, curve: -4, bias: 1)); // initial attack
	env2 = EnvGen.ar(Env.adsr(0,click,0,0,32, bias:1)); // click adder
	aEnv = EnvGen.kr(Env.perc(0.005, rel/1.75, curve: 2)); // amplitude
	wEnv = EnvGen.ar(Env.adsr(0,0.01,0,0, curve: -4));

	vEnv = EnvGen.kr(Env.adsr(rel, rel/2, 1, 0.01, curve: 3),
		gate, doneAction: Done.freeSelf); // for reverb
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
		damping: damp, drylevel: 0, earlyreflevel: 0.5, taillevel: 1,
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
		clampTime: 0.002, relaxTime: 0.1, mul: 1);
	Out.ar(out, sig);
}).add;
)


Synth(\technokick, [\rel, 0.5])

(
SynthDef(\fm7_moog_1,
{
    arg  note = 60,out_bus=0,amp=0.5,sustain = 0.5,release = 0.5,cutoff = 10000,rq = 1,pan = 0,lfo_speed = 5,lfo_amp = 0;
	var ctls, mods, chans,out,pitch,gate,
        coars1= 1 ,fine_1= 1.995 ,detun1= 39 ,noteBlok1= 0 ,
		coars2= 0.5 ,fine_2= 1.0 ,detun2= 14 ,noteBlok2= 1 ,
		coars3= 1 ,fine_3= 1.047 ,detun3= 39 ,noteBlok3= 0 ,
		coars4= 0.5 ,fine_4= 1.0 ,detun4= 1 ,noteBlok4= 1 ,
		coars5= 0.5 ,fine_5= 1.0 ,detun5= 14 ,noteBlok5= 1 ,
		coars6= 2 ,fine_6= 1.0 ,detun6= 1 ,noteBlok6= 1 ,
        envAmp1,envAmp2,envAmp3,envAmp4,envAmp5,envAmp6,env1,
		envEnv1,envEnv2,envEnv3,envEnv4,envEnv5,envEnv6,envAmp,envEnv,lfo;
        gate = Trig1.kr(1, sustain);
		envEnv1 = Env.new([0.0002 ,1.0 ,1.0 ,1.0 ,0.0002], [0.0309 ,0.0 ,0.0 ,3.2796], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
		envAmp1 = EnvGen.kr(envEnv1,gate,doneAction: 0);
		envEnv2 = Env.new([0.0001 ,0.2296 ,0.3535 ,0.2296 ,0.0001], [0.0836 ,0.185 ,3.9328 ,5.4112], [3.0 ,3.0 ,-3.0 ,-3.0],3);
		envAmp2 = EnvGen.kr(envEnv2,gate,doneAction: 0);
		envEnv3 = Env.new([0.0002 ,1.0 ,0.8414 ,0.6494 ,0.0002], [0.0348 ,0.0632 ,0.4163 ,2.8341], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
		envAmp3 = EnvGen.kr(envEnv3,gate,doneAction: 0);
		envEnv4 = Env.new([0.0 ,0.1059 ,0.2304 ,0.1496 ,0.0], [0.008 ,0.2794 ,1.8094 ,3.7047], [3.0 ,3.0 ,-3.0 ,-3.0],3);
		envAmp4 = EnvGen.kr(envEnv4,gate,doneAction: 0);
		envEnv5 = Env.new([0.0 ,0.0244 ,0.0531 ,0.0376 ,0.0], [0.0045 ,0.1397 ,1.8094 ,2.7788], [3.0 ,3.0 ,-3.0 ,-3.0],3);
		envAmp5 = EnvGen.kr(envEnv5,gate,doneAction: 0);
		envEnv6 = Env.new([0.0002 ,0.4597 ,1.0 ,0.6494 ,0.0002], [0.0136 ,0.6447 ,1.8094 ,9.5991], [3.0 ,3.0 ,-3.0 ,-3.0],3);
		envAmp6 = EnvGen.kr(envEnv6,gate,doneAction: 0);
        envEnv = Env.new([0,1,1,0], [0.0001,sustain,release],[0,0,0]);
		envAmp = EnvGen.kr(envEnv,gate,doneAction:2);
		lfo = LFTri.kr(lfo_speed);
		lfo = LinLin.ar(lfo, 0, 1, lfo_amp.neg.midiratio  , lfo_amp.midiratio);
        pitch = note.midicps;

   ctls = [
			[coars1 * fine_1 * ((pitch * noteBlok1) + ((detun1-7)/32))* lfo, 0, envAmp1],

		    [coars2 * fine_2 * ((pitch * noteBlok2) + ((detun2-7)/32))* lfo , 0, envAmp2],

		    [coars3 * fine_3 * ((pitch * noteBlok3) + ((detun3-7)/32))* lfo , 0, envAmp3],

		    [coars4 * fine_4 * ((pitch * noteBlok4) + ((detun4-7)/32))* lfo , 0, envAmp4],

		    [coars5 * fine_5 * ((pitch * noteBlok5) + ((detun5-7)/32))* lfo , 0, envAmp5],

		    [coars6 * fine_6 * ((pitch * noteBlok6) + ((detun6-7)/32))* lfo, 0, envAmp6]
	];

	mods = [
		[0, 12.5664, 0, 0, 0, 0],
		[0, 1.704, 0, 0, 0, 0],
		[0, 0, 0, 12.5664, 12.5664, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 12.5664],
		[0, 0, 0, 0, 0, 0]
	];
	chans = [0, 1, 2, 3, 4, 5];
	out = FM7.ar(ctls, mods).slice(chans) * -12.dbamp;
	out = Mix.new([
		(out[0] * 1),
		(out[1] * 0),
		(out[2] * 1),
		(out[3] * 0),
		(out[4] * 0),
		(out[5] * 0),
	]);
	out = RLPF.ar(out,cutoff,rq);
	Out.ar(out_bus,Pan2.ar(out,pan,amp));
}).add;
)

Synth(\fm7_moog_1,[\sustain,1,\release,3,\amp,0.5,\lfo_speed,5,\lfo_amp,0.05]);

(
SynthDef(\gabberkick, {
    var snd, low, hi;
    snd = SinOsc.ar(\freq.kr(54) * XLine.kr(5, 1, 0.07) * XLine.kr(1.05, 1, 0.32));
    snd = snd * Env.perc(0.01, 1.0, curve: -8, doneAction: Done.freeSelf).kr;
    snd = (snd * 40.dbamp).tanh;
    snd = BHiShelf.ar(snd, 200, 1, -8);
    snd = BPeakEQ.ar(snd, \ffreq.kr(1000) * XLine.kr(1, 0.5, 0.5), 1, 15);
    snd = BPeakEQ.ar(snd, \ffreq.kr(1000) * 1.6 * XLine.kr(1, 0.5, 0.5), 1, 8);
    snd = (snd * 6.dbamp).tanh;
    snd = snd + ((snd.sign - snd) * -20.dbamp);
    low = LPF.ar(LPF.ar(snd, 500), 500);
    hi = HPF.ar(HPF.ar(snd, 500), 500);
    hi = DelayC.ar(hi, 0.2, SinOsc.kr(2, [1.5pi, 0.5pi]).range(0, 0.001));
    hi = hi * -3.dbamp;
    snd = low + hi;
    snd = (snd * 60.dbamp).tanh;
    snd = snd * Env.asr(0, 1, 0.01).kr(Done.freeSelf, \gate.kr(1));
    Out.ar(\out.kr(0), snd * \amp.kr(0.1));
}).add;
)

Synth(\gabberkick)
s.freeAll

(
SynthDef(\gabberkick, {
    var snd, freq, high, lfo;
    freq = \freq.kr(100) * (Env.perc(0.001, 0.08, curve: -1).ar * 48 * \bend.kr(1)).midiratio;
    snd = Saw.ar(freq);
    snd = (snd * 100).tanh + ((snd.sign - snd) * -8.dbamp);
    high = HPF.ar(snd, 300);
    lfo = SinOsc.ar(8, [0, 0.5pi]).range(0, 0.01);
    high = high.dup(2) + (DelayC.ar(high, 0.01, lfo) * -2.dbamp);
    snd = LPF.ar(snd, 100).dup(2) + high;
    snd = RLPF.ar(snd, 7000, 2);
    snd = BPeakEQ.ar(snd, \ffreq.kr(3000) * XLine.kr(1, 0.8, 0.3), 0.5, 15);
    snd = snd * Env.asr(0.001, 1, 0.05).ar(2, \gate.kr(1));
    Out.ar(\out.kr(0), snd * \amp.kr(0.1));
}).add;
)



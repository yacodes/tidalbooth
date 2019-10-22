/*
Based on the example at
http://www.mcld.co.uk/cymbalsynthesis/
published 2008 by Dan Stowell
Synth(\cymbalic_mcld)
*/
(
SynthDef(\cymbalic_mcld, { |out=0, pan=0, amp=0.1|
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;

	locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3)) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
	hidriver = hidriver * EnvGen.ar(Env.perc(1, 2, 0.25));

	thwack = EnvGen.ar(Env.perc(0.001,0.001,1));

	// This bit will regenerate new freqs every time you evaluate the SynthDef!
	freqs  = {exprand(300, 20000)}.dup(100);

	res    = Ringz.ar(lodriver + hidriver + thwack, freqs).mean;

	Out.ar(out, Pan2.ar(((res * 1) + (lodriver * 2) + thwack) * amp, pan));
},
metadata: (
	credit: "Based on the example at http://www.mcld.co.uk/cymbalsynthesis/ published 2008 by Dan Stowell",
	tags: [\percussion, \cymbal, \gong, \inharmonic, \additive, \subtractive]
	)
).add
)
Synth(\cymbalic_mcld)

s.boot

(
SynthDef(\oneclap_thor, {arg out=0, t_trig=1, amp=0.1, filterfreq=100, rq=0.1, pan=0;
var env, signal, attack,Ê noise, hpf1, hpf2;
	noise = WhiteNoise.ar(1)+SinOsc.ar([filterfreq/2,filterfreq/2+4 ], pi*0.5, XLine.kr(1,0.01,4));
	//noise = PinkNoise.ar(1)+SinOsc.ar([(filterfreq)*XLine.kr(1,0.01,3), (filterfreq+4)*XLine.kr(1,0.01,3) ], pi*0.5, XLine.kr(1,0.01,4));
	//signal = signal * SinOsc.ar(1,0.75);
	hpf1 = RLPF.ar(noise, filterfreq, rq);
	hpf2 = RHPF.ar(noise, filterfreq/2, rq/4);
	env = EnvGen.kr(Env.perc(0.003, 0.00035));
	signal = (hpf1+hpf2) * env;
	signal = CombC.ar(signal, 0.5, 0.03, 0.031)+CombC.ar(signal, 0.5, 0.03016, 0.06);
	//signal = Decay2.ar(signal, 0.5);
	signal = FreeVerb.ar(signal, 0.23, 0.15, 0.2);
	Out.ar(out, Pan2.ar(signal * amp, pan));
	DetectSilence.ar(signal, doneAction:2);
},
metadata: (
	credit: "published on the sc-users list 2009-01-08 by thor",
	tags: [\clap, \handclap]
	)
).add
)
Synth(\oneclap_thor)

(
SynthDef(\kalimba, {
	//Kalimba based on bank of ressonators
    |out = 0, freq = 440, amp = 0.1, mix = 0.1, relMin = 2.5, relMax = 3.5|
    var snd;
    // Basic tone is a SinOsc
    snd = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.005, Rand(relMin, relMax), 1, -8), doneAction: 2);
    // The "clicking" sounds are modeled with a bank of resonators excited by enveloped pink noise
    snd = (snd * (1 - mix)) + (DynKlank.ar(`[
        // the resonant frequencies are randomized a little to add variation
        // there are two high resonant freqs and one quiet "bass" freq to give it some depth
        [240*ExpRand(0.9, 1.1), 2020*ExpRand(0.9, 1.1), 3151*ExpRand(0.9, 1.1)],
        [-7, 0, 3].dbamp,
        [0.8, 0.05, 0.07]
    ], PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01))) * mix);
    Out.ar(out, Pan2.ar(snd, 0, amp));
//By Nathan Ho aka Snappiz
//http://sccode.org/1-51l
}).add;
)
Synth(\kalimba)

(
SynthDef(\snare909,{ |out=0,mul=1,velocity=1|
	var excitation, membrane;

	excitation = LPF.ar(WhiteNoise.ar(1), 7040, 1) * (0.1 + velocity);
	membrane = (
		/* Two simple enveloped oscillators represent the loudest resonances of the drum membranes */
		(LFTri.ar(330,0,1) * EnvGen.ar(Env.perc(0.0005,0.055),doneAction:0) * 0.25)
		+(LFTri.ar(185,0,1) * EnvGen.ar(Env.perc(0.0005,0.075),doneAction:0) * 0.25)

		/* Filtered white noise represents the snare */
		+(excitation * EnvGen.ar(Env.perc(0.0005,0.4),doneAction:2) * 0.2)
		+(HPF.ar(excitation, 523, 1) * EnvGen.ar(Env.perc(0.0005,0.283),doneAction:0) * 0.2)

	) * mul;
	Out.ar(out, membrane!2)
}).add;
)
Synth(\snare909)

(
SynthDef(\neurosnare, {
    var snd;
    // a percussive click to give it some attack
    snd = LPF.ar(HPF.ar(WhiteNoise.ar, 300), 8000) * Env.linen(0.001, 0.01, 0.001).ar;
    // sine sweep body. very important!
    snd = snd + (SinOsc.ar(Env([400, 196, 160], [0.04, 0.2], \exp).ar) * Env.perc(0.04, 0.2).ar * 6.dbamp).tanh;
    // sound of snare coils rattling
    snd = snd + (HPF.ar(BPeakEQ.ar(WhiteNoise.ar, 4000, 0.5, 3), 300) * Env.perc(0.05, 0.2).delay(0.01).ar(2) * -3.dbamp);
    // another sound sweep to improve the attack, optional
    snd = snd + (SinOsc.ar(XLine.kr(3000, 1500, 0.01)) * Env.perc(0.001, 0.02).ar);
    // distortion helps glue everything together and acts as a compressor
    snd = (snd * 1.4).tanh;
    snd = Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)) * 4;
    Out.ar(\out.kr(0), snd);

//By Snapizz
//http://sccode.org/1-57f

}).add;
)
Synth(\neurosnare)

(
SynthDef(\gabberkick, {
    var snd, freq, high, lfo;
    freq = \freq.kr(440) * (Env.perc(0.001, 0.08, curve: -1).ar * 48 * \bend.kr(1)).midiratio;
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

s.boot

(
SynthDef(\gabberkick, {
    var snd, low, hi;
    snd = SinOsc.ar(\freq.kr(54) * XLine.kr(5, 1, 0.07) * XLine.kr(1.05, 1, 0.32));
    snd = snd * Env.perc(0.01, 2.0, curve: -8).ar;
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

(
SynthDef(\supercross, {|out, speed=1, sustain=1, decay=0, pan, freq, accelerate=0, voice=0.0, detune=0.0,
	  pitch1=1, pitch2=2, vcoegint=0|
	var env = EnvGen.ar(Env.pairs([[0,0],[0.03,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -1), timeScale:sustain, doneAction:2);
	var basefreq1 = pitch1 * freq * Line.kr(1, 1+accelerate, sustain);
	var basefreq2 = pitch2 * freq * Line.kr(1, 1+accelerate, sustain);
	var sound, sa, sb, loop, rlo, rhi;
	rlo = 1.0 - (0.9 * vcoegint);
	rhi = 1.0 + (0.9 * vcoegint);
	loop = LocalIn.ar(1);
	basefreq1 = clip(basefreq1 * loop.range(rlo,rhi), 2, 20000); // FM mod from osc 2
	sa = SelectX.ar(voice, [
		VarSaw.ar(basefreq1, 0, 0.5) - VarSaw.ar(basefreq1+detune, 0, 0.2),
		SinOsc.ar(basefreq1+detune,0.1) * loop.range(rlo,1), // ring mod for sine,
		LFTri.ar(basefreq1, 0) + LFTri.ar(basefreq1+detune, 0.1) * 0.5,
		Pulse.ar(basefreq1+detune, LPF.ar(loop.range(rlo/2,rhi/2), 50)) * 0.5 // mod pulse width for square
	]);
	basefreq2 = clip(basefreq2 * sa.range(rlo,rhi), 2, 20000); // FM mod from osc 1
	sb = SelectX.ar(voice, [
		VarSaw.ar(basefreq2-detune, 0.2, 0.2) - VarSaw.ar(basefreq2-detune, 0.2, 0.3),
		SinOsc.ar(basefreq2-detune,0.3) * sa.range(rlo,1), // ring mod for sine
		LFTri.ar(basefreq2-detune, 0.3) + LFTri.ar(basefreq2-detune, 0.2) * 0.5,
		Pulse.ar(basefreq2-detune, LPF.ar(sa.range(rlo/2,rhi/2), 50) ) * 0.5
	]);
	LocalOut.ar(DelayN.ar(sb,0.2, Line.ar(0,0.5,sustain)/basefreq1));
    sound = sa+sb;
	sound = 0.5*LPF.ar(sound, XLine.ar(1,0.01,sustain, 12000));
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
}).add;
)


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
		clampTime: 0.002, relaxTime: 0.1, mul: 1) * 2;
	Out.ar(out, sig);
}).add;
)
Synth(\technokick)


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
Synth(\fm7_moog_1)

Synth(\fm7_moog_1,[\sustain,1,\release,3,\amp,0.5,\lfo_speed,5,\lfo_amp,0.05]);

(
SynthDef("pulseRisset", {arg freq = 440, att = 0.01, rel = 11, amp = 0.1, pan = 0, pulseFreq = 8;
    var partials, durs, amps, snd, env;
 	partials = [246.4, 247.4, 404.8, 406.5, 523.6, 748, 880, 1206, 1320, 1654, 1791]; // original freqs
	partials = (partials / 440) * freq; // consider 440 the 'root'
	durs = [11, 10, 7, 6, 4, 3.4, 3, 2.2, 2, 1.1, 1] / 11;
	amps = durs.linlin(1, 11, 0.2, 1);

	env = Env.perc(
		attackTime: att,
		releaseTime: durs * rel,
		level: amps
	).kr(doneAction: [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]); // only longest env gets doneAction: 2

	snd = Pulse.ar(partials) * env * amp / 11;

	snd = RLPF.ar(
		in: snd,
		freq: freq * LFPulse.ar(pulseFreq).range(2, 4),
		rq: SinOsc.ar(LFNoise2.kr(1).range(4, 9)).range(0.1, 0.3));

	snd = LPF.ar(snd, 12000);
	snd = Limiter.ar(Mix.ar(snd)) * 8;

	Out.ar(0, Pan2.ar(snd,pan) );
},
metadata: (
	credit: "by Bruno Tucunduva Ruviaro, based on Jean-Claude Risset's bell",
	category: \bells,
	tags: [\percussion, \bell, \inharmonic]
)
).add;
)

Synth(\pulseRisset)

(
SynthDef("rissetBell", { arg out = 0, pan = 0, freq = 400, amp = 0.1, att = 0.005, rel = 2, gate = 1;
	var amps = #[1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33];
	var durs = #[1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075];
	var frqs = #[0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2, 2.74, 3, 3.76, 4.07];
	var dets = #[0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0];
	var doneActionEnv = Env.linen(0, att+rel, 0).ar(gate: gate, doneAction: 2);
	var snd = Mix.fill(11, {arg i;
		var env = Env.perc(
			attackTime: att,
			releaseTime: rel * durs[i],
			level: amps[i],
			curve: att.explin(0.005, 4, -4.5, 0)
	).ar(gate: gate);
		SinOsc.ar(
			freq: freq * frqs[i] + dets[i],
			mul: amp * env
		);
	});
	snd = snd * doneActionEnv * 0.5;
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "based on Jean-Claude Risset's bell",
	category: \bells,
	tags: [\percussion, \bell, \inharmonic]
)
).add;
)
Synth(\rissetBell, [\freq, 220, \rel, 8])

(
SynthDef(\kick3, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(1500, 800, 0.01)) * Env.perc(0.0005, 0.01, curve: \lin).ar);
    snd = snd + (BPF.ar(Impulse.ar(0) * SampleRate.ir / 48000, 6100, 1.0) * 3.dbamp);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 300, 0.9) * Env.perc(0.001, 0.02).ar);
    snd = snd + (SinOsc.ar(XLine.ar(472, 60, 0.045)) * Env.perc(0.0001, 0.3, curve: \lin).delay(0.005).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;
)

Synth(\kick3, [amp: 0.4]);


(
SynthDef(\kick2, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (HPF.ar(Hasher.ar(Sweep.ar), 1320) * Env.perc(0.003, 0.03).ar * 0.5);
    snd = snd + (SinOsc.ar(XLine.ar(750, 161, 0.02)) * Env.perc(0.0005, 0.02).ar);
    snd = snd + (SinOsc.ar(XLine.ar(167, 52, 0.04)) * Env.perc(0.0005, 0.3).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;
)

Synth(\kick2, [amp: 0.4]);


(
SynthDef(\kick1, {
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(800, 400, 0.01)) * Env.perc(0.0005, 0.01).ar);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), XLine.ar(800, 100, 0.01), 0.6) * Env.perc(0.001, 0.02).delay(0.001).ar);
    snd = snd + (SinOsc.ar(XLine.ar(172, 50, 0.01)) * Env.perc(0.0001, 0.3, 1, \lin).delay(0.005).ar(2));
    snd = snd.tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
}).add;
)

Synth(\kick1, [amp: 0.4]);

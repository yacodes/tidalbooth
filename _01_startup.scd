s.stopRecording;
Server.default.record(numChannels: 2);
thisProcess.platform.recordingsDir
s.plotTree
s.queryAllNodes

(
  // Configuration
  ~config = (
    \channels: 8,
    \out: 0,
  );
  Server.default.options.inDevice = "Scarlett 2i4 USB";
  Server.default.options.outDevice = "Scarlett 2i4 USB";
  Server.default.options.sampleRate = 44100;
  Server.default.options.blockSize = 2**9;
  Server.default.options.hardwareBufferSize = 2**9;
  Server.default.options.numBuffers = 2**18;
  Server.default.options.memSize = 2**18;
  Server.default.options.maxNodes = 2**18;
  Server.default.options.numOutputBusChannels = ~config.channels;
  Server.default.options.numInputBusChannels = 2;

  s.waitForBoot {
    "Server booted".postln;
    ~dirt = SuperDirt(2, s);
    // ~dirt.loadSoundFiles(PathName.new("./samples").fullPath ++ "/*");

    s.sync;
    ~dirt.start(57120, 12.collect({0})); // 12 virtual channels

    // MIDI
    MIDIClient.init;
    MIDIIn.connectAll();
    ~twister = Twister(TwisterDevice(\primary, MIDIClient.sources[5]));

    // SynthDefs
    SynthDef(\pad, {
      | att = 2, sus = 0, rel = 3,
      freq = 440, detune = 0.2,
      ffmin = 500, ffmax = 2000,
      rqmin = 0.1, rqmax = 0.2,
      ffhzmin = 0.1, ffhzmax = 0.3,
      lsf = 200, ldb = 0,
      amp = 1, pan = 0, out = 0 |
      var signal, envelope;

      envelope = EnvGen.kr(
        Env([0, 1, 1, 0], [att, sus, rel], [1, 0, -1]),
        doneAction: Done.freeSelf,
      );

      signal = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio}!2);
      signal = Resonz.ar(
        signal,
        {LFNoise1.kr(
          LFNoise1.kr(4).exprange(ffhzmin, ffhzmax),
        ).exprange(ffmin, ffmax)}!2,
        {LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2,
      );
      signal = BLowShelf.ar(signal, lsf, 0.5, ldb);
      signal = FreeVerb.ar(signal, 0.5, 1, 1);
      // Stereo
      // signal = Balance2.ar(signal[0], signal[1], pan);

      // Multichannel
      // signal = Mix(signal);
      // signal = PanAz.ar(8, signal, LFNoise1.kr(0.5));
      signal = signal * envelope * amp;

      Out.ar(out, signal);
    }).add;
  };

  s.latency = 0.3;
);

~c = ControlValueEnvir(BusControlValue);
~c.use {
  ~amp.spec = [0, 1];
  ~rqmin.spec = [0.0001, 0.5];
  ~rqmax.spec = [0.01, 1];
};
~twister.rows(0, 0).knobCV = ~c.amp;
~twister.rows(0, 1).knobCV = ~c.rqmin;
~twister.rows(0, 2).knobCV = ~c.rqmax;

(
  ~pad = Pbindef(\ppad,
    \instrument, \pad,
    \dur, 2,
    \midinote, Pxrand([
      [23, 35, 54, 63, 64],
      [45, 52, 54, 59, 61, 64],
      [28, 40, 47, 56, 59, 63],
      [42, 52, 57, 61, 63],
    ], inf),
    \detune, 0.5, //~c.detune.asMap,
    \ffmin, 100,
    \ffmax, 12000,
    \rqmin, ~c.rqmin.asMap,//0.005,
    \rqmax, ~c.rqmax.asMap,//0.0075,
    \atk, 5,
    \ldb, 12,
    \amp, ~c.amp.asMap,//0.75,
    \out, ~config.out,
  ).play;
)

SynthDef(\dxkBd1, {|t_trig = 1, basefreq = 45, overdrive = 2, len=0.5, att = 0.002, fgprop =0.3, fgdprop = 0.9, noisiness=0.2, lop = 1250, amp = 1, pan = 0, out = 0|

	//fgprop = frequency glide in proportion to freq
	//fgdprop = freq glide duration in proportion to dur
	//freq = fundamental
	var freqenv, noise, main, fgdur, fgact, env;
	fgdur = Clip.ir(len * fgdprop, 0, len); //real value of fgdprop
	fgact = fgprop*basefreq; //actual hz to glide over
	freqenv = EnvGen.ar(Env.perc(att, fgdur, fgact, -4),t_trig);
	freqenv = (freqenv + basefreq) + PinkNoise.ar(noisiness);
	main = SinOsc.ar(freqenv);
	main = LPF.ar(main, lop);
	env = EnvGen.ar(Env.perc(att, len, amp, -4), t_trig, doneAction: 2);
	main = main * env;
	main = (main * overdrive).tanh;
	main = Pan2.ar(main, pan);
	Out.ar(out, main);
}).add;

Synth(\dxkBd1)


(
SynthDef(\dxkCymb808, {|t_trig = 1, basefreq = 205.35, len = 0.25, sustain = 0.5, att = 0.001, out = 0, pan = 0, amp = 1|
	var freqArray, sig1, sig2,env, sig1env, output, failsafe;
	freqArray = basefreq * [ 1, 1.4823959094229, 1.800048697346, 2.545458972486, 2.6322863403944, 3.9552471390309 ];
	sig2 = Pulse.ar(freqArray, 0.55, 0.9);
	sig2 = Mix.ar(sig2);
	sig1 = Pulse.ar(freqArray, 0.5);
	sig1 = Mix.ar(sig1);
	sig1 = ( BinaryOpUGen('==', sig1, 6) * 0.6) + ( BinaryOpUGen('==', sig1, 2)*0.2)+( BinaryOpUGen('==', sig1, 1)*0.9);
	sig1env = EnvGen.ar(Env([1.0, 1.0, 0.6], [att, len], -4), t_trig);
	env = EnvGen.ar(Env([1.0, 0.4, 0], [att, len, 0.05], -4), t_trig);
	output = sig1 + sig2;
	output = SOS.ar(output, 0.175812, 0.351623, 0.175812, 0.834059, -0.537305);
	output = SOS.ar(output, 0.669886, -1.33977, 0.669886, 0.968752, -0.710791);
	output = SOS.ar(output, 0.669886, -1.33977, 0.669886, 0.968752, -0.710791 );
	output = output * env;
	output = DelayN.ar(output, 0.005, 0.005);
	output = FreeVerb.ar(output, sustain);
	failsafe = FreeSelf.kr(Trig.kr(t_trig) * (amp <= 0));
	DetectSilence.ar(output, time: 0.01, doneAction:2);
	output = Pan2.ar(output*amp, pan);
	Out.ar(out, output);
}).add;
)
Synth(\dxkCymb808)

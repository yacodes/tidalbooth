(
  ~config = (
    device: "TC",
    channels: 2,
  );
  s.options.inDevice = ~config.device;
  s.options.outDevice = ~config.device;
  s.options.sampleRate = 44100;
  s.options.blockSize = 2**9;
  s.options.hardwareBufferSize = 2**9;
  s.options.numBuffers = 2**20;
  s.options.memSize = 2**20;
  s.options.maxNodes = 2**20;
  s.options.numOutputBusChannels = ~config.channels;
  s.options.numInputBusChannels = 0;

  s.waitForBoot {
    ~dirt = SuperDirt(2, s);
    s.sync;
    ~dirt.start(57120, 12.collect({0})); // 12 virtual channels
  };

  s.latency = 0.3;
);


(
// freq – fundamental frequency
// sweep – percentage of sweep frequency:
//     30% * 45Hz = 13.5Hz;
//     45Hz + 13.5Hz = 58.5Hz;
// sweepDur — percentage of sus for sweep env speed:
//     min(sus, sus * sweepDur);
//     0.5 * 0.9 = 0.45s = 450ms for 58.5Hz to 45Hz
SynthDef(\kick, {
  | freq = 45,
    attack = 0.002, sustain = 0.5,
    sweep = 12, sweepDur = 0.05,
    noise = 0.1, curve = -32,
    pan = 0, out = 0 |
  var freqEnv, source;

	freqEnv = Env.perc(attack, Clip.ir(sustain * sweepDur, 0, sustain), sweep * freq, curve).ar;
	freqEnv = (freqEnv + freq) + PinkNoise.ar(Clip.ir(noise * 100, 0, 100));

	source = SinOsc.ar(freqEnv);
  source = BLowShelf.ar(source, freq, 1, 12);
  source = source * 24.dbamp;
  source = Limiter.ar(source, 4);

  OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, Env.perc(attack, sustain).ar(Done.freeSelf)));
}).add;
)

Synth(\kick)


(
  QtGUI.palette = QPalette.dark;
  ~gui = ();
  ~gui[\bounds] = Rect(0, Window.screenBounds.height - 380, 380, 380);
  ~gui[\win] = Window.new("Channel strip", ~gui[\bounds]);
  ~gui[\meter] = CustomMeterView.new(s, ~gui[\win], 0@0, 2, 16);
  ~gui[\bounds].height = ~gui[\meter].view.bounds.height * 2;
  ~gui[\win].bounds = ~gui[\bounds];

  ~gui[\freqscope] = FreqScopeView(
    ~gui[\win],
    Rect(
      0,
      ~gui[\meter].view.bounds.height,
      ~gui[\win].view.bounds.width,
      200
    )
  );
  ~gui[\freqscope].background = Color(0, 0, 0, 1);
  ~gui[\freqscope].active_(true);
  ~gui[\freqscope].freqMode_(1);
  ~gui[\win].onClose_({~gui[\freqscope].kill});
  ~gui[\win].view.background = Color(0, 0, 0, 1);
  ~gui[\win].alwaysOnTop = true;
  ~gui[\win].acceptsClickThrough = true;
  ~gui[\win].front;

  ~gui;
)


(
  SynthDef(\perc, {
    | freq = 220,
      attack = 0.005, sustain = 1,
      pan = 0, out = 0 |
    var envelope, source;

    source = LocalIn.ar(2);
    source = AllpassC.ar(source, 0.01, XLine.ar(0.01, 0.001, 0.01), 0.01);
    source = OnePole.ar(source);
    source = SinOsc.ar(freq) + source;
    LocalOut.ar(source);

    envelope = Env.perc(attack, sustain).ar(doneAction: Done.freeSelf);

    source = Limiter.ar(source);
    OffsetOut.ar(out, source * envelope);
  }).add;
)
Synth(\perc)


(
SynthDef(\hh, {
  arg out = 0, pan = 0, freq = 220, pitch1 = 238.5, resonance = 1, sustain = 0.5;
  var source, envelope, bpf, hpf;

  source = Mix(PMOsc.ar(Pulse.ar(freq), freq * [1.34, 2.405, 3.09, 1.309], pitch1 * [1, 0.22, 0.014, 0.0038]));

  bpf = BPF.ar(
    source,
    XLine.kr(15000, 9000, sustain),
    Clip.ir(resonance, 0, 1),
    Env.perc(0.005, sustain, curve: -4).ar
  );

  hpf = HPF.ar(
    source,
    XLine.kr(9000, 12000, sustain),
    Env.perc(0.005, sustain, curve: -4).ar
  );

  envelope = Env.perc(0.005, sustain).ar(Done.freeSelf);

  OffsetOut.ar(out, DirtPan.ar((bpf + hpf) * (-5).dbamp, ~dirt.numChannels, pan, envelope));
},
metadata: (
  credit: "Renick Bell",
  category: \drums,
  tags: [\pitched, \hihats, \sos]
)).add;
);
Synth(\hh)
s.freeAll

(
  SynthDef(\test, {
    | freq = 440,
      attack = 0.005, sustain = 1,
      pan = 0, out = 0|
    var source, feedback, envelope;
    envelope = Env.perc(attack, sustain, 1, -4).ar(Done.freeSelf);

    feedback = LocalIn.ar(2);
    source = SinOsc.ar(freq);
    feedback = AllpassC.ar(feedback, 0.001, 0.001);
    feedback = feedback + source;
    feedback = AllpassC.ar(feedback, 0.01, 0.01);
    feedback = LPF.ar(feedback, freq * 8);
    LocalOut.ar(feedback);

    feedback = Limiter.ar(feedback);

    OffsetOut.ar(out, DirtPan.ar(feedback, ~dirt.numChannels, pan, envelope));
  }).add;
)

Synth(\test, [\freq, 400])

(
  SynthDef(\fb, {
    | freq = 440,
      attack = 0.005, sustain = 1,
      pan = 0, out = 0|
    var source, feedback, envelope;
    envelope = Env.perc(attack, sustain, 1, -12).ar(Done.freeSelf);

    feedback = LocalIn.ar(2);
    source = SawDPW.ar(freq, feedback);
    feedback = feedback + source + PinkNoise.ar(1);
    feedback = BPF.ar(feedback, freq, 0.5);
    LocalOut.ar(feedback);

    feedback = HPF.ar(feedback, 40);
    feedback = feedback * 24.dbamp;
    feedback = Limiter.ar(feedback);

    OffsetOut.ar(out, DirtPan.ar(feedback, ~dirt.numChannels, pan, envelope));
  }).add;
)
Synth(\fb, [\freq, 2000])
s.freeAll

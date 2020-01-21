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
SynthDef(\test, {
  | freq = 220, out = 0 |
  OffsetOut.ar(out, SinOsc.ar(freq!2) * Env.perc.ar(doneAction: 2));
}).add
)

(
(
// DrumSynths SC Example - SOS Drums by Renick Bell, renick@gmail.com
// recipes from Gordon Reid in his Sound on Sound articles
// SOSkick — http:www.soundonsound.com/sos/jan02/articles/synthsecrets0102.asp
// increase pitch1 and voice for interesting electronic percussion
// Adapted to SuperDirt by Aleksandr Yakunichev, hi@ya.codes
//
// midinote – controls the root note of the kick,
//            but wraped between e2 (28) and e3 (40) notes
//            to avoid unpleasant sounds
// pitch1 - controls modulation frequency in Hz (min: 0, max: SampleRate.ir / 2)
// voice - controls modulation input phase in radians (min: 0, max: your sanity)
// pitch2 - controls WhiteNoise amplitude (min: 0, max: 1)
// speed - controls WhiteNoise sweep (min: 0, max: 1)
SynthDef(\soskick, {
  arg out, pan, freq = 65, attack = 0.005, pitch1 = 0, speed = 0.3, voice = 1, sustain = 1, pitch2 = 0.00;
  var beater, source, env;

  freq = Wrap.ir(freq, 28.midicps, 52.midicps);
  env = Env.perc(attack, sustain).ar(Done.freeSelf);

  source = Line.ar(freq * 2, freq, 0.02);
  source = PMOsc.ar(source, pitch1, voice);
  source = LPF.ar(source, 1000);

  beater = WhiteNoise.ar(pitch2.clip);
  beater = HPF.ar(beater, 500);
  beater = LPF.ar(beater, XLine.ar(6000, 500, speed.clip * 0.1));
  beater = beater * Env.perc.ar;

  OffsetOut.ar(out, DirtPan.ar(BLowShelf.ar((source + beater), freq, 0.5, 6), ~dirt.numChannels, pan, env));
},
metadata: (
  credit: "Renick Bell",
  category: \drums,
  tags: [\pitched, \bass, \sos]
)).add;
);
)


(
  SynthDef(\perc, {
    | attack = 0.005, sustain = 1,
      pan = 0, out = 0 |
    var source = LocalIn.ar(2);
    source = source + WhiteNoise.ar(1);
    LocalOut.ar(source);
    OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, Env.perc(attack, sustain).ar(Done.freeSelf)));
  }).add;
)


(
SynthDef(\k, {
  | freq = 80,
    attack = 0.005, sustain = 1,
    sweep = 16, sweepDur = 0.01,
    noise = 0, overdrive = 0.1,
    pan = 0, out = 0 |
  var freqEnv, source;

	freqEnv = Env.perc(attack, Clip.ir(sustain * sweepDur, 0, sustain), sweep * freq, -4).ar;
	freqEnv = (freqEnv + freq) + PinkNoise.ar(Clip.ir(noise * 100, 0, 100));

	source = SinOsc.ar(freqEnv);
	source = (source * Clip.ir(10 * overdrive, 1, 10)).tanh;
  source = source * 24.dbamp;

  OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, Env.perc(attack, sustain).ar(Done.freeSelf)));
}).add;
)

(
SynthDef(\fs, {
  | freq = 220,
    attack = 0.01, sustain = 1,
    pan = 0, out = 0 |
  var envelope, source, feedback;
  envelope = Env.perc(attack, sustain).ar(Done.freeSelf);

  feedback = LocalIn.ar(2) * 0.99;

  source = Saw.ar(freq);

  feedback = OnePole.ar(feedback, 0.75);
  feedback = OneZero.ar(feedback, 0.2);
  feedback = AllpassC.ar(feedback, 0.01, 0.01, 0.1);
  feedback = source + feedback;
  feedback = LeakDC.ar(feedback);
  LocalOut.ar(feedback);

  OffsetOut.ar(out, DirtPan.ar(feedback, ~dirt.numChannels, pan, envelope));
}).add;
)


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

(
  ~config = (
    device: "Scarlett 2i4 USB",
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
  //     0.5 * 0.9 = 0.45s = 450ms slide from 58.5Hz to 45Hz
  SynthDef(\hick, {
    | freq = 45,
      attack = 0.002, sustain = 0.5,
      accelerate = 12, speed = 0.05,
      voice = 1, pitch1 = 0,
      pan = 0, out = 0 |
    var freqEnv, feedback, source;

    freqEnv = Env.perc(attack, Clip.ir(sustain * speed.clip(0, 0.25), 0, sustain), accelerate * freq, voice.clip(0, 1) * -32).ar;

    source = SinOsc.ar(freqEnv + freq, LocalIn.ar(2) * pitch1.clip);
    source = BLowShelf.ar(source, freq, 1, 12);
    LocalOut.ar(source);
    source = Limiter.ar(source, 2);

    OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, Env.perc(attack, sustain).ar(Done.freeSelf)));
  }).add;
)

10.clip

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

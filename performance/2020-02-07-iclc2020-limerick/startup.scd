ServerOptions.inDevices; // input devices
ServerOptions.outDevices; // output devices

(
  ~config = (
    // device: "Scarlett 2i4 USB",
    device: "Built-in Output",
    channels: 2,
  );
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
    ~dirt = SuperDirt(~config.channels, s);
    ~dirt.loadSoundFiles(File.getcwd +/+ "samples/*");
    s.sync;
    ~dirt.start(57120, 24.collect({0}));
  };

  s.latency = 0.05;
);

PathName.new(File.getcwd +/+ "samples");

// Drums
(
  SynthDef(\hick, {
    | freq = 45,
      attack = 0.002, sustain = 0.5,
      accelerate = 12, // sweep freq multiplier
      speed = 0.05, // sweep speed
      curve = -32, // envelope curve
      feedback = 0, // amount of feedback
      pan = 0, out = 0 |
    var freqEnv, source;

    freqEnv = Env.perc(attack, Clip.ir(sustain * speed.clip(0, 0.25), 0, sustain), accelerate * freq, curve).ar;

    source = SinOsc.ar(freqEnv + freq, LocalIn.ar(2) * feedback.clip);
    LocalOut.ar(source);
    source = Limiter.ar(source, 1);

    OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, Env.perc(attack, sustain).ar(Done.freeSelf)));
  }).add;
)


(
SynthDef(\cymbal, {
  | freq = 205.35,
    sustain = 0.25,
    attack = 0.001,
    curve = -16,
    pan = 0, out = 0 |

	var freqArray, sig1, sig2, env, source;
	freqArray = freq * [1, 1.4823959094229, 1.800048697346, 2.545458972486, 2.6322863403944, 3.9552471390309];
	sig2 = Pulse.ar(freqArray, 0.55, 0.9);
	sig2 = Mix.ar(sig2);
	sig1 = Pulse.ar(freqArray, 0.5);
	sig1 = Mix.ar(sig1);
	env = Env.perc(attack, sustain, curve).ar(Done.freeSelf);
	source = sig1 + sig2;
	source = SOS.ar(source, 0.175812, 0.351623, 0.175812, 0.834059, -0.537305);
	source = SOS.ar(source, 0.669886, -1.33977, 0.669886, 0.968752, -0.710791);
	source = SOS.ar(source, 0.669886, -1.33977, 0.669886, 0.968752, -0.710791);
  source = source / 128;
  source = Limiter.ar(source, 0.1);
  // source = source / 256;

  OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, env));
}).add;
)

Synth(\cymbal, [\freq, 1000])

// GUI
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

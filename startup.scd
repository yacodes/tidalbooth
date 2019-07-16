// ServerOptions.outDevices.do {|d| d.postln}
// ServerOptions.inDevices.do {|d| d.postln}

(
  // s.options.inDevice = "Scarlett 2i4 USB";
  // s.options.outDevice = "Scarlett 2i4 USB";
  // s.options.outDevice = "Soundflower (2ch)";
  s.options.outDevice = "Built-in Output";
  s.options.numBuffers = 1024 * 256;
  s.options.memSize = 8192 * 16;
  s.options.maxNodes = 1024 * 32;
  s.options.numOutputBusChannels = 64;
  s.options.numInputBusChannels = 2;

  s.waitForBoot {
    ~dirt = SuperDirt(2, s);
    ~dirt.loadSoundFiles;
    ~dirt.loadSoundFiles(PathName.new("./samples").fullPath ++ "/*");
    s.sync;
    // ~dirt.start(57120, 12.collect({|i| 2 * i})); // 12 hardware channels
    ~dirt.start(57120, 12.collect({0})); // 12 virtual channels

    (
      SynthDef.new(\kick9, {|out, pan, sustain = 2, n = 110|
        var env = EnvGen.kr(Env.perc(0.02, sustain, 1, -8), doneAction: Done.freeSelf);
        var noise = LPF.ar(WhiteNoise.ar(), Env.new([n * 10, n, 20], [0, sustain], -2).kr, mul: 5);
        var osc = Resonz.ar(SinOsc.ar(Env.new([n * 10, n, 20], [0, sustain], -1).kr), n, 0.9, mul: 1);
        var sig = Mix.new([noise, osc]);
        OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
      }).add;
    )
  };

  s.latency = 0.3;
);

// Platform.systemExtensionDir; // system extensions
// Platform.userExtensionDir; // user extensions

// Custom synth example
// (
//   SynthDef(\tutorial1, {|out, sustain=1, pan, accelerate, n |
//     var env = EnvGen.ar(Env.perc(0.001, 0.999, 1, -4), timeScale: sustain, doneAction: 2);
//     var sound = SinOsc.ar(n * Line.kr(1, 1 + accelerate, sustain));
//     OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
//   }).add
// )

// @TODO Adopt for SuperDirt
// (
//   SynthDef("kik", {|basefreq = 50, ratio = 7, sweeptime = 0.05, preamp = 1, amp = 1, decay1 = 0.3, decay1L = 0.8, decay2 = 0.15, out|
//     var fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
//         env = EnvGen.kr(Env([1, decay1L, 0], [decay1, decay2], -4), doneAction: 2),
//         sig = SinOsc.ar(fcurve, 0.5pi, preamp).distort * env * amp;
//     Out.ar(out, sig ! 2);
//   }).add;
// )

// Synth(\kik, [\basefreq, 40, \decay1, 0.9, \decay1L, 0.9, \decay2, 0.45, \sweeptime, 0.25, \ratio, 2])

// (
//   SynthDef(\tutorial1, {|out, sustain=1, pan, accelerate, n |
//     var env = EnvGen.ar(Env.perc(0.001, 0.999, 1, -4), timeScale: sustain, doneAction: 2);
//     var sound = SinOsc.ar(n * Line.kr(1, 1 + accelerate, sustain));
//     OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
//   }).add
// )

// Beautifull FreqScope
// (
// w = Window("My Analyzer", Rect(0, 20, 300, 150)); // width should be 511
// f = FreqScopeView(w, w.view.bounds);
// f.active_(true);
// f.freqMode_(1);

// w.onClose_({ f.kill }); // you must have this
// w.front;
// )
// f.active_(true);

// Stethoscope inserted inside the window
// (
// w = Window.new("my own scope", Rect(20, 20, 400, 500));
// w.view.decorator = FlowLayout(w.view.bounds);
// c = Stethoscope.new(s, view:w.view);
// w.onClose = { c.free }; // don't forget this
// w.front;
// )

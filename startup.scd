(
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
  };

  s.latency = 0.3;
);

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

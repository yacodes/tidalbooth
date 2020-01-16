(
  s.options.inDevice = "TC";
  s.options.outDevice = "TC";
  s.options.sampleRate = 44100;
  s.options.blockSize = 512;
  s.options.hardwareBufferSize = 512;
  s.options.numBuffers = 1024 * 512;
  s.options.memSize = 8192 * 16;
  s.options.maxNodes = 1024 * 32;
  s.options.numOutputBusChannels = 8;
  s.options.numInputBusChannels = 2;

  s.waitForBoot {
    ~dirt = SuperDirt(2, s);

    SynthDef(\k, {
      | freq = 45, attack = 0.002, sustain = 0.5, sweep = 0.3, sweepDur = 0.9, noise = 0.1, overdrive = 0, amp = 1, pan = 0, out = 0 |
      OffsetOut.ar(out, DirtPan.ar(
        (SinOsc.ar(EnvGen.ar(Env.perc(attack, Clip.ir(sustain * sweepDur, 0, sustain), sweep * freq, -4)) + freq + PinkNoise.ar(Clip.ir(noise * 100, 0, 100))) * amp * Clip.ir(10 * overdrive, 1, 10)).tanh,
        ~dirt.numChannels,
        pan,
        EnvGen.ar(Env.perc(attack, sustain, 1, -4), doneAction: 2)
      ));
    }).add;

    SynthDef(\hh, {
      | freq = 6000, attack = 0.01, sustain = 0.2, amp = 1, pan = 0, out = 0 |
      OffsetOut.ar(out, DirtPan.ar(HPF.ar(WhiteNoise.ar(amp), freq), ~dirt.numChannels, pan, Env.perc(attack, sustain).kr(doneAction: 2)));
    }).add;

    SynthDef(\sq, {
      | freq = 220,
        attack = 0.01, sustain = 1,
        amp = 0.5, pan = 0, out = 0 |
      var source, local;

      source = Saw.ar(freq);
      4.do({ |i| source = AllpassC.ar(source, 0.03, (i + 1) * 0.01, (i + 1) * 0.25); });

      local = LeakDC.ar(LocalIn.ar(2) * 0.99) + source;
      LocalOut.ar(local);
      local = (local * amp).tanh;

      OffsetOut.ar(out, DirtPan.ar(local, ~dirt.numChannels, pan, EnvGen.ar(Env.perc(attack, sustain), doneAction: Done.freeSelf)));
    }).add;

    SynthDef(\perc, {
      | freq = 220,
        attack = 0.01, sustain = 1,
        pan = 0, amp = 1, out = 0 |
      var feedback;

      var source = SinOsc.ar(freq);
      8.do({|i| source = AllpassC.ar(source, 0.08, (i+1) * 0.001, 0.4)});

      feedback = LeakDC.ar(Limiter.ar(OnePole.ar(AllpassC.ar(LocalIn.ar(2) * 0.9, 0.001, 0.001, 0.01), 0.75) + source));
      LocalOut.ar(feedback);

      OffsetOut.ar(out, DirtPan.ar(feedback, ~dirt.numChannels, pan, EnvGen.ar(Env.perc(attack, sustain), doneAction: Done.freeSelf)));
    }).add;

    s.sync;
    ~dirt.start(57120, 12.collect({0})); // 12 virtual channels
  };

  s.latency = 0.3;
);

"e2".notemidi
"e3".notemidi

(
SynthDef(\soskick, {
  arg out, pan, freq = 65, pitch1 = 0, speed = 0.3, voice = 1, sustain = 1, pitch2 = 0.00;
  var beater, source, env;

  freq = Wrap.ir(freq, 28.midicps, 40.midicps);
  env = Env.perc(0.005, sustain).ar(Done.freeSelf);

  source = Line.ar(freq * 2, freq, 0.02);
  source = PMOsc.ar(source, pitch1, voice);
  source = LPF.ar(source, 1000);

  beater = WhiteNoise.ar(pitch2.clip);
  beater = HPF.ar(beater, 500);
  beater = LPF.ar(beater, XLine.ar(6000, 500, speed.clip * 0.1));
  beater = beater * Env.perc.ar;

  OffsetOut.ar(out, DirtPan.ar((source + beater) * 3.dbamp, ~dirt.numChannels, pan, env));
},
metadata: (
  credit: "Renick Bell",
  category: \drums,
  tags: [\pitched, \bass, \sos]
)).add;
)

(36 + 12).midinote
Synth(\soskick, [\freq, 440, \speed, 0.001, \pitch2, 0.2])
36 + 12

36.midinote

28.midicps
36.midicps
48.midicps
"e2".notemidi
40.midinote

28.midicps
40.midicps

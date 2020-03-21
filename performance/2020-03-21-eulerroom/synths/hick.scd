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

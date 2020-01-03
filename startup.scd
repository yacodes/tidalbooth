(
  s.options.inDevice = "SC140";
  s.options.outDevice = "SC140";
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
    "./synths/drums/kick/kick.scd".load;
    s.sync;
    ~dirt.start(57120, 12.collect({0})); // 12 virtual channels
  };

  s.latency = 0.3;
);

Synth(\kick)

loadRelative
s.makeGui;

(
  s.options.numBuffers = 1024 * 256;
  s.options.memSize = 8192 * 16;
  s.options.maxNodes = 1024 * 32;
  s.options.numOutputBusChannels = 64;
  s.options.numInputBusChannels = 2;

  s.waitForBoot {
    ~dirt = SuperDirt(2, s);
    ~dirt.loadSoundFiles;
    ~dirt.loadSoundFiles(PathName.new("../samples").fullPath ++ "/*");
    s.sync;
    ~dirt.start(57120, 12.collect({|i| 2 * i})); // 12 hardware channels
    // ~dirt.start(57120, 12.collect({0})); // 12 virtual channels
  };

  s.latency = 0.3;
);

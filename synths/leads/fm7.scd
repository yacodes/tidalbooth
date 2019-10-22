SynthDef(\fm7, {
  arg out = 0, pan = 0, freq = 220, sustain = 0.5, lfo = 5;

  var ctls, mods, chans,signal,gate,

  coars1= 1 ,fine_1= 1.995 ,detun1= 39 ,noteBlok1= 0 ,
  coars2= 0.5 ,fine_2= 1.0 ,detun2= 14 ,noteBlok2= 1 ,
  coars3= 1 ,fine_3= 1.047 ,detun3= 39 ,noteBlok3= 0 ,
  coars4= 0.5 ,fine_4= 1.0 ,detun4= 1 ,noteBlok4= 1 ,
  coars5= 0.5 ,fine_5= 1.0 ,detun5= 14 ,noteBlok5= 1 ,
  coars6= 2 ,fine_6= 1.0 ,detun6= 1 ,noteBlok6= 1 ,
  envAmp1,envAmp2,envAmp3,envAmp4,envAmp5,envAmp6,env1,
  envEnv1,envEnv2,envEnv3,envEnv4,envEnv5,envEnv6,envAmp,envEnv,lfoSig;

  gate = Trig1.kr(1, sustain);
  envEnv1 = Env.new([0.0002 ,1.0 ,1.0 ,1.0 ,0.0002], [0.0309 ,0.0 ,0.0 ,3.2796], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
  envAmp1 = EnvGen.kr(envEnv1,gate,doneAction: 0);
  envEnv2 = Env.new([0.0001 ,0.2296 ,0.3535 ,0.2296 ,0.0001], [0.0836 ,0.185 ,3.9328 ,5.4112], [3.0 ,3.0 ,-3.0 ,-3.0],3);
  envAmp2 = EnvGen.kr(envEnv2,gate,doneAction: 0);
  envEnv3 = Env.new([0.0002 ,1.0 ,0.8414 ,0.6494 ,0.0002], [0.0348 ,0.0632 ,0.4163 ,2.8341], [3.0 ,-3.0 ,-3.0 ,-3.0],3);
  envAmp3 = EnvGen.kr(envEnv3,gate,doneAction: 0);
  envEnv4 = Env.new([0.0 ,0.1059 ,0.2304 ,0.1496 ,0.0], [0.008 ,0.2794 ,1.8094 ,3.7047], [3.0 ,3.0 ,-3.0 ,-3.0],3);
  envAmp4 = EnvGen.kr(envEnv4,gate,doneAction: 0);
  envEnv5 = Env.new([0.0 ,0.0244 ,0.0531 ,0.0376 ,0.0], [0.0045 ,0.1397 ,1.8094 ,2.7788], [3.0 ,3.0 ,-3.0 ,-3.0],3);
  envAmp5 = EnvGen.kr(envEnv5,gate,doneAction: 0);
  envEnv6 = Env.new([0.0002 ,0.4597 ,1.0 ,0.6494 ,0.0002], [0.0136 ,0.6447 ,1.8094 ,9.5991], [3.0 ,3.0 ,-3.0 ,-3.0],3);
  envAmp6 = EnvGen.kr(envEnv6,gate,doneAction: 0);
  envEnv = Env.new([0,1,1,0], [0.0001,sustain,0.5],[0,0,0]);
  envAmp = EnvGen.kr(envEnv,gate,doneAction:2);
  lfoSig = LFTri.kr(lfo);
  lfoSig = LinLin.ar(lfo, 0, 1, 0.neg.midiratio  , 0.midiratio);

  ctls = [
    [coars1 * fine_1 * ((freq * noteBlok1) + ((detun1-7)/32))* lfoSig, 0, envAmp1],

    [coars2 * fine_2 * ((freq * noteBlok2) + ((detun2-7)/32))* lfoSig , 0, envAmp2],

    [coars3 * fine_3 * ((freq * noteBlok3) + ((detun3-7)/32))* lfoSig , 0, envAmp3],

    [coars4 * fine_4 * ((freq * noteBlok4) + ((detun4-7)/32))* lfoSig , 0, envAmp4],

    [coars5 * fine_5 * ((freq * noteBlok5) + ((detun5-7)/32))* lfoSig , 0, envAmp5],

    [coars6 * fine_6 * ((freq * noteBlok6) + ((detun6-7)/32))* lfoSig, 0, envAmp6]
  ];

  mods = [
    [0, 12.5664, 0, 0, 0, 0],
    [0, 1.704, 0, 0, 0, 0],
    [0, 0, 0, 12.5664, 12.5664, 0],
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 12.5664],
    [0, 0, 0, 0, 0, 0]
  ];
  chans = [0, 1, 2, 3, 4, 5];
  signal = FM7.ar(ctls, mods).slice(chans) * -12.dbamp;
  signal = Mix.new([
    (signal[0] * 1),
    (signal[1] * 0),
    (signal[2] * 1),
    (signal[3] * 0),
    (signal[4] * 0),
    (signal[5] * 0),
  ]);
  signal = RLPF.ar(signal,10000,1);
  OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, envAmp));
}).add;

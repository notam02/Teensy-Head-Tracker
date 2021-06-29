MIDIIn.connectAll;

// YawPitchRoll
(
z = CC14.new(cc1: 16,  cc2: 48,  chan: 0,  fix: false,  normalizeValues: true).func_{|val| "z: ".post; val.postln };
y = CC14.new(cc1: 17,  cc2: 49,  chan: 0,  fix: false,  normalizeValues: true).func_{|val| "y: ".post; val.postln };
x = CC14.new(cc1: 18,  cc2: 50,  chan: 0,  fix: false,  normalizeValues: true).func_{|val| "x: ".post; val.postln };
)

Ndef(\sine, { Pan2.ar(SinOsc.ar(\f.kr(0.25).linexp(0.00000000001,1.0,40.0, 2500.0)), \pan.kr(0)) * 0.5 }).mold(2).play

(
z = CC14.new(cc1: 16,  cc2: 48,  chan: 0,  fix: false,  normalizeValues: true).func_{|val| 
	Ndef(\sine).set(\pan, val.linlin(0.0,1.0,-1.0,1.0).postln)
	// Ndef(\sine).set(\f, val)
};

y = CC14.new(cc1: 17,  cc2: 49,  chan: 0,  fix: false,  normalizeValues: true).func_{|val| 
};

x = CC14.new(cc1: 18,  cc2: 50,  chan: 0,  fix: false,  normalizeValues: true).func_{|val| 
	// "x: ".post; val.postln 
	Ndef(\sine).set(\f, val)
};

)
// z = CC14.new(cc1: 19,  cc2: 51,  chan: 0,  fix: false,  normalizeValues: true).func_{|val| "z: ".post; val.postln };

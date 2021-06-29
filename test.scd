MIDIIn.connectAll;
MIDIFunc.trace(true)

(
w = CC14.new(cc1: 16,  cc2: 48,  chan: 0,  fix: false,  normalizeValues: true).func_{|val| "w: ".post; val.postln };
x = CC14.new(cc1: 17,  cc2: 49,  chan: 0,  fix: false,  normalizeValues: true).func_{|val| "x: ".post; val.postln };
y = CC14.new(cc1: 18,  cc2: 50,  chan: 0,  fix: false,  normalizeValues: true).func_{|val| "y: ".post; val.postln };
z = CC14.new(cc1: 19,  cc2: 51,  chan: 0,  fix: false,  normalizeValues: true).func_{|val| "z: ".post; val.postln };
)

/*

This is an example patch for SuperCollider which uses the IEM plugins as main output fx with the Teensy Head Tracker setup to rotate the sound scene using SceneRotator and decode to headphones using BinauralDecoder.

Note that this setup will remove the plugins when you press ctrl/cmd-. to hardstop the sound.

---------------------------

DEPENDENCIES:

To make this script work, you need to install the following dependencies:

CC14 for 14 bit midi support:
Quarks.install("CC14");

And IEM plugins:
"https://plugins.iem.at/".openOS;

And then IEM's VSTPlugin extension for SuperCollider:
"https://git.iem.at/pd/vstplugin/-/releases".openOS;

*/
(

// Set the ambisonic order
~order = 7;

/**********************************************/

s.waitForBoot{
	~numChans = ((~order+1)**2).asInteger;
	~headtrackerGroup = Group.after(1);

	SynthDef(\hoainsert, { arg bus;
		var sig = VSTPlugin.ar(In.ar(bus, ~numChans), ~numChans, id: \sceneRot);
		sig = VSTPlugin.ar(sig, ~numChans, id: \binauralDec);
		ReplaceOut.ar(bus, sig);
	}).add;

	s.sync;

	~headtrackFX = VSTPluginController.collect(Synth(\hoainsert, [\bus, 0], ~headtrackerGroup, addAction:\addToTail));

	~headtrackFX.sceneRot.open("SceneRotator");
	s.sync;

	~headtrackFX.binauralDec.open("BinauralDecoder");
	s.sync;

	// Connect midi controller
	MIDIIn.connectAll;

	s.sync;
	~yawMidi = CC14.new(cc1: 16,  cc2: 48,  chan: 0,  fix: false,  normalizeValues: true);
	~yawMidi.func_({|val|
		~headtrackFX.sceneRot.set('Yaw Angle', val);
	});

	~pitchMidi = CC14.new(cc1: 17,  cc2: 49,  chan: 0,  fix: false,  normalizeValues: true);
	~pitchMidi.func_({|val|
		~headtrackFX.sceneRot.set('Pitch Angle', val);
	});

	~rollMidi = CC14.new(cc1: 18,  cc2: 50,  chan: 0,  fix: false,  normalizeValues: true);
	~rollMidi.func_({|val|
		~headtrackFX.sceneRot.set('Roll Angle', val)
	});

	// Set normalization to N3D to match ATK's format (IEM is SN3D by default)
	if(AtkHoa.format[1] == 'n3d', {
		~headtrackFX.sceneRot.set('Normalization', 0);
		~headtrackFX.binauralDec.set('Input Normalization', 0);
	})

	// Open guis
	~headtrackFX.sceneRot.gui;
	~headtrackFX.binauralDec.gui;
}
)

/*

This is an example patch for SuperCollider which uses the IEM plugins as main output fx with the Teensy Head Tracker setup to rotate the sound scene using SceneRotator and decode to headphones using BinauralDecoder.

It expects the SuperCollider user to be using ATK's ambisonics format:

AtkHoa.format;
AtkHoa.refRadius;

---------------------------

DEPENDENCIES:

To make this script work, you need to install the following dependencies:

CC14 for 14 bit midi support:
Quarks.install("CC14");

ATK
Quarks.install("atk-sc3");

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

	~iemBinDecRefRadius = 3.25;

	SynthDef(\headtracker, { |bus|
		// HOA input
		var sig = In.ar(bus, ~numChans);

		// Format exchange from ATK's HOA-format to what IEM expects (ambix) with the binauralDecoder's expected radius.
		// (for source, see https://github.com/ambisonictoolkit/atk-sc3/issues/95)
		// exchange reference radius
		sig = HoaNFCtrl.ar(
			in: sig,
			encRadius: AtkHoa.refRadius,
			decRadius: ~iemBinDecRefRadius,
			order: ~order
		);

		// exchange normalisation
		sig = HoaDecodeMatrix.ar(
			in: sig,
			hoaMatrix: HoaMatrixDecoder.newFormat(\ambix, ~order)
		);

		/*
		the resulting signal can be
		fed directly to the IEM BinauralDecoder plugin
		and is encoded as:

		Ambisonic order: 7
		Ambisonic component ordering: ACN
		Ambisonic component normalisation: SN3D
		Ambisonic reference radius: 3.25
		*/

		// This will be the SceneRotator
		sig = VSTPlugin.ar(sig, ~numChans, id: \sceneRot);

		// This will be the BinauralDecoder
		sig = VSTPlugin.ar(sig, ~numChans, id: \binauralDec);
		ReplaceOut.ar(bus, sig);
	}).add;

	s.sync;

	// This function is called every time the user presses hard stop/CMdPeriod to stop the sound
	// It respawns the synths with the VST plugins and remaps the midi controller
	~treeFunc = {
		"Adding % order ambisonics headtracker to main output".format(~order).postln;

		forkIfNeeded{
			~headtrackerGroup = Group.after(1);

			s.sync;

			/*

			Open plugins

			*/
			~headtrackFX = VSTPluginController.collect(Synth(\headtracker, [\bus, 0], ~headtrackerGroup, addAction:\addToTail));
			s.sync;

			~headtrackFX.sceneRot.open("SceneRotator");

			s.sync;
			~headtrackFX.binauralDec.open("BinauralDecoder");

			/*

			Map head tracker to scene rotator

			*/
			s.sync;
			~yawMidi = ~yawMidi ?? {CC14.new(cc1: 16,  cc2: 48,  chan: 0,  fix: true,  normalizeValues: true)};
			~yawMidi.func_({|val|
				if(~headtrackFX.sceneRot.loaded, {
					~headtrackFX.sceneRot.set('Yaw Angle', val);
				});
			});

			s.sync;
			~pitchMidi = ~pitchMidi ?? {CC14.new(cc1: 17,  cc2: 49,  chan: 0,  fix: true,  normalizeValues: true)};
			~pitchMidi.func_({|val|
				if(~headtrackFX.sceneRot.loaded,{
					~headtrackFX.sceneRot.set('Pitch Angle', val);
				});
			});

			s.sync;
			~rollMidi = ~rollMidi ?? { CC14.new(cc1: 18,  cc2: 50,  chan: 0,  fix: true,  normalizeValues: true)};
			~rollMidi.func_({|val|
				if(~headtrackFX.sceneRot.loaded,{
					~headtrackFX.sceneRot.set('Roll Angle', val)
				});
			});
		}

	};

	// This will respawn the synth on hardstop/cmd-period. Inspired by SafetyNet
	ServerTree.add(~treeFunc, Server.local);

	// Connect midi controller
	MIDIIn.connectAll;

	s.sync;
	~treeFunc.value;

	s.sync;
	~headtrackFX.sceneRot.gui;

	// Open guis
	// ~headtrackFX.binauralDec.gui;
}
)

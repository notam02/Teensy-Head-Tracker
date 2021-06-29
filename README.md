# Teensy Head Tracker

Teensy Head Tracker is a fork of IEM's [Mr Head Tracker](https://git.iem.at/DIY/MrHeadTracker). The main change is switching the hardware setup to use a Teensy to simplify things.

Teensy Head Tracker's main use case is the compensation of the user's head movement during
binaural synthesis of a 3D audio scene. Therefore, the device is mounted on
the user's headphones and provides rotation data with opposite direction.
The audio scene gets rotated using this data.

Alternatively, with the original, non-inverse rotation data the device can
be used as a controller/pointing-device for employment in live-performances
or automation-writing for 3D audio productions. Another thinkable application
is the tracking of a 3D microphone's orientation during recording for a a
posteriori stabilization of the recorded scene.

The device is designed to act as a class-compliant USB-MIDI device,
providing plug-and-play compatibility on Windows, macOS and Linux.
With the usage of 14-bit MIDI, the rotation data is provided with a resolution
high enough to be not noticeable.

The idea is to make 3D audio production tools more assessable for everyone
and allow the user to perceive a more realistic binaural playback without the
need of third party software or expensive hardware (e.g. optical tracking
system) and - above all - without the need of an expensive multichannel
audio playback system.

# Calibration process

When first put into operation, the MrHeadTracker won't start sending rotation data until a full calibration was performed.
To do so:

1. look into your desired front direction
2. press and hold the push button for longer than 1s
3. release
4. nod/tilt your head forwards
5. press the button again while looking downward.

The calibration data is saved into the EEPROM memory and has to be done only when the mounting position has changed. 

# Changing front orientation
For changing the desired front orientation just press and release the push button shortly (below 1s). 

This is useful if the sensor starts drifting.

## Using it in Reaper
Usage in REAPER

1. Enable input from device and input for control messages  for MrHeadTracker in Reaper's MIDI Devices settings. If the device doesn't appear, click Reset all MIDI devices, close and reopen the settings again.
2. Load and open the ambix-rotator Plugin (or similar plugin) to a Track (before the decoder plugin)
3. Button "Param" -> "FX parameter list" -> "Parameter modulation/MIDI link" -> Yaw/Pitch/Roll
4. Activate Checkbox "Link from MIDI or FX parameter"
5. Button "(none)" -> "MIDI" -> "CC 14-bit" -> "16/48"
6. On Track: Choose Input Signal: "Input: MIDI" -> MrHeadTracker -> All or single Channel
7. On Track: Arm Record
8. On Track: Activate Monitoring (ON)

## Changes from Mr Head Tracker

- Use Teensy (and Teensy's EEPROM and MIDI libs) instead of Arduino
- Converted to platformio project
- Use Bounce for debouncing
- Various small changes to the code


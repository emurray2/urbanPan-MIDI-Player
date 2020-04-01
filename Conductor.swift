//
//  Conductor.swift
//  SamplerDemo
//
//  Created by Shane Dunne, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import CoreMIDI
//takes in a number without a label which is the MIDINoteNumber or UInt8; takes in an argument labled semitones which is an Int; Returns a new MIDINoteNumber or UInt8
//create a constant with the value of an Int called nn which will be the note number. We use the Int function to convert the note from a UInt8 to just a regular Int
//return the new offset note, hence the formula semitones + original note, and notice that it is converted into a MIDINoteNumber Type
func offsetNote(_ note: MIDINoteNumber, semitones: Int) -> MIDINoteNumber {
    let nn = Int(note)
    return (MIDINoteNumber)(semitones + nn)
}

class Conductor {
    
    //Class methods can now be accessed using Conductor.shared.methodName()
    static let shared = Conductor()
    
    //Create a midi object referring to the class AKMIDI()
    let midi = AKMIDI()
    //Create a new sampler object of type AKAppleSampler
    var sampler: MIDIFileInstrument
    var midiFile: AKAppleSequencer!
    var midiFileConnector: AKMIDINode!

    //Demonstrate what a mod wheel does, maybe go to Couch or the High School, or just film the pedal at home, or the OP-1
    var pitchBendUpSemitones = 2
    var pitchBendDownSemitones = 2

    //Assuming that this is the default offset, where the synth will just play the note the user is playing without any offset
    var synthSemitoneOffset = 0

    init() {

        // MIDI Configure - (Methods from the AKMIDI class instance we created)
        
        /// Create set of virtual input and output MIDI ports
        midi.createVirtualPorts()
        
        ///Open midi input port by name
        midi.openInput(name: "Session 1")
        
        //Default function to open the output port
        midi.openOutput()

        // Session settings
        AKAudioFile.cleanTempDirectory()
        
        //Buffer length = amount of samples/time - quality of rendering - increases latency the more you increase it
        AKSettings.bufferLength = .medium
        
        //Log everything which happens in AudioKit
        AKSettings.enableLogging = true

        // Signal Chain
        
        //Sampler Object - Allows us to play a soundfont as an instrument
        sampler = MIDIFileInstrument()
        
        midiFile = AKAppleSequencer(fromURL: Bundle.main.url(forResource: "wii", withExtension: "mid")!)
        
        print("MIDI Tracks Number", midiFile.trackCount)
        
        //midiFile.tracks[0].clear()
        //midiFile.tracks[1].clear()
        //midiFile.tracks[2].clear()
        //midiFile.tracks[3].clear()
        //midiFile.tracks[4].clear()
        //midiFile.tracks[5].clear()
        //midiFile.tracks[6].clear()
        //midiFile.tracks[7].clear()
        //midiFile.tracks[8].clear()
        
        midiFileConnector = AKMIDINode(node: sampler)
        
        midiFile.tracks[1].setMIDIOutput(midiFileConnector.midiIn)
        
        //Set the volume property of our new sampler object

        // Set up the AKSampler
        setupSampler()

        // Set Output & Start AudioKit
        AudioKit.output = sampler
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start")
        }
        
        midiFile.play()
    }

    private func setupSampler() {
        //Example (below) of loading compressed sample files without a SFZ file
        //loadAndMapCompressedSampleFiles()

        //referred method: use SFZ file
        //You can download a small set of ready-to-use SFZ files and samples from
        // http://audiokit.io/downloads/ROMPlayerInstruments.zip
        // see loadSamples(byIndex:) below

        sampler.attackDuration = 0.01
        sampler.decayDuration = 0.1
        sampler.sustainLevel = 0.8
        sampler.releaseDuration = 0.5

        sampler.filterEnable = true
        sampler.filterCutoff = 20.0
        sampler.filterAttackDuration = 1.0
        sampler.filterDecayDuration = 1.0
        sampler.filterSustainLevel = 0.5
        sampler.filterReleaseDuration = 10.0
    }

    //We use the _ to indicate that we don't need a parameter label when calling
    //the function (not midi.addListener(listener: listener))
    func addMIDIListener(_ listener: AKMIDIListener) {
        midi.addListener(listener)
    }

    //Method to get the midi input names and returns them in an array/list of Strings
    func getMIDIInputNames() -> [String] {
        return midi.inputNames
    }

    //Method to open a specific MIDI input port by name
    func openMIDIInput(byName: String) {
        //Close all MIDI input ports which are already open
        midi.closeAllInputs()
        
        //Same as the open input function above and takes in the name from this method
        midi.openInput(name: byName)
    }

    //Method to open a specific MIDI input port by index - the number in the array
    func openMIDIInput(byIndex: Int) {
        
        //Close all MIDI input ports which are already open
        midi.closeAllInputs()
        
        //Notice how the name argument is the same, but uses indices to get the name
        midi.openInput(name: midi.inputNames[byIndex])
    }

    //Method to load a sample and takes in the index (number of samples to load). we don't load more than 4 at once, and we can't load negative samples. That doesn't make sense.
    func loadSamples(byIndex: Int) {
        
        //exit the function if the sample index is negative or greater than 3
        if byIndex < 0 || byIndex > 3 { return }

        //Access The Process Info Instance via Pointee <NSProcessInfo: Address Number>
        let info = ProcessInfo.processInfo
        
        //Access the systemUptime property which inherits from the NSProcessInfo
        //Notice we keep track of this as a constant
        let begin = info.systemUptime

        let sfzFiles = ["000_urbanPan.sfz"]
        
        
        sampler.loadSFZ(path: Bundle.main.resourcePath! + "/", fileName: sfzFiles[byIndex])
        //load the actual .wav samples
        sampler.loadSfzWithEmbeddedSpacesInSampleNames(folderPath: Bundle.main.resourcePath! + "/",
                                                       sfzFileName: sfzFiles[byIndex])
        print(info.systemUptime, "hi")
        let elapsedTime = info.systemUptime - begin
        AKLog("Time to load samples \(elapsedTime) seconds")
    }

    func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        AKLog("playNote \(note) \(velocity)")
        sampler.play(noteNumber: offsetNote(note, semitones: synthSemitoneOffset), velocity: velocity)
    }

    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        AKLog("stopNote \(note)")
        sampler.stop(noteNumber: offsetNote(note, semitones: synthSemitoneOffset))
    }

    func allNotesOff() {
        sampler.stopAllVoices()
    }

    func afterTouch(_ pressure: MIDIByte) {
    }

    func controller(_ controller: MIDIByte, value: MIDIByte) {
        switch controller {
        case AKMIDIControl.modulationWheel.rawValue:
            if sampler.filterEnable {
                sampler.filterCutoff = 1 + 19 * Double(value) / 127.0
            } else {
                sampler.vibratoDepth = 0.5 * Double(value) / 127.0
            }

        case AKMIDIControl.damperOnOff.rawValue:
            sampler.sustainPedal(pedalDown: value != 0)

        default:
            break
        }
    }

    //A MIDIWord means that it is an Unsigned 16 bit number ranging from 0 to 255 Unsigned means positive
    
    func pitchBend(_ pitchWheelValue: MIDIWord) {
        let pwValue = Double(pitchWheelValue)
        let scale = (pwValue - 8_192.0) / 8_192.0
        if scale >= 0.0 {
            sampler.pitchBend = scale * self.pitchBendUpSemitones
        } else {
            sampler.pitchBend = scale * self.pitchBendDownSemitones
        }
    }

}

class MIDIFileInstrument: AKSampler {
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        super.play(noteNumber: noteNumber, velocity: velocity)
        automateButtonPress(buttonNumber: Int(noteNumber))
        
    }
    override func stop(noteNumber: MIDINoteNumber) {
        super.stop(noteNumber: noteNumber)
        automateButtonRelease(buttonNumber: Int(noteNumber))
    }
    
    func automateButtonPress(buttonNumber: Int) {
        let panRange = 53...84
        DispatchQueue.main.async {
            if panRange.contains(buttonNumber) {
                buttonArray[Int(buttonNumber) - 53].isHighlighted = true
            }
        }
    }
    
    func automateButtonRelease(buttonNumber: Int) {
        let panRange = 53...84
        DispatchQueue.main.async {
            if panRange.contains(buttonNumber) {
                buttonArray[Int(buttonNumber) - 53].isHighlighted = false
            }
        }
    }
}

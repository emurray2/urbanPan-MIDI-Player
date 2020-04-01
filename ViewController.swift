//
//  ViewController.swift
//  urbanPan
//
//  Created by URBANSMASH pro on 29/08/2019.
//  Copyright © 2019 Play it on Pan. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

var buttonArray: [UIButton] = [UIButton]()

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet var button56: UIButton!
    @IBOutlet var button62: UIButton!
    @IBOutlet var button66: UIButton!
    @IBOutlet var button54: UIButton!
    @IBOutlet var button58: UIButton!
    @IBOutlet var button64: UIButton!
    @IBOutlet var button60: UIButton!
    @IBOutlet var button68: UIButton!
    @IBOutlet var button80: UIButton!
    @IBOutlet var button74: UIButton!
    @IBOutlet var button78: UIButton!
    @IBOutlet var button82: UIButton!
    @IBOutlet var button70: UIButton!
    @IBOutlet var button76: UIButton!
    @IBOutlet var button72: UIButton!
    @IBOutlet var button84: UIButton!
    @IBOutlet var button55: UIButton!
    @IBOutlet var button61: UIButton!
    @IBOutlet var button57: UIButton!
    @IBOutlet var button65: UIButton!
    @IBOutlet var button53: UIButton!
    @IBOutlet var button59: UIButton!
    @IBOutlet var button63: UIButton!
    @IBOutlet var button67: UIButton!
    @IBOutlet var button79: UIButton!
    @IBOutlet var button73: UIButton!
    @IBOutlet var button69: UIButton!
    @IBOutlet var button77: UIButton!
    @IBOutlet var button83: UIButton!
    @IBOutlet var button71: UIButton!
    @IBOutlet var button75: UIButton!
    @IBOutlet var button81: UIButton!
    
    
    var player : AVAudioPlayer!
    
    let sounds = ["Rest", "2-F3", "2-FS3", "2-G3", "2-GS3", "2-A3", "2-AS3", "2-B3", "2-C4", "2-CS4", "2-D4", "2-DS4", "2-E4", "2-F4", "2-FS4", "2-G4", "2-GS4", "2-A4", "2-AS4", "2-B4", "2-C5", "2-CS5", "2-D5", "2-DS5", "2-E5", "2-F5", "2-FS5", "2-G5", "2-GS5", "2-A5", "2-AS5", "2-B5", "2-C6"]
    
    var noteNum = 0
    
    let conductor = Conductor.shared
    var isPlaying = false
    var currentSound = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonArray = [self.button53, self.button54, self.button55, self.button56, self.button57, self.button58, self.button59, self.button60, self.button61,self.button62, self.button63, self.button64, self.button65, self.button66, self.button67, self.button68, self.button69, self.button70, self.button71, self.button72,self.button73, self.button74, self.button75, self.button76, self.button77, self.button78, self.button79, self.button80, self.button81, self.button82, self.button83, self.button84]
        
        conductor.midi.addListener(self)
        conductor.loadSamples(byIndex: currentSound)
    }
    
    
    @IBAction func noteReleased(_ sender: UIButton) {
        noteNum = sender.tag
//        player.currentTime = 0
        stopSound()

    }
    
    @IBAction func notePlayed(_ sender: UIButton) {
        noteNum = sender.tag
        //        player.currentTime = 0
        playSound()
        
    }
    
    func stopSound() {
        
        noteOff(note: MIDINoteNumber(noteNum))

    }
    
    func playSound() {
        
        noteOn(note: MIDINoteNumber(noteNum))
        
    }
    
    func noteOn(note: MIDINoteNumber) {
        DispatchQueue.main.async {
            self.conductor.playNote(note: note, velocity: 100, channel: 0)
        }
    }
    
    func noteOff(note: MIDINoteNumber) {
        DispatchQueue.main.async {
            self.conductor.stopNote(note: note, channel: 0)
        }
    }
    
}

extension ViewController: AKMIDIListener {
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            self.conductor.playNote(note: noteNumber, velocity: velocity, channel: channel)
        }
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            self.conductor.stopNote(note: noteNumber, channel: channel)
        }
    }
    
    // MIDI Controller input
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        AKLog("Channel: \(channel + 1) controller: \(controller) value: \(value)")
        //conductor.controller(controller, value: value)
    }
    
    // MIDI Pitch Wheel
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {
        //conductor.pitchBend(pitchWheelValue)
    }
    
    // After touch
    func receivedMIDIAfterTouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        conductor.afterTouch(pressure)
    }
    
    func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        // do nothing: silence superclass's log chatter
    }
    
    // MIDI Setup Change
    func receivedMIDISetupChange() {
        AKLog("midi setup change, midi.inputNames: \(conductor.midi.inputNames)")
        let inputNames = conductor.midi.inputNames
        inputNames.forEach { inputName in
            conductor.midi.openInput(name: inputName)
        }
    }
    
    func setSpeakersAsDefaultAudioOutput() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        }
        catch {
            // hard to imagine how we'll get this exception
            let alertController = UIAlertController(title: "Speaker Problem", message: "You may be able to hear sound using headphones.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result: UIAlertAction) -> Void in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    
    
}





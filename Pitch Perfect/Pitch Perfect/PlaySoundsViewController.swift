//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Prateek Shokeen on 3/7/15.
//  Copyright (c) 2015 Cliff O'r Cloud. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var audioPlayer:AVAudioPlayer!
    var audioEngine:AVAudioEngine!
    
    var audioFile:AVAudioFile!
    var receivedAudio:RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the Audio Player & enable Audio rate for playback speed changes
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.recordedFilePath, error: nil)
        audioPlayer.enableRate = true
        
        //Enable Audio Engine
        audioEngine = AVAudioEngine()
        
        // Initialize AudioFile from the received Audio File.
        audioFile = AVAudioFile(forReading: receivedAudio.recordedFilePath, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // <summary>
    // Method that plays the audio file at aa specified rate
    // </summary>
    func playAudioAtDefinedRate(playbackRate: Float) {
        // Stop any previous playback
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        if playbackRate >= 2.0 && playbackRate <= 0.0 {
            println("Play Back speed not within valid range")
        }
        else {
            // Set playback rate & Rewind the file
            audioPlayer.rate = playbackRate
            audioPlayer.currentTime = 0.0
            
            // Play the audio
            audioPlayer.play()
        }
    }
    
    // Action to play sound at a slower pace
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioAtDefinedRate(0.5)
    }

    //Action to play sound at a fast pace.
    @IBAction func playFastAudio(sender: UIButton) {
       playAudioAtDefinedRate(1.5)
    }
    
    // Stops All audio players.
    func stopAllAudio() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    // <summary>
    // Method that plays an audio file with defined pitch effect
    // <//summary>
    // <pitch> Takes a floating point integer to change pitch level.</pitch>
    func playAudioWithVariablePitch(pitch: Float){
        // Stop any previous playback
        stopAllAudio()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
    @IBAction func playReverbAudio(sender: UIButton) {
        // Stop any previous playback
        stopAllAudio()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var reverbEffect = AVAudioUnitReverb()
        reverbEffect.wetDryMix = 50
        audioEngine.attachNode(reverbEffect)
        
        audioEngine.connect(audioPlayerNode, to: reverbEffect, format: nil)
        audioEngine.connect(reverbEffect, to: audioEngine.outputNode, format: nil)
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        stopAllAudio()
    }
}

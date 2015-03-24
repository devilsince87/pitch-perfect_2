//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Prateek Shokeen on 3/6/15.
//  Copyright (c) 2015 Cliff O'r Cloud. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabelOutlet: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var recorderInitialized:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Enable the record button & pause buttons by default
        recordButton.enabled = true
        pauseButton.enabled = true
        
        // Hide the pause & stop buttons by default.
        stopButton.hidden = true
        pauseButton.hidden = true
        recorderInitialized = false
        
        // Show default instruction
        recordingLabelOutlet.text = "Tap to Record"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // <summary>
    // Creates a new filename for the recording based on TimeStamp
    // </summary>
    // <returns> FilePath in the form of NSURL </returns>
    func getNewTimedFilename() -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        return filePath!
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        // Disable the record button & enable the pause button if it was previously disabled
        recordButton.enabled = false
        pauseButton.enabled = true
        
        // Show the recording message
        recordingLabelOutlet.text = "Recording in progress"
        
        // Show the Stop & Pause Button
        stopButton.hidden = false
        pauseButton.hidden = false
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        // If the Audio Recorder is not initialized, then make a new audio file.
        if(!recorderInitialized) {
            let recordingFile = getNewTimedFilename()
            recorderInitialized = true
            
            audioRecorder = AVAudioRecorder(URL: recordingFile, settings: nil, error: nil)
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
        }
        
        // Start recording or resume a recording
        audioRecorder.record()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stopRecordingSegue") {
            // Declare a variable of type PlaySoundsViewController, which is our destination view, and use the segue keyword's destination property to initialize the variable with the right type.
            
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            
            let data = sender as RecordedAudio
            
            // Pass the recorded data to the destination view
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        // Pause Audio Recording
        audioRecorder.pause()
        
        recordingLabelOutlet.text = "Recording paused. \nTap Microphone to resume."
        recordingLabelOutlet.sizeToFit()

        recordButton.enabled = true
        pauseButton.enabled = false
    }
    
    @IBAction func stopRecording(sender: UIButton, forEvent event: UIEvent) {
        // Stop recording the user's voice
        audioRecorder.stop()
        
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    // <summary>
    // Function that executes right after the audio recorder finishes recording.
    // </summary>
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        //Check if recording was successful
        if(flag) {
            // Save the recorded audio
            if let title = recorder.url.lastPathComponent {
                recordedAudio = RecordedAudio(recordedFilePath: recorder.url, title: title)
                
                // Perform segue to the next scene
                self.performSegueWithIdentifier("stopRecordingSegue", sender: recordedAudio)
            }
        }
        else {
            // Show an alert that recording was unsuccessful.
            let alert = UIAlertView()
            alert.title = "Failure"
            alert.message = "Recording Failed"
            alert.addButtonWithTitle("OK")
            alert.show()
            
            // Reset to initial state.
            recordButton.enabled = true
            pauseButton.enabled = false
            pauseButton.hidden = true
            stopButton.hidden = true
        }
        
    }    
}


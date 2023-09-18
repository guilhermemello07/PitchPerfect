//
//  RecordViewController.swift
//  PitchPerfect-Project01
//
//  Created by Guilherme Mello on 17/09/23.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordLabel: UILabel!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!

    //MARK: - View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        recordingSession.requestRecordPermission { allowed in
            if allowed {
                DispatchQueue.main.async {
                    self.stopButton.isEnabled = false
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopButton.isEnabled = false
    }

    //MARK: - IBActions
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        recordLabel.text = "Recording in progress ..."
        stopButton.isEnabled = true
        recordButton.isEnabled = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let pathArray = Array([dirPath, "recordedVoice.wav"])
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        try! recordingSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        recordLabel.text = "Tap to record"
        stopButton.isEnabled = false
        recordButton.isEnabled = true
        
        audioRecorder.stop()
        
        try! recordingSession.setActive(false)
    }
    
    //MARK: - AVAudioRecorderDelegate Methods
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Finishing recording...")
            performSegue(withIdentifier: "goToPlaySounds", sender: audioRecorder.url)
        } else {
            print("Recording was not successful...")
        }
    }
    
    //MARK: - Transfer data method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlaySounds" {
            let destinationVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            destinationVC.recordedAudioURL = recordedAudioURL
        }
    }
}


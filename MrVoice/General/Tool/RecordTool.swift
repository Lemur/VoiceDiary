//
//  RecordTool.swift
//  VoiceDiary
//
//  Created by dongyixuan on 16/6/9.
//  Copyright © 2016年 Lemur. All rights reserved.
//

import Foundation
import AVFoundation
class RecordTool: NSObject, AVAudioRecorderDelegate{
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var filePath: String? = nil
    var mood: Int? = nil
}

// MARK: - Private
extension RecordTool {
    private func buildFilePath() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss:SSS"
        let dateString = dateFormatter.stringFromDate(NSDate())
        let folderPath = FilePathTool.getDocumentsDirectory()
        return folderPath.stringByAppendingPathComponent("\(dateString).m4a")
    }
}

// MARK: - Record
extension RecordTool {
    func startRecording(){
        let path = buildFilePath()
        self.filePath = path
        let fileURL = NSURL(fileURLWithPath: path)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(URL: fileURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success success: Bool){
        if audioRecorder == nil {
            log.error("no audio recorder")
        } else {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
    func saveRecordingWithMood(mood: Mood) {
        if let filePath = self.filePath {
            let name = filePath.componentsSeparatedByString("/").last!
            let record = Record(filename: name, mood: mood)
            DB.Record.addRecord(record)
        }
        self.filePath = nil
    }
}

// MARK: - Play
extension RecordTool {
    func startPlaying(filename: String){
        let folderPath = FilePathTool.getDocumentsDirectory()
        let filepath = folderPath.stringByAppendingPathComponent(filename)
        let url = NSURL(fileURLWithPath: filepath)
        log.debug(url)
        do{
            let sound = try AVAudioPlayer(contentsOfURL: url)
            audioPlayer = sound
            sound.play()
        } catch {
            log.error(error)
        }
    }
    func stopPlaying(){
        if audioPlayer != nil{
            audioPlayer.stop()
            audioPlayer = nil
        }
    }
}
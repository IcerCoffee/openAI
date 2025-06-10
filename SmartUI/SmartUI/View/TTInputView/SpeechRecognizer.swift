//
//  SpeechRecognizer.swift
//  SmartUI
//
//  Created by why on 2025/5/20.
//
import Speech

class SpeechRecognizer {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN")) // 中文识别
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    func recognizeAudioFile(url: URL, completion: @escaping (String?, Error?) -> Void) {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            completion(nil, NSError(domain: "SpeechRecognizer", code: 1, userInfo: [NSLocalizedDescriptionKey: "语音识别不可用"]))
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            completion(nil, NSError(domain: "SpeechRecognizer", code: 2, userInfo: [NSLocalizedDescriptionKey: "无法创建识别请求"]))
            return
        }
        
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let bestTranscription = result.bestTranscription.formattedString
                completion(bestTranscription, nil)
            } else if let error = error {
                completion(nil, error)
            }
        }
        
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let audioFormat = audioFile.processingFormat
            let audioFrameCount = UInt32(audioFile.length)
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
            
            try audioFile.read(into: audioBuffer!)
            
            recognitionRequest.append(audioBuffer!)
            recognitionRequest.endAudio()
        } catch {
            completion(nil, error)
        }
    }
    
    func requestAuthorization(completion: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
}

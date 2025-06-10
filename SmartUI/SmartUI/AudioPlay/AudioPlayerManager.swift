//
//  VoiceRecognitionService.swift
//  SmartUI
//
//  Created by why on 2025/5/21.
//

import AVFoundation

class AudioPlayerManager {
    static let shared = AudioPlayerManager()
    private var player: AVPlayer?
    
    func playAudio(from url: URL) {
        // 停止当前播放
        player?.pause()
        
        // 创建新的播放器
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // 开始播放
        player?.play()
        
        // 监听播放完成
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem,
                                               queue: .main) { _ in
            print("音频播放完成")
        }
    }
    
    func stopPlayback() {
        player?.pause()
    }
}

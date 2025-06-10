//
//  SpectrumComponentView.swift
//  SmartUI
//
//  Created by why on 2025/5/13.
//

import UIKit
import AVFoundation
import Accelerate
import SnapKit

/// 语音录制并实时显示频谱的组件
class SpectrumComponentView: UIView {
    // MARK: - 私有属性
    private let spectrumView = SpectrumView()
    private let audioEngine = AVAudioEngine()
    private var fftSetup: FFTSetup?
    private let fftSize: Int = 512
    
    /// 振幅缩放因子，取值范围 0~1，越小振动高度越低
    private let amplitudeScale: Float = 0.2

    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configureAudioSession()
        setupFFT()
        installInputTap()
        startAudioEngine()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        configureAudioSession()
        setupFFT()
        installInputTap()
        startAudioEngine()
    }

    deinit {
        audioEngine.inputNode.removeTap(onBus: 0)
        if let fft = fftSetup {
            vDSP_destroy_fftsetup(fft)
        }
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    // MARK: - UI
    private func setupUI() {
        backgroundColor = UIColor(hexString: "#F5F5F5")
        addSubview(spectrumView)
        spectrumView.snp.makeConstraints { make in
            make.edges.equalToSuperview().offset(10)
        }
    }

    // MARK: - Audio Session 配置
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord,
                                    mode: .default,
                                    options: [.defaultToSpeaker])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("🔴 AudioSession 配置失败：\(error)")
        }
    }

    // MARK: - FFT 初始化
    private func setupFFT() {
        fftSetup = vDSP_create_fftsetup(
            vDSP_Length(log2(Float(fftSize))),
            FFTRadix(kFFTRadix2)
        )
    }

    // MARK: - 启动 AudioEngine
    private func startAudioEngine() {
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("🔴 Audio Engine 启动失败：\(error)")
        }
    }

    // MARK: - 安装输入 Tap
    private func installInputTap() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0,
                             bufferSize: AVAudioFrameCount(fftSize),
                             format: format) { [weak self] buffer, _ in
            self?.process(buffer: buffer)
        }
    }

    // MARK: - 处理音频数据并更新频谱
    private func process(buffer: AVAudioPCMBuffer) {
        guard
            let fftSetup = fftSetup,
            let channelData = buffer.floatChannelData?[0]
        else { return }

        // 1. 窗函数
        var window = [Float](repeating: 0, count: fftSize)
        vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))
        var windowed = [Float](repeating: 0, count: fftSize)
        vDSP_vmul(channelData, 1,
                  window, 1,
                  &windowed, 1,
                  vDSP_Length(fftSize))

        // 2. real–complex 转换 & FFT
        var realp = [Float](repeating: 0, count: fftSize/2)
        var imagp = [Float](repeating: 0, count: fftSize/2)
        realp.withUnsafeMutableBufferPointer { realPtr in
            imagp.withUnsafeMutableBufferPointer { imagPtr in
                var split = DSPSplitComplex(realp: realPtr.baseAddress!,
                                            imagp: imagPtr.baseAddress!)
                windowed.withUnsafeBufferPointer { ptr in
                    ptr.baseAddress!.withMemoryRebound(to: DSPComplex.self,
                                                      capacity: fftSize) { typeConverted in
                        vDSP_ctoz(typeConverted, 2, &split, 1, vDSP_Length(fftSize/2))
                    }
                }
                vDSP_fft_zrip(fftSetup, &split, 1,
                              vDSP_Length(log2(Float(fftSize))),
                              FFTDirection(FFT_FORWARD))

                // 3. 计算幅度并分段平均
                var magnitudes = [Float](repeating: 0, count: fftSize/2)
                vDSP_zvabs(&split, 1, &magnitudes, 1, vDSP_Length(fftSize/2))

                let displayCount = 60
                let binSize = magnitudes.count / displayCount
                var dispMags = [Float]()
                for i in 0..<displayCount {
                    let start = i * binSize
                    let slice = magnitudes[start..<start+binSize]
                    var avg: Float = 0
                    vDSP_meanv(Array(slice), 1, &avg, vDSP_Length(binSize))
                    dispMags.append(avg)
                }

                // 4. 应用振幅缩放 + 幂次中心衰减
                let centerIndex = Float(displayCount - 1) / 2.0
                let minCenterScale: Float = 0.2   // 中心最小保留 20%
                let exponent: Float = 2.5         // 幂次越大，中间衰减越强
                let scaledMags = dispMags.enumerated().map { idx, mag -> Float in
                    let distance = abs(Float(idx) - centerIndex)
                    let distanceRatio = distance / centerIndex  // 0 在中间，1 在两端
                    let envelope = minCenterScale + (1 - minCenterScale) * pow(distanceRatio, exponent)
                    return mag * amplitudeScale * envelope
                }

                // 5. 更新 UI
                DispatchQueue.main.async {
                    self.spectrumView.magnitudes = scaledMags
                }
            }
        }
    }

}



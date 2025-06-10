import UIKit
import AVFoundation
import Accelerate

class SpectrumVC: UIViewController {
    // MARK: - UI & Audio Properties
    private let spectrumView = SpectrumView()
    private let audioEngine = AVAudioEngine()
    private var fftSetup: FFTSetup?
    private let fftSize: Int = 512

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpectrumView()
        configureAudioSession()
        setupFFT()
        installInputTap()
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("🔴 Audio Engine 启动失败：\(error)")
        }
    }

    deinit {
        audioEngine.inputNode.removeTap(onBus: 0)
        if let fftSetup = fftSetup {
            vDSP_destroy_fftsetup(fftSetup)
        }
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    // MARK: - Setup Methods
    private func setupSpectrumView() {
        spectrumView.frame = view.bounds
        spectrumView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(spectrumView)
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord,
                                    mode: .default,
                                    options: [.defaultToSpeaker])
            try session.setActive(true,
                                  options: .notifyOthersOnDeactivation)
        } catch {
            print("🔴 AudioSession 配置失败：\(error)")
        }
    }

    private func setupFFT() {
        fftSetup = vDSP_create_fftsetup(
            vDSP_Length(log2(Float(fftSize))),
            FFTRadix(kFFTRadix2)
        )
    }

    private func installInputTap() {
        let inputNode = audioEngine.inputNode
        // —— 关键修改：用 inputFormat 而非 outputFormat
        let format = inputNode.inputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0,
                             bufferSize: AVAudioFrameCount(fftSize),
                             format: format) { [weak self] buffer, _ in
            self?.process(buffer: buffer)
        }
    }

    // MARK: - Audio → FFT → UI
    private func process(buffer: AVAudioPCMBuffer) {
        guard
            let fftSetup = fftSetup,
            let channelData = buffer.floatChannelData?[0]
        else { return }

        // 1. 窗函数
        var window = [Float](repeating: 0, count: fftSize)
        vDSP_hann_window(&window,
                         vDSP_Length(fftSize),
                         Int32(vDSP_HANN_NORM))
        var windowed = [Float](repeating: 0, count: fftSize)
        vDSP_vmul(channelData,
                  1,
                  window,
                  1,
                  &windowed,
                  1,
                  vDSP_Length(fftSize))

        // 2. real–complex 转换 & FFT
        var realp = [Float](repeating: 0, count: fftSize/2)
        var imagp = [Float](repeating: 0, count: fftSize/2)
        realp.withUnsafeMutableBufferPointer { realPtr in
            imagp.withUnsafeMutableBufferPointer { imagPtr in
                var split = DSPSplitComplex(
                    realp: realPtr.baseAddress!,
                    imagp: imagPtr.baseAddress!
                )
                windowed.withUnsafeBufferPointer { ptr in
                    ptr.baseAddress!.withMemoryRebound(
                        to: DSPComplex.self,
                        capacity: fftSize
                    ) { typeConverted in
                        vDSP_ctoz(typeConverted,
                                  2,
                                  &split,
                                  1,
                                  vDSP_Length(fftSize/2))
                    }
                }
                vDSP_fft_zrip(fftSetup,
                              &split,
                              1,
                              vDSP_Length(log2(Float(fftSize))),
                              FFTDirection(FFT_FORWARD))

                // 3. 计算幅度并分段平均
                var magnitudes = [Float](repeating: 0,
                                         count: fftSize/2)
                vDSP_zvabs(&split,
                           1,
                           &magnitudes,
                           1,
                           vDSP_Length(fftSize/2))

                let displayCount = 60
                let binSize = magnitudes.count / displayCount
                var dispMags = [Float]()
                for i in 0..<displayCount {
                    let start = i * binSize
                    let slice = magnitudes[start..<start+binSize]
                    var avg: Float = 0
                    vDSP_meanv(Array(slice),
                               1,
                               &avg,
                               vDSP_Length(binSize))
                    dispMags.append(avg)
                }

                // 4. 更新 UI
                DispatchQueue.main.async {
                    self.spectrumView.magnitudes = dispMags
                    self.spectrumView.setNeedsDisplay()
                }
            }
        }
    }
}

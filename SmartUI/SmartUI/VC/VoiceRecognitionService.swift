//
//  VoiceRecognitionService.swift
//  SmartUI
//
//  Created by why on 2025/5/21.
//
import Alamofire
import CommonCrypto

class VoiceRecognitionService {
    private let appId = "h5C72Lvj"
    private let cuid = "ceshitj25"
    private let carrierId = "202"
    private let iptvId = "1902312"
    private let secretKey = "_5Bu5kw1DNX0mdW"
//    private let baseURL = "https://music.chinaunicomvideo.cn:10025/voice/v1/cpOttFuseRecognition"

    private let baseURL = "https://music.chinaunicomvideo.cn:10025/voice/v1/cpOttFuseRecognition?appid=h5C72Lvj&cuid=ceshitj25&carrierid=202&iptvid=1902312"
    func uploadAudioData(pcmFileURL: URL,completion: @escaping (Result<[String: Any]>) -> Void) {
//        guard !arrayBuffer.isEmpty else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty audio data"])))
//            return
//        }
        
        guard let pcmData = try? Data(contentsOf: pcmFileURL) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法读取PCM文件"])))
            return
        }
        
        // 生成签名
        let signString = "appid\(appId)cuid\(cuid)carrierid\(carrierId)iptvid\(iptvId)\(secretKey)"
        let signature = signString.sha256().base64EncodedString()
        
        // 请求头
        let headers: HTTPHeaders = [
            "Content-Type": "audio/pcm;rate=16000;",
            "sign": signature
        ]
        
        // URL 参数
        let parameters: [String: String] = [
            "appid": appId,
            "cuid": cuid,
            "carrierid": carrierId,
            "iptvid": iptvId
        ]
        
        // 使用 Alamofire 4.x 的上传方式
        Alamofire.upload(
            multipartFormData: { multipart in
                multipart.append(pcmData, withName: "audio", fileName: "audio.pcm", mimeType: "audio/pcm")
                // 添加其他参数
                for (key, value) in parameters {
                    if let data = value.data(using: .utf8) {
                        multipart.append(data, withName: key)
                    }
                }
            },
            to: baseURL,
            method: .post,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            if let json = value as? [String: Any] {
                                completion(.success(json))
                            } else {
                                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
}

// 自定义 Result 类型（兼容 Swift 4.x）
enum Result<T> {
    case success(T)
    case failure(Error)
}

// SHA256 扩展
extension String {
    func sha256() -> Data {
        if let stringData = self.data(using: .utf8) {
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            _ = stringData.withUnsafeBytes {
                CC_SHA256($0.baseAddress, UInt32(stringData.count), &digest)
            }
            return Data(digest)
        }
        return Data()
    }
}

// Data 转 base64 扩展
extension Data {
    func base64EncodedString() -> String {
        return self.base64EncodedString(options: [])
    }
}

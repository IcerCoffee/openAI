//
//  CareSpeechVC.swift
//  SmartUI
//
//  Created by why on 2024/10/28.
//

import UIKit
import AVFoundation

class CareSpeechVC: UOTopBarViewController {
    let synthesizer = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        initilizationUI()
            
        // Do any additional setup after loading the view.
    }
    
    private func initilizationUI(){
        let uttrance = AVSpeechUtterance(string: "设备列表")
        uttrance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  MineVC.swift
//  SmartUI
//
//  Created by why on 2024/10/24.
//

import UIKit

class MineVC: UOTopBarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initilizationUI()
        // Do any additional setup after loading the view.
    }
    
    private func initilizationUI() {
        view.backgroundColor = .systemTeal
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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

//
//  UBOTTAccountListVC.swift
//  SmartUI
//
//  Created by why on 2024/12/12.
//

import UIKit

class UBOTTAccountListVC: UOTopBarViewController,UITableViewDelegate,UITableViewDataSource {
   
    @objc var accountList: NSArray = []
    
    @objc var accountResult: (([String:Any]) -> Void)?
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true // Initially hidden, only shown when network is available
        return tableView
    }()
    
    private let networkErrorView: UBOTTNetworkError = {
        let errorView = UBOTTNetworkError()
        errorView.isHidden = true // Initially hidden, only shown when network is unavailable
        return errorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initilizationUI()
        // Do any additional setup after loading the view.
    }
    
    func initilizationUI(){
        self.title = "OTT账号登录"
        self.view.backgroundColor = UIColor(hexString: "#f8f8f8")
      
        self.view.addSubview(networkErrorView)
        
        networkErrorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(tableView);
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        checkNetworkStatusAndUpdateUI()
    }
    
    private func configureTableView(){
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 77
        tableView.register(UBOTTAccountCell.self, forCellReuseIdentifier: "CellID")
        tableView.separatorStyle = .none
    }
        
    private func configureNetworkErrorView(){
        networkErrorView.onRetry = { [weak self] in
            self?.checkNetworkStatusAndUpdateUI()
        }
    }
    
    private func checkNetworkStatusAndUpdateUI(){
        //重新获取OTT账号信息
        let isNetworkAvailable = false
        
        if isNetworkAvailable {
            tableView.isHidden = false
            networkErrorView.isHidden = true
            tableView.reloadData() // Reload data when network is available
        } else {
            tableView.isHidden = true
            networkErrorView.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accountList.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView();
        let label = UILabel()
        label.text = "选择账号登录"
        label.textColor = UIColor(hexString: "#73757A")
        label.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(30);
            make.height.equalTo(40)
        }
        return view
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath) as? UBOTTAccountCell else{
            return UITableViewCell()
        }
        guard let accountInfo = self.accountList[indexPath.row] as? [String:Any] else{
            return cell
        }
        cell.selectionStyle = .none
//        cell.model = accountInfo
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let accountInfo = self.accountList[indexPath.row] as? [String:Any] else{
            return
        }
        self.accountResult?(accountInfo)
        self.navigationController?.popViewController(animated: true)
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

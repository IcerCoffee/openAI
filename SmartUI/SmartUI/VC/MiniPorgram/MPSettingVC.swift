//
//  MPSettingVC.swift
//  SmartUI
//
//  Created by why on 2025/5/7.
//
import UIKit
import SnapKit

class MPSettingVC: UIViewController {
    // MARK: - Data
    private var scopes: [MPScope] = []

    // MARK: - UI
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "允许”智家通通“201D使用"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hexString: "#999999")
        return label
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.rowHeight = 62  // 54 + 8 spacing
        tv.register(MPSettingCell.self, forCellReuseIdentifier: MPSettingCell.identifier)
        return tv
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
    }

    // MARK: - Setup
    private func setupData() {
        // 模拟数据
        let loc = MPScope()
        loc.orderNum = 1
        loc.scopeName = "位置权限"
        let cam = MPScope()
        cam.orderNum = 2
        cam.scopeName = "相机权限"
        let contact = MPScope()
        contact.orderNum = 3
        contact.scopeName = "通讯录权限"
        scopes = [loc, cam, contact]
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hexString: "#F5F5F5")
        title = "授权管理"

        view.addSubview(descriptionLabel)
        view.addSubview(tableView)

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(15)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UITableViewDataSource
extension MPSettingVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scopes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MPSettingCell.identifier, for: indexPath) as? MPSettingCell else {
            return UITableViewCell()
        }
        let scope = scopes[indexPath.row]
        cell.configure(with: scope)
        // 示例：偶数项默认开启
        cell.switchButton.isSelected = (indexPath.row % 2 == 0)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MPSettingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MPSettingCell {
            cell.switchButton.isSelected.toggle()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Cell
class MPSettingCell: UITableViewCell {
    static let identifier = "MPSettingCell"

    let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 8
        v.clipsToBounds = true
        return v
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(hexString: "#333333")
        return label
    }()

    let switchButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "mp_switch"), for: .normal)
        btn.setImage(UIImage(named: "mp_switch_selected"), for: .selected)
        return btn
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(switchButton)

        // 增加上下间隙 8pt（上4pt，下4pt）
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }

        switchButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 24))
            make.right.equalToSuperview().inset(15)
        }

        switchButton.addTarget(self, action: #selector(didTapSwitch), for: .touchUpInside)
    }

    func configure(with scope: MPScope) {
        titleLabel.text = scope.scopeName
        switchButton.isSelected = false
    }

    @objc private func didTapSwitch() {
        switchButton.isSelected.toggle()
    }
}

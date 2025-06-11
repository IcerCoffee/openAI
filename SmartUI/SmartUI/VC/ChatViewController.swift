//
//  TTChatViewController.swift
//  SmartUI
//
//  Created by why on 2025/5/14.
//
//
//  TTChatViewController.swift
//  SmartUI
//
//  Created by why on 2025/5/14.
//
import UIKit
import SnapKit

/// View layer for simple chat demo. Logic is handled by ChatViewModel

// MARK: - ChatViewController
class ChatViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.keyboardDismissMode = .interactive
//        /Users/why/Documents/Xcode临时工程/SmartUI/SmartUI/VC/ChatViewController.swift
        tv.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tv.register(LoadingCell.self, forCellReuseIdentifier: "LoadingCell")
        tv.register(AICell.self, forCellReuseIdentifier: "AICell")
        tv.dataSource = self
        return tv
    }()
    
    private let viewModel = ChatViewModel()
    private let initialQuestion = "摄像头离线了怎么办？"
    
    override var inputAccessoryView: UIView? { chatInputView }
    override var canBecomeFirstResponder: Bool { true }
    
    private lazy var chatInputView: ChatInputView = {
        let v = ChatInputView()
        v.sendAction = { [weak self] text in
            self?.viewModel.send(question: text)
            self?.chatInputView.clear()
        }
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        viewModel.onMessagesUpdated = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.scrollToBottom()
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChanged(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.messages.isEmpty {
            viewModel.send(question: initialQuestion)
        }
    }
    
    @objc private func keyboardChanged(_ n: Notification) {
        guard let frame = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        tableView.contentInset.bottom = view.bounds.height - frame.origin.y
        scrollToBottom()
    }
    

    
    private func scrollToBottom() {
        let last = viewModel.messages.count - 1
        guard last >= 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: last, section: 0), at: .bottom, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.messages.count
    }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = viewModel.messages[indexPath.row]
        switch msg.type {
        case .user:
            let cell = tv.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
            cell.label.text = msg.text; return cell
        case .loading:
            let cell = tv.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
            cell.label.text = msg.text; cell.indicator.startAnimating(); return cell
        case .ai:
            let cell = tv.dequeueReusableCell(withIdentifier: "AICell", for: indexPath) as! AICell
            cell.label.text = msg.text; return cell
        }
    }
}

// MARK: - Cell 实现
class BaseCell: UITableViewCell {
    let bubble = UIView()
    let label = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(bubble)
        bubble.layer.cornerRadius = 8
        bubble.snp.makeConstraints { make in make.top.bottom.equalToSuperview().inset(8) }
        bubble.addSubview(label)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.snp.makeConstraints { make in make.edges.equalToSuperview().inset(12) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class UserCell: BaseCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubble.backgroundColor = UIColor(hexString: "#E6F7FF")
        bubble.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(60)
        }
        label.textAlignment = .left
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class AICell: BaseCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubble.backgroundColor = UIColor(hexString: "#FFF9E6")
        bubble.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(60)
        }
        label.textAlignment = .left
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class LoadingCell: BaseCell {
    let indicator = UIActivityIndicatorView(style: .gray)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubble.backgroundColor = UIColor(hexString: "#F5F5F5")
        bubble.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(60)
        }
        bubble.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }
        label.snp.remakeConstraints { make in
            make.leading.equalTo(indicator.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview().inset(12)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


// MARK: - ChatInputView
class ChatInputView: UIView {
    var sendAction: ((String) -> Void)?
    private let textField = UITextField()
    private let sendBtn = UIButton(type: .system)
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(textField)
        addSubview(sendBtn)
        textField.borderStyle = .roundedRect
        textField.placeholder = "请输入问题"
        textField.tintColor = UIColor(hexString: "#E60027")
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor(hexString: "#EEEEEE").cgColor
        
        sendBtn.setTitle("发送", for: .normal)
        sendBtn.addTarget(self, action: #selector(sendTap), for: .touchUpInside)
        
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().inset(8)
            make.trailing.equalTo(sendBtn.snp.leading).offset(-8)
            make.height.equalTo(36)
        }
        sendBtn.snp.makeConstraints { make in
            make.centerY.equalTo(textField)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(50)
        }
        
        layer.shadowColor = UIColor(hexString: "#000000").withAlphaComponent(0.1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: -4)
        layer.shadowOpacity = 1
        layer.shadowRadius = 8
    }
    @objc private func sendTap() {
        sendAction?(textField.text ?? "")
    }
    func clear() { textField.text = "" }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

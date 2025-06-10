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

// MARK: - Message 模型
enum MessageType {
    case user       // 用户提问
    case loading    // AI 思考中
    case ai         // AI 回答中
    case rating     // 好评、差评
}

struct Message {
    let text: String
    let type: MessageType
}

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
        tv.register(RatingCell.self, forCellReuseIdentifier: "RatingCell")
        tv.dataSource = self
        return tv
    }()
    
    private var messages: [Message] = []
    private let initialQuestion = "摄像头离线了怎么办？"
    private let answerText = """
    您好，若摄像头直播页面出现“设备已离线”，一般是设备硬件损坏或网络波动导致，请您：
    （1）首先查看摄像机指示灯是否正常（绿灯长亮为设备正常状态），如绿灯闪烁，则尝试将网线拔掉，过5秒左右重新插入，等待摄像头上线（一般一分钟之内摄像头会自动上线）。
    （2）设备指示灯为长绿灯常亮，APP上显示离线，则退出APP，重新登录查看状态。如仍然无效，则拔插摄像机电源，确认设备状态。
    （3）如果上述操作都无法解决问题，建议从客户端将摄像头解绑，摄像头长按Reset按键复位（Reset按键需要拧开二维码下面的螺丝才能看到），重新进行绑定操作。
    """
    
    override var inputAccessoryView: UIView? { chatInputView }
    override var canBecomeFirstResponder: Bool { true }
    
    private lazy var chatInputView: ChatInputView = {
        let v = ChatInputView()
        v.sendAction = { [weak self] text in self?.send(text: text) }
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChanged(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if messages.isEmpty {
            send(text: initialQuestion)
        }
    }
    
    @objc private func keyboardChanged(_ n: Notification) {
        guard let frame = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        tableView.contentInset.bottom = view.bounds.height - frame.origin.y
        scrollToBottom()
    }
    
    private func send(text: String) {
        guard !text.isEmpty else { return }
        // 添加用户消息
        messages.append(.init(text: text, type: .user))
        tableView.reloadData(); scrollToBottom()
        // 添加 loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.messages.append(.init(text: "通通分析中。。。", type: .loading))
            self.tableView.reloadData(); self.scrollToBottom()
            // 模拟思考
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let idx = self.messages.firstIndex(where: { $0.type == .loading }) {
                    self.messages.remove(at: idx)
                }
                self.messages.append(.init(text: "", type: .ai))
                self.tableView.reloadData(); self.scrollToBottom()
                self.typeAnswer()
            }
        }
    }
    
    private func typeAnswer() {
        guard let idx = messages.firstIndex(where: { $0.type == .ai }) else { return }
        var current = ""
        let chars = Array(answerText)
        var i = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if i < chars.count {
                current.append(chars[i]); i += 1
                self.messages[idx] = .init(text: current, type: .ai)
                self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
                self.scrollToBottom()
            } else {
                timer.invalidate()
                self.messages.append(.init(text: "", type: .rating))
                self.tableView.reloadData(); self.scrollToBottom()
            }
        }
    }
    
    private func scrollToBottom() {
        let last = messages.count - 1
        guard last >= 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: last, section: 0), at: .bottom, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]
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
        case .rating:
            let cell = tv.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingCell
            cell.onRate = { good in print(good ? "用户好评" : "用户差评") }; return cell
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

class RatingCell: UITableViewCell {
    var onRate: ((Bool) -> Void)?
    private let goodBtn = UIButton(type: .system)
    private let badBtn = UIButton(type: .system)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(goodBtn)
        contentView.addSubview(badBtn)
        goodBtn.setTitle("好评", for: .normal)
        badBtn.setTitle("差评", for: .normal)
        goodBtn.layer.cornerRadius = 4
        badBtn.layer.cornerRadius = 4
        goodBtn.layer.borderWidth = 0.5
        badBtn.layer.borderWidth = 0.5
        goodBtn.layer.borderColor = UIColor(hexString: "#4CAF50").cgColor
        badBtn.layer.borderColor = UIColor(hexString: "#F44336").cgColor
        goodBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.trailing.equalTo(contentView.snp.centerX).offset(-8)
            make.width.equalTo(80)
            make.height.equalTo(36)
        }
        badBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.equalTo(contentView.snp.centerX).offset(8)
            make.width.equalTo(80)
            make.height.equalTo(36)
        }
        goodBtn.addTarget(self, action: #selector(rateGood), for: .touchUpInside)
        badBtn.addTarget(self, action: #selector(rateBad), for: .touchUpInside)
    }
    @objc private func rateGood() { onRate?(true) }
    @objc private func rateBad()  { onRate?(false) }
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

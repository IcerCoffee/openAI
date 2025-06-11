import Foundation

enum MessageType {
    case user
    case loading
    case ai
}

struct Message {
    var text: String
    var type: MessageType
}

class ChatViewModel {
    private(set) var messages: [Message] = []
    var onMessagesUpdated: (() -> Void)?

    func send(question: String) {
        guard !question.isEmpty else { return }
        messages.append(Message(text: question, type: .user))
        notify()
        messages.append(Message(text: "思考中...", type: .loading))
        notify()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            if let idx = self.messages.firstIndex(where: { $0.type == .loading }) {
                self.messages.remove(at: idx)
            }
            self.messages.append(Message(text: "", type: .ai))
            self.notify()
            self.typeAnswer()
        }
    }

    private func typeAnswer() {
        guard let idx = messages.lastIndex(where: { $0.type == .ai }) else { return }
        let answer = Self.randomChineseText()
        var current = ""
        let chars = Array(answer)
        var i = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            if i < chars.count {
                current.append(chars[i])
                i += 1
                self.messages[idx].text = current
                self.notify()
            } else {
                timer.invalidate()
            }
        }
    }

    private func notify() {
        onMessagesUpdated?()
    }

    private static func randomChineseText() -> String {
        let length = Int.random(in: 10...200)
        var result = ""
        for _ in 0..<length {
            let code = Int.random(in: 0x4e00...0x9fa5)
            if let scalar = UnicodeScalar(code) {
                result.append(Character(scalar))
            }
        }
        return result
    }
}

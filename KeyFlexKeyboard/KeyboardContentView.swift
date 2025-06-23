import SwiftUI
import Foundation

enum KeyboardMode {
    case alphabet
    case numbers
    case symbols
}

struct KeyboardContentView: View {
    var proxy: UITextDocumentProxy
    @State private var chat: Chat?
    
    @State private var keyboardMode: KeyboardMode = .alphabet
    @State private var shiftOn = false
    //    @State private var suggestions = ["I’m good, thanks!", "Doing well, how about you?", "I’m fine, and you?"]
    //    @State private var inputText = "How are you?"
    @State private var copiedText: String = ""
    @State private var suggestions: [String] = []
    
    
    var body: some View {
        VStack(spacing: 6) {
            // Suggestions Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: {
                            proxy.insertText(suggestion)
                        }) {
                            Text(suggestion)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray5))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            
            // Message Input Bubble
            //            HStack {
            //                Button(action: {
            //                    // Open options or actions
            //                }) {
            //                    Image(systemName: "plus")
            //                        .foregroundColor(.blue)
            //                        .padding(.leading, 4)
            //                }
            //
            //                TextField("Type something", text: $inputText)
            //                .disabled(true) // Disable direct typing — can't type into it
            //                .padding()
            //                .background(Color.gray.opacity(0.2))
            //                .cornerRadius(10)
            //            }
            //            .padding(.horizontal, 8)
            
            // QWERTY Keyboard
            VStack(spacing: 6) {
                ForEach(currentKeyRows(), id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(row, id: \.self) { key in
                            KeyButton(label: key) {
                                proxy.insertText(key)
                            }
                        }
                    }
                }
                
                HStack(spacing: 6) {
                    if keyboardMode == .alphabet {
                        KeyButton(label: shiftOn ? "⬆︎" : "⇧", width: 50) {
                            shiftOn.toggle()
                        }
                        KeyButton(label: "123", width: 50) {
                            keyboardMode = .numbers
                        }
                    } else {
                        KeyButton(label: "ABC", width: 50) {
                            keyboardMode = .alphabet
                            shiftOn = false
                        }
                        KeyButton(label: keyboardMode == .numbers ? "#+=" : "123", width: 50) {
                            keyboardMode = keyboardMode == .numbers ? .symbols : .numbers
                        }
                    }
                    
                    KeyButton(label: "space", width: 160) {
                        proxy.insertText(" ")
                    }
                    
                    KeyButton(label: "⌫", width: 50) {
                        proxy.deleteBackward()
                    }
                    
                    KeyButton(label: "↩︎", width: 50) {
                        proxy.insertText("\n")
                    }
                }
            }
            
            Spacer(minLength: 4)
        }
        .padding(.bottom, 8)
        .background(Color(UIColor.systemBackground))
        
        .onAppear {
            
            if UIPasteboard.general.hasStrings {
                let copiedText = UIPasteboard.general.string ?? ""
                print("Copied: \(copiedText)")
            }
            
            if let copied = UIPasteboard.general.string, copied != copiedText {
                print("happy")
                print(copied)
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                    copiedText = copied
                    generatePrompts(from: copied)
                }
            }
        }
    }
    
    private func currentKeyRows() -> [[String]] {
        switch keyboardMode {
        case .alphabet:
            return shiftOn ? uppercaseAlphabetRows : lowercaseAlphabetRows
        case .numbers:
            return numberRows
        case .symbols:
            return symbolRows
        }
    }
    
    private var uppercaseAlphabetRows: [[String]] {
        [["Q","W","E","R","T","Y","U","I","O","P"],
         ["A","S","D","F","G","H","J","K","L"],
         ["Z","X","C","V","B","N","M"]]
    }
    
    private var lowercaseAlphabetRows: [[String]] {
        uppercaseAlphabetRows.map { $0.map { $0.lowercased() } }
    }
    
    private var numberRows: [[String]] {
        [["1","2","3","4","5","6","7","8","9","0"],
         ["-","/",":",";","(",")","$","&","@"],
         [".",",","?","!","'"]]
    }
    
    private var symbolRows: [[String]] {
        [["[","]","{","}","#","%","^","*","+","="],
         ["_","\\","|","~","<",">","€","£","¥","•"],
         [".",",","?","!","'"]]
    }
    
    func generatePrompts(from text: String) {
        
        if let data = UserDefaults.standard.data(forKey: "cachedChat"),
           let chat = try? JSONDecoder().decode(Chat.self, from: data) {
            ChatService.shared.generatePrompt(chatId: chat.chatId, message: text) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            suggestions = response.result.currentChoices.map { $0.message }
                        case .failure(let error):
                            print("Error generating prompts: \(error.localizedDescription)")
                        }
                    }
                }
        }
       
    }
    
    func loadCachedChat() {
        if let data = UserDefaults.standard.data(forKey: "cachedChat"),
           let chat = try? JSONDecoder().decode(Chat.self, from: data) {
            self.chat = chat
        }
        
    }
}

struct KeyButton: View {
    let label: String
    var width: CGFloat? = 32
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16))
                .frame(width: width, height: 44)
                .background(Color(.systemGray5))
                .foregroundColor(.black)
                .cornerRadius(6)
        }
    }
}



import SwiftUI

struct Dashboard: View {
    
    @State private var prompt: String = ""
    @State private var aiResponse: String = ""
    @State private var aiSuggestionsEnabled: Bool = true
    @State private var selectedTone: String = "Friendly"
    @State private var isDarkTheme: Bool = true
    @State private var chats: [Chat] = []
    @State private var selectedChat: Chat?
    @State private var newChatFlavor: String = ""
    @State private var newChatTone: String = ""
    @State private var newChatStyle: String = ""
    @State private var newChatIntent: String = ""
    @AppStorage("token") private var token: String = ""
    @State private var chat: Chat?
    @State private var error: String?
    @State private var suggestions: [String] = []
    var body: some View {
        ScrollView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    // Chat List
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Chats")
                            .font(.headline)

//                        ForEach(chats, id: \.id) { chat in
//                            Button(action: {
//                                selectedChat = chat
//                            }) {
                        VStack(alignment: .leading) {
                            Text("Chat: \(chat?.chatId ?? "N/A")")
                                .font(.caption)
                        }
//                                .padding(8)
//                                .background(selectedChat?.id == chat.id ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
//                                .cornerRadius(8)
//                            }
//                        }

                     
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)

                    // Prompt Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Generate a Prompt")
                            .font(.headline)

                        HStack {
                            TextField("Type your prompt", text: $prompt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button("Generate") {
                                generatePrompt()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        if !suggestions.isEmpty {
//                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(suggestions, id: \.self) { suggestion in
                                        Button(action: {
                                           
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
//                            }
                        }


                        if !aiResponse.isEmpty {
                            Text(aiResponse)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)

                    // Settings Section
                    VStack(spacing: 20) {
                        Toggle("Enable AI Suggestions", isOn: $aiSuggestionsEnabled)

                        NavigationLink(destination: ToneSelectionView(selectedTone: $selectedTone)) {
                            HStack {
                                Text("Tone")
                                Spacer()
                                Text(selectedTone)
                                    .foregroundColor(.gray)
                            }
                        }

                        HStack {
                            Text("Theme")
                            Spacer()
                            Picker("", selection: $isDarkTheme) {
                                Text("Dark").tag(true)
                                Text("Light").tag(false)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
                .padding()
            }
            .navigationBarTitle("RelateOS", displayMode: .inline)
            .onAppear(perform: loadCachedChat)
        }
    }

    func loadChats() {
        ChatService.shared.fetchChats(token: token) { fetchedChats in
            DispatchQueue.main.async {
                if let fetchedChats = fetchedChats {
                    self.chats = fetchedChats
                    self.selectedChat = fetchedChats.first
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


    func generatePrompt() {
        print("ppppp")
        guard let chat = chat else { return }
        ChatService.shared.generatePrompt(chatId: chat.chatId, message: prompt) { response in
            DispatchQueue.main.async {
                switch response {
                   case .success(let choice):
                    suggestions = choice.result.currentChoices.map { $0.message }
                    print(suggestions)
                    case .failure(let err):
                       print("Failed to create chat: \(err)")
                    aiResponse = "Failed to get response"
                    error = err.localizedDescription                }
              
            }
        }
    }
}

// Supporting Structs
struct ToneSelectionView: View {
    @Binding var selectedTone: String
    let tones = ["Friendly", "Professional", "Casual", "Concise"]

    var body: some View {
        List {
            ForEach(tones, id: \.self) { tone in
                HStack {
                    Text(tone)
                    Spacer()
                    if tone == selectedTone {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTone = tone
                }
            }
        }
        .navigationTitle("Select Tone")
    }
}


#Preview {
    Dashboard()
}

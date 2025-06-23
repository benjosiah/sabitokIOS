//
//  flexKeysApp.swift
//  flexKeys
//
//  Created by user on 5/5/25.
//

import SwiftUI

@main
struct flexKeysApp: App {
    @State private var chat: Chat? = loadCachedChat()
    @State private var isLoading: Bool = false
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
                    if let chat = chat {
                               Dashboard() // Pass it if Dashboard needs it
                           } else if isLoading {
                               ProgressView("Setting up chat...")
                           } else {
                               ProgressView("Setting up chat...")
                                   .onAppear {
                                       isLoading = true
                                       createChatAndCache(token: accessToken) { newChat in
                                           DispatchQueue.main.async {
                                               self.chat = newChat
                                               self.isLoading = false
                                           }
                                       }
                                   }
                           }
                } else {
                    LoginView()
                }
               
            

            }
        }
    }
}

func loadCachedChat() -> Chat? {
    @AppStorage("cachedChat") var token: String = ""
    if let data = UserDefaults.standard.data(forKey: "cachedChat"),
       let chat = try? JSONDecoder().decode(Chat.self, from: data) {
//        print(chat)
        return chat
    }
    return nil
}

func createChatAndCache(token: String, completion: @escaping (Chat?) -> Void) {
    ChatService.shared.createChat(token: token) { result in
        DispatchQueue.main.async {
            
            switch result {
               case .success(let chat):
                   // Cache chat here if needed
                   cacheChat(chat)
                   completion(chat)
               case .failure(let error):
                   print("Failed to create chat: \(error)")
                   completion(nil)
            }
           
        }
    }
}

func cacheChat(_ chat: Chat) {
    if let encoded = try? JSONEncoder().encode(chat) {
        UserDefaults.standard.set(encoded, forKey: "cachedChat")
    }
}

func isKeyboardExtensionEnabled(bundleIdentifier: String) -> Bool {
    guard let keyboards = UserDefaults.standard.dictionaryRepresentation()["AppleKeyboards"] as? [String] else {
        return false
    }
    return keyboards.contains(bundleIdentifier)
}


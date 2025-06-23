import Foundation

struct Chat: Codable {
    let chatId: String
    let message: String
}

struct Metadata: Codable {
    let id: String
    let tone: String
    let style: String
    let intent: String
    let flavor: String
}

struct PromptChatResponse: Decodable {
    let result: PromptResult
}

struct PromptResult: Decodable {
    let currentChoices: [PromptChoice]
}

struct PromptChoice: Decodable {
    let message: String
}

struct ChatResponse: Codable {
    let results: [Chat]
    let totalItems: Int
    let totalPages: Int
    let currentPage: Int
    let limit: Int
    
}

struct Choice: Codable {
    let id: String
    let message: String
    let tip: String
    let whyItWorks: String
    let sender: String
    let isRegenerated: Bool
    let rephrase: Bool
    let flow: String
    let metadata: Metadata
    let createdAt: String
    let updatedAt: String
}

//struct PromptChatResponse: Codable {
//    struct Result: Codable {
//        let id: String
//        let sender: String
//        let currentChoices: [Choice]
//        let selectedChoice: Choice?
//        let choicesHistory: [String]?
//        let targetMessageId: String
//        let createdAt: String
//        let updatedAt: String
//    }
//    let result: Result
//    let message:String
//}

struct APIErrorResponse: Decodable, Error {
    let message: [String]?
    let error: String?
    let statusCode: Int?
}

class ChatService {
    static let shared = ChatService()
    private init() {}

    private var baseURL: String {
        return Bundle.main.infoDictionary?["BASE_AUTH_URL"] as? String ?? ""
    }

    func fetchChats(token: String, completion: @escaping ([Chat]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "x-access-token")
        request.setValue("http://localhost:3000", forHTTPHeaderField: "Origin")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
                completion(decoded.results)
            } catch {
                completion(nil)
            }
        }.resume()
    }

    func createChat(token: String, completion: @escaping (Result<Chat, Error>) -> Void) {
        func makeRequest(with token: String) {
            guard let url = URL(string: "\(baseURL)/chat") else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "x-access-token")
            request.setValue("http://localhost:3000", forHTTPHeaderField: "Origin")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = [
                "flavor": "plain",
                "tone": "freiendly",
                "style": "proffesional",
                "intent": "communicate"
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            print("session")
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    // Token expired — attempt to refresh
                    AuthService.refreshToken { result in
                        switch result {
                        case .success(let refreshed):
                            makeRequest(with: refreshed.accessToken) // retry with new token
                        case .failure:
                            DispatchQueue.main.async {
                                UserDefaults.standard.removeObject(forKey: "accessToken")
                                UserDefaults.standard.removeObject(forKey: "refreshToken")
                                completion(.failure(NSError(domain: "Unauthorized", code: 401)))
                            }
                        }
                    }
                    return
                }
                
                if let data = data {
                    print(String(data: data, encoding: .utf8) ?? "No readable data")
                } else {
                    print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                }
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let data = data else {
                        completion(.failure(NSError(domain: "No data", code: -1)))
                        return
                    }
                    
                    print(data)
                    
                    do {
                        let chat = try JSONDecoder().decode(Chat.self, from: data)
                        print(chat)
                        completion(.success(chat))
                    } catch {
                        print(error)
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
                           let message = apiError.message?.first {
                            let customError = NSError(domain: "", code: apiError.statusCode ?? 400, userInfo: [NSLocalizedDescriptionKey: message])
                            completion(.failure(customError))
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
            }.resume()
        }
        makeRequest(with: token)
    }

    func generatePrompt(chatId: String, message: String, completion: @escaping (Result<PromptChatResponse, Error>) -> Void) {
        func makeRequest(with token: String) {
            guard let url = URL(string: "\(baseURL)/chat/\(chatId)/generate-prompt-chat") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "x-access-token")
            request.setValue("http://localhost:3000", forHTTPHeaderField: "Origin")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body = ["message": message]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    // Token expired — attempt to refresh
                    AuthService.refreshToken { result in
                        switch result {
                        case .success(let refreshed):
                            makeRequest(with: refreshed.accessToken) // retry with new token
                        case .failure:
                            DispatchQueue.main.async {
                                UserDefaults.standard.removeObject(forKey: "accessToken")
                                UserDefaults.standard.removeObject(forKey: "refreshToken")
                                completion(.failure(NSError(domain: "Unauthorized", code: 401)))
                            }
                        }
                    }
                    return
                }

                DispatchQueue.main.async {
                    guard let data = data else {
                        completion(.failure(NSError(domain: "No data", code: -1)))
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 && httpResponse.statusCode < 500 {
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
                           let message = apiError.message?.first {
                            let customError = NSError(domain: "", code: apiError.statusCode ?? 400, userInfo: [NSLocalizedDescriptionKey: message])
                            completion(.failure(customError))
                        }
                    }

                    do {
                        print(String(data: data, encoding: .utf8) ?? "Invalid data")
                        let response = try JSONDecoder().decode(PromptChatResponse.self, from: data)
                        print(response)
                        completion(.success(response))
                    } catch {
                        print(error)
                        if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
                           let message = apiError.message?.first {
                            let customError = NSError(domain: "", code: apiError.statusCode ?? 400, userInfo: [NSLocalizedDescriptionKey: message])
                            completion(.failure(customError))
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
            }.resume()
        }

        guard let token = UserDefaults.standard.string(forKey: "accessToken") else { return }
        makeRequest(with: token)
    }

//    func checkOrCreateChat(token: String, completion: @escaping (Chat?) -> Void) {
//        fetchChats(token: token) { existingChat in
//            if let chat = existingChat {
//                UserDefaults.standard.set(chat.id, forKey: "chatId")
//                completion(chat)
//            } else {
//                self.createChat(token: token) { newChat in
//                    if let chat = newChat {
//                        UserDefaults.standard.set(chat.id, forKey: "chatId")
//                    }
//                    completion(newChat)
//                }
//            }
//        }
//    }
}

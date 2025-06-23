import Foundation

final class AuthService {
    // Use environment variable or configuration constant
    static let baseAuthURL = Bundle.main.infoDictionary?["BASE_AUTH_URL"] as? String ?? "https://sabitok-backend.vercel.app"
    
    // MARK: - Models
    struct LoginResponse: Codable {
        let accessToken: String
        let refreshToken: String
    }

    struct RegisterResponse: Codable {
        let message: String
    }

    struct RequestOTPResponse: Codable {
        let message: String
    }

    struct VerifyOTPResponse: Codable {
        let token: String
        let user: User
    }

    struct User: Codable {
        let id: String
        let name: String?
        let email: String
    }
    
    struct APIErrorResponse: Decodable, Error {
        let message: [String]?
        let error: String?
        let statusCode: Int?
    }


    // MARK: - OTP
    static func requestOTP(email: String, completion: @escaping (Result<RequestOTPResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseAuthURL)/signup/request-otp") else { return }

        makePOSTRequest(url: url, body: ["email": email], completion: completion)
    }

    static func verifyOTP(email: String, otp: String, password: String, completion: @escaping (Result<VerifyOTPResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseAuthURL)/signup/verify-otp") else { return }

        let body = ["email": email, "otp": otp, "password": password]
        makePOSTRequest(url: url, body: body, completion: { (result: Result<VerifyOTPResponse, Error>) in
            if case let .success(response) = result {
                // Save token
                UserDefaults.standard.set(response.token, forKey: "accessToken")
            }
            completion(result)
        })
    }

    // MARK: - Login
    static func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        print("Login button tapped")
        guard let url = URL(string: "\(baseAuthURL)/auth/login") else { return }
        UserDefaults.standard.set(true, forKey: "_NSURLSessionLogRequests")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("sabitok-backend.vercel.app", forHTTPHeaderField: "Origin")

        let body = ["email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: -1)))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                    print(decoded)
                    // Save token
                    UserDefaults.standard.set(decoded.accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(decoded.refreshToken, forKey: "refreshToken")
                    completion(.success(decoded))
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
    
    static func refreshToken(completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        print("Login button tapped")
        let token:String
        if let refreshToken = UserDefaults.standard.string(forKey: "accessToken") {
            token = refreshToken
        }else{
            return
        }
        guard let url = URL(string: "\(baseAuthURL)/auth/refresh") else { return }
        UserDefaults.standard.set(true, forKey: "_NSURLSessionLogRequests")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "x-access-token")
        request.setValue("http://localhost:3000", forHTTPHeaderField: "Origin")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: -1)))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                    print(decoded)
                    // Save token
                    UserDefaults.standard.set(decoded.accessToken, forKey: "accessToken")
                    completion(.success(decoded))
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

    // MARK: - Register
    static func register(firstName: String, lastName: String, email: String, password: String, completion: @escaping (Result<RegisterResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseAuthURL)/auth/register") else { return }

        let body = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password
        ]

        makePOSTRequest(url: url, body: body, completion: completion)
    }

    // MARK: - Helper
    private static func makePOSTRequest<T: Decodable>(url: URL, body: [String: Any], completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: -1)))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    // Try decoding the error message
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

}

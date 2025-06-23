struct RequestOTPResponse: Codable {
    let message: String
    let expiresIn: Int
}

struct VerifyOTPResponse: Codable {
    let message: String
    let userId: String
    let token: String
}

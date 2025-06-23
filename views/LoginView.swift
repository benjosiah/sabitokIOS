import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showDashboard = false
    @State private var showRegister = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)


                SecureField("Password", text: $password)
                   .padding()
                   .background(Color.gray.opacity(0.1))
                   .cornerRadius(8)
                
                Button(action: {
                    AuthService.login(email: email, password: password) { result in
                        switch result {
                        case .success(let response):
                            UserDefaults.standard.set(response.accessToken, forKey: "jwt")
                            showDashboard = true
                        case .failure(let err):
                            error = err.localizedDescription
                        }
                    }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                

                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
                

                // Link to register
                Button("Don't have an account? Register") {
                    showRegister = true
                }
                .font(.footnote)
            }
            .padding()
            .navigationTitle("Login")
            .navigationDestination(isPresented: $showDashboard) {
                Dashboard()
            }
            .fullScreenCover(isPresented: $showDashboard) {
                Dashboard()
            }
        }
    }
}


#Preview {
    LoginView()
}

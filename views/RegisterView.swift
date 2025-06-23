//
//  RegisterView.swift
//  flexKeys
//
//  Created by user on 6/9/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var showVerify = false
    @State private var error: String?
    @State private var showLogin = false
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var password = ""


    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
            
                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                
                TextField("Last Name", text: $lastName)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                
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
                    AuthService.register(firstName: firstName, lastName: lastName, email: email, password: password){
                        result in
                        switch result {
                        case .success:
                            showLogin = true
                        case .failure(let err):
                            error = err.localizedDescription
                        }
                    }
                })
                {
                   Text("Register")
                       .frame(maxWidth: .infinity)
                       .padding()
                       .background(Color.blue)
                       .foregroundColor(.white)
                       .cornerRadius(8)
               }
                
            


                if let error = error {
                    Text(error).foregroundColor(.red)
                }
                
                Spacer()

                                // Link to login
                Button("Already have an account? Login") {
                    showLogin = true
                }
                .font(.footnote)

            }
            .padding()
            .navigationTitle("Register")
            .navigationDestination(isPresented: $showLogin) {
                           LoginView()
            }
        }
    }

}

#Preview {
    RegisterView()
}

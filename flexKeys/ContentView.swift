//
//  ContentView.swift
//  flexKeys
//
//  Created by user on 5/5/25.
//

import SwiftUI


import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var showKeyboardPrompt = true

    var body: some View {
        VStack {
            Text("Welcome to the App!")
                .font(.largeTitle)
                .padding()
        }
        .alert(isPresented: $showKeyboardPrompt) {
            Alert(
                title: Text("Enable Keyboard"),
                message: Text("To use the keyboard extension, please enable it in Settings > General > Keyboard > Keyboards > Add New Keyboard."),
                primaryButton: .default(Text("Open Settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}


//struct ContentView: View {
//    @State private var isSignUp = false
//    @State private var email = ""
//    @State private var password = ""
//    @State private var confirmPassword = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                if isSignUp {
//                    SignUpView(isSignUp: $isSignUp, email: $email, password: $password, confirmPassword: $confirmPassword)
//                } else {
//                    LoginView(isSignUp: $isSignUp, email: $email, password: $password)
//                }
//            }
//            .navigationTitle(isSignUp ? "Sign Up" : "Login")
//        }
//    }
//}
//
//struct LoginView: View {
//    @Binding var isSignUp: Bool
//    @Binding var email: String
//    @Binding var password: String
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            TextField("Email", text: $email)
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(8)
//                .keyboardType(.emailAddress)
//                .autocapitalization(.none)
//            
//            SecureField("Password", text: $password)
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(8)
//            
//            Button(action: {
//                // Handle login action
//            }) {
//                Text("Login")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            
//            HStack {
//                Text("Don't have an account?")
//                Button(action: {
//                    isSignUp = true
//                }) {
//                    Text("Sign Up")
//                        .foregroundColor(.blue)
//                }
//            }
//        }
//        .padding()
//    }
//}
//
//struct SignUpView: View {
//    @Binding var isSignUp: Bool
//    @Binding var email: String
//    @Binding var password: String
//    @Binding var confirmPassword: String
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            TextField("Email", text: $email)
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(8)
//                .keyboardType(.emailAddress)
//                .autocapitalization(.none)
//            
//            SecureField("Password", text: $password)
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(8)
//            
//            SecureField("Confirm Password", text: $confirmPassword)
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(8)
//            
//            Button(action: {
//                // Handle sign-up action
//            }) {
//                Text("Sign Up")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            
//            HStack {
//                Text("Already have an account?")
//                Button(action: {
//                    isSignUp = false
//                }) {
//                    Text("Login")
//                        .foregroundColor(.blue)
//                }
//            }
//        }
//        .padding()
//    }
//}



//struct ContentView: View {
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("Welcome to KeyFlex!")
//                .font(.title)
//            Text("To enable the keyboard:")
//                .font(.headline)
//            VStack(alignment: .leading, spacing: 8) {
//                Text("1. Go to Settings → General → Keyboard → Keyboards.")
//                Text("2. Tap 'Add New Keyboard…' and select KeyFlex.")
//                Text("3. Allow Full Access if needed.")
//            }
//            .font(.subheadline)
//            .padding()
//        }
//        .padding()
//    }
//}



#Preview {
    ContentView()
}

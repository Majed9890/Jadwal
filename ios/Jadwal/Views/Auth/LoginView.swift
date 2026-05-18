import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var detectedRole = ""
    @State private var isLoggedIn = false
    @State private var errorMessage = ""

    var body: some View {
        if isLoggedIn {
            MainTabView(role: detectedRole, isLoggedIn: $isLoggedIn)
        } else {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        VStack(spacing: 12) {
                            Spacer().frame(height: 70)

                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.15))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "ticket.fill")
                                    .font(.system(size: 34))
                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                            }

                            Text("Welcome Back,")
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(.white)

                            Text("Sign in to Jadwal")
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(.white)

                            Text("Discover and book amazing events")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 4)

                            Spacer().frame(height: 40)
                        }

                        VStack(spacing: 14) {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                    .frame(width: 20)
                                TextField("", text: $email)
                                    .placeholder(when: email.isEmpty) {
                                        Text("Email address").foregroundColor(.white.opacity(0.3))
                                    }
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(16)

                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                    .frame(width: 20)
                                SecureField("", text: $password)
                                    .placeholder(when: password.isEmpty) {
                                        Text("Password").foregroundColor(.white.opacity(0.3))
                                    }
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(16)

                            if !errorMessage.isEmpty {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button(action: {
                                login()
                            }) {
                                Text("Sign In")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color(red: 0.6, green: 1.0, blue: 0.0))
                                    .cornerRadius(16)
                            }
                            .padding(.top, 10)

                            NavigationLink(destination: RegisterView()) {
                                HStack(spacing: 4) {
                                    Text("Don't have an account?")
                                        .foregroundColor(.white.opacity(0.5))
                                    Text("Register")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                }
                                .font(.subheadline)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 50)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    func login() {
        let url = URL(string: "\(APIConfig.baseURL)/api/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "email": email,
            "password": password
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data else { return }

            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if let token = result["token"] as? String,
                       let role = result["role"] as? String {
                        AuthManager.shared.token = token
                        AuthManager.shared.role = role
                        detectedRole = role
                        isLoggedIn = true
                    } else if let err = result["error"] as? String {
                        errorMessage = err
                    }
                }
            }
        }.resume()
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow { placeholder() }
            self
        }
    }
}

#Preview {
    LoginView()
}

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole = "attendee"
    @State private var isLoggedIn = false
    @State private var errorMessage = ""
    let roles = ["attendee", "organizer", "admin"]
    
    var body: some View {
        if isLoggedIn {
            MainTabView(role: selectedRole, isLoggedIn: $isLoggedIn)
        } else {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Jadwal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 60)
                    
                    Text("Login to your account")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Picker("Role", selection: $selectedRole) {
                        ForEach(roles, id: \.self) { role in
                            Text(role.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        login()
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: RegisterView()) {
                        Text("Don't have an account? Register")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    func login() {
        let url = URL(string: "http://192.168.3.10:3000/api/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "role": selectedRole
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
                    if let token = result["token"] as? String {
                        AuthManager.shared.token = token
                        AuthManager.shared.role = selectedRole
                        isLoggedIn = true
                    } else if let err = result["error"] as? String {
                        errorMessage = err
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    LoginView()
}

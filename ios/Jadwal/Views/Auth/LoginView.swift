import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole = "attendee"
    @State private var isLoggedIn = false
    let roles = ["attendee", "organizer", "admin"]
    
    var body: some View {
        if isLoggedIn {
            MainTabView(role: selectedRole)
        } else {
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
                
                Button(action: {
                    // TODO: connect to API
                    isLoggedIn = true
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    LoginView()
}

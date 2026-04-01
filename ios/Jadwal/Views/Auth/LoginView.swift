import SwiftUI

struct LoginView: View {

    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole = "attendee"
    @State private var isLoggedIn = false

    let roles = ["attendee", "organizer", "admin"]

    var body: some View {
        VStack(spacing: 20) {

            Text("Jadwal")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 60)

            Text("Login to your account")
                .foregroundColor(.gray)

            Spacer()

            // email field
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .autocapitalization(.none)

            // password field
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            // role picker
            Picker("Role", selection: $selectedRole) {
                ForEach(roles, id: \.self) { role in
                    Text(role.capitalized)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            // login button
            Button(action: {
                // TODO: connect to real API later
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

#Preview {
    LoginView()
}


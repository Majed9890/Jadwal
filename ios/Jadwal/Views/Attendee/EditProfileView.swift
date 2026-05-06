import SwiftUI

struct EditProfileView: View {
    @State private var name = ""
    @State private var phone = ""
    @State private var city = ""
    @State private var dateOfBirth = ""
    @State private var gender = "male"
    @State private var errorMessage = ""
    @State private var successMessage = ""
    let genders = ["male", "female"]
    
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Full Name", text: $name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Phone Number", text: $phone)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("City", text: $city)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Date of Birth (YYYY-MM-DD)", text: $dateOfBirth)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                Picker("Gender", selection: $gender) {
                    ForEach(genders, id: \.self) { g in
                        Text(g.capitalized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if !successMessage.isEmpty {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
                Button(action: {
                    saveProfile()
                }) {
                    Text("Save Changes")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: UpdateInterestsView()) {
                    Text("Update Interests")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    AuthManager.shared.logout()
                    isLoggedIn = false
                }) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationTitle("Edit Profile")
            .onAppear {
                fetchProfile()
            }
        }
    }
    
    func fetchProfile() {
        let url = URL(string: "http://192.168.3.10:3000/api/attendee/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let attendee = result["attendee"] as? [String: Any] {
                DispatchQueue.main.async {
                    name = attendee["name"] as? String ?? ""
                    phone = attendee["phone_number"] as? String ?? ""
                    city = attendee["city"] as? String ?? ""
                    dateOfBirth = attendee["date_of_birth"] as? String ?? ""
                    gender = attendee["gender"] as? String ?? "male"
                }
            }
        }.resume()
    }
    
    func saveProfile() {
        let url = URL(string: "http://192.168.3.10:3000/api/attendee/edit-profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "name": name,
            "phone_number": phone,
            "city": city,
            "date_of_birth": dateOfBirth,
            "gender": gender
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if result["attendee"] != nil {
                        successMessage = "profile updated successfully"
                    } else if let err = result["error"] as? String {
                        errorMessage = err
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    EditProfileView(isLoggedIn: .constant(true))
}

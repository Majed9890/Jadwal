import SwiftUI

struct OrganizerProfileView: View {
    @Binding var isLoggedIn: Bool
    @State private var entityName = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var contactName = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Entity Name", text: $entityName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Phone Number", text: $phone)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Address", text: $address)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Contact Name", text: $contactName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
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
        let url = URL(string: "http://localhost:3000/api/organizer/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let organizer = result["organizer"] as? [String: Any] {
                DispatchQueue.main.async {
                    entityName = organizer["entity_name"] as? String ?? ""
                    phone = organizer["phone_number"] as? String ?? ""
                    address = organizer["address"] as? String ?? ""
                    contactName = organizer["contact_name"] as? String ?? ""
                }
            }
        }.resume()
    }
    
    func saveProfile() {
        let url = URL(string: "http://localhost:3000/api/organizer/edit-profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "entity_name": entityName,
            "phone_number": phone,
            "address": address,
            "contact_name": contactName
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if result["organizer"] != nil {
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
    OrganizerProfileView(isLoggedIn: .constant(true))
}

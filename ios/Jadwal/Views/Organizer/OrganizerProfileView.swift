import SwiftUI

struct OrganizerProfileView: View {
    @Binding var isLoggedIn: Bool
    @State private var entityName = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var contactName = ""
    @State private var email = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 20)

                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.07))
                                .frame(width: 80, height: 80)
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.white.opacity(0.3))
                        }

                        // Email (read only)
                        if !email.isEmpty {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.4))
                        }

                        // Fields
                        VStack(spacing: 14) {
                            darkField(icon: "building.fill", placeholder: "Entity Name", text: $entityName)
                            darkField(icon: "phone.fill", placeholder: "Phone Number", text: $phone, keyboard: .phonePad)
                            darkField(icon: "mappin.fill", placeholder: "Address", text: $address)
                            darkField(icon: "person.fill", placeholder: "Contact Name", text: $contactName)
                        }
                        .padding(.horizontal, 24)

                        if !errorMessage.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                                Text(errorMessage).font(.caption).foregroundColor(.red)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                        }

                        if !successMessage.isEmpty {
                            HStack {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                Text(successMessage).font(.caption).foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                        }

                        VStack(spacing: 12) {
                            Button(action: { saveProfile() }) {
                                Text("Save Changes")
                                    .font(.headline).fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color(red: 0.6, green: 1.0, blue: 0.0))
                                    .cornerRadius(16)
                            }

                            Button(action: { AuthManager.shared.logout(); isLoggedIn = false }) {
                                Text("Sign Out")
                                    .font(.headline).fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { fetchProfile() }
        }
    }

    func darkField(icon: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0)).frame(width: 20)
            TextField("", text: text)
                .placeholder(when: text.wrappedValue.isEmpty) { Text(placeholder).foregroundColor(.white.opacity(0.3)) }
                .foregroundColor(.white).keyboardType(keyboard).autocapitalization(.none)
        }
        .padding(.horizontal, 18).padding(.vertical, 16)
        .background(Color.white.opacity(0.07)).cornerRadius(14)
    }

    func fetchProfile() {
        let url = URL(string: "\(APIConfig.baseURL)/api/organizer/profile")!
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
                    email = organizer["email"] as? String ?? ""
                }
            }
        }.resume()
    }

    func saveProfile() {
        let url = URL(string: "\(APIConfig.baseURL)/api/organizer/edit-profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = ["entity_name": entityName, "phone_number": phone, "address": address, "contact_name": contactName]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if result["organizer"] != nil { successMessage = "profile updated successfully"; errorMessage = "" }
                    else if let err = result["error"] as? String { errorMessage = err; successMessage = "" }
                }
            }
        }.resume()
    }
}

#Preview { OrganizerProfileView(isLoggedIn: .constant(true)) }

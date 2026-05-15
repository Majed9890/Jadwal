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
    let cityOptions = ["Riyadh", "Jeddah", "Mecca", "Medina", "Dammam", "Khobar", "Dhahran", "Taif", "Tabuk", "Abha", "Khamis Mushait", "Buraidah", "Hail", "Najran", "Jubail", "Yanbu", "Al Ahsa", "Arar", "Sakaka", "Jazan"]
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 20)

                        // Avatar placeholder
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.07))
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.white.opacity(0.3))
                        }

                        // Fields
                        VStack(spacing: 14) {
                            darkField(icon: "person.fill", placeholder: "Full Name", text: $name)
                            darkField(icon: "phone.fill", placeholder: "Phone Number", text: $phone, keyboard: .phonePad)
                            dropdownField(icon: "building.2.fill", placeholder: "City", selection: $city, options: cityOptions)
                            darkField(icon: "calendar", placeholder: "Date of Birth (YYYY-MM-DD)", text: $dateOfBirth)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Gender")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.5))
                                HStack(spacing: 10) {
                                    ForEach(genders, id: \.self) { g in
                                        Button(action: { gender = g }) {
                                            Text(g.capitalized)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 14)
                                                .background(gender == g ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.white.opacity(0.07))
                                                .foregroundColor(gender == g ? Color(red: 0.08, green: 0.11, blue: 0.08) : Color.white.opacity(0.6))
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                            }
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

                        // Buttons
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

                            NavigationLink(destination: UpdateInterestsView()) {
                                Text("Update Interests")
                                    .font(.headline).fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color.white.opacity(0.07))
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

    func dropdownField(icon: String, placeholder: String, selection: Binding<String>, options: [String]) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selection.wrappedValue = option
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                    .frame(width: 20)
                Text(selection.wrappedValue.isEmpty ? placeholder : selection.wrappedValue)
                    .foregroundColor(selection.wrappedValue.isEmpty ? .white.opacity(0.3) : .white)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.07))
            .cornerRadius(14)
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
        if city.isEmpty {
            errorMessage = "please select a city"
            successMessage = ""
            return
        }

        let url = URL(string: "http://192.168.3.10:3000/api/attendee/edit-profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = ["name": name, "phone_number": phone, "city": city, "date_of_birth": dateOfBirth, "gender": gender]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if result["attendee"] != nil { successMessage = "profile updated successfully"; errorMessage = "" }
                    else if let err = result["error"] as? String { errorMessage = err; successMessage = "" }
                }
            }
        }.resume()
    }
}

#Preview {
    EditProfileView(isLoggedIn: .constant(true))
}

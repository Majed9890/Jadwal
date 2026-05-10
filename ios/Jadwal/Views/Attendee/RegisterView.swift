import SwiftUI

struct RegisterView: View {
    @State private var selectedType = "attendee"
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        if selectedType == "attendee" { AttendeeRegisterView(selectedType: $selectedType, presentationMode: presentationMode) }
        else { OrganizerRegisterView(selectedType: $selectedType, presentationMode: presentationMode) }
    }
}

struct AttendeeRegisterView: View {
    @Binding var selectedType: String
    var presentationMode: Binding<PresentationMode>
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var city = ""
    @State private var dateOfBirth = ""
    @State private var gender = "male"
    @State private var errorMessage = ""
    @State private var showOTP = false
    let genders = ["male", "female"]

    var body: some View {
        if showOTP { OTPView(email: email, role: "attendee") }
        else {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 20)

                        // Back button + title
                        HStack {
                            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.07))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 24)

                        VStack(spacing: 8) {
                            Text("Create Account")
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(.white)
                            Text("Join Jadwal today")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                        }

                        HStack(spacing: 10) {
                            Button(action: { selectedType = "attendee" }) {
                                Text("Attendee")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(selectedType == "attendee" ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.white.opacity(0.07))
                                    .foregroundColor(selectedType == "attendee" ? Color(red: 0.08, green: 0.11, blue: 0.08) : Color.white.opacity(0.6))
                                    .cornerRadius(12)
                            }
                            Button(action: { selectedType = "organizer" }) {
                                Text("Organizer")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(selectedType == "organizer" ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.white.opacity(0.07))
                                    .foregroundColor(selectedType == "organizer" ? Color(red: 0.08, green: 0.11, blue: 0.08) : Color.white.opacity(0.6))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 24)

                        VStack(spacing: 14) {
                            darkField(icon: "person.fill", placeholder: "Full Name", text: $name)
                            darkField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboard: .emailAddress)
                            darkSecureField(icon: "lock.fill", placeholder: "Password", text: $password)
                            darkField(icon: "phone.fill", placeholder: "Phone Number", text: $phone, keyboard: .phonePad)
                            darkField(icon: "building.2.fill", placeholder: "City", text: $city)
                            darkField(icon: "calendar", placeholder: "Date of Birth (YYYY-MM-DD)", text: $dateOfBirth)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Gender")
                                    .font(.caption).fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.5))
                                HStack(spacing: 10) {
                                    ForEach(genders, id: \.self) { g in
                                        Button(action: { gender = g }) {
                                            Text(g.capitalized)
                                                .font(.subheadline).fontWeight(.semibold)
                                                .frame(maxWidth: .infinity).padding(.vertical, 12)
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

                        Button(action: { register() }) {
                            Text("Register")
                                .font(.headline).fontWeight(.bold)
                                .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                .frame(maxWidth: .infinity).padding(.vertical, 18)
                                .background(Color(red: 0.6, green: 1.0, blue: 0.0)).cornerRadius(16)
                        }
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarHidden(true)
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

    func darkSecureField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0)).frame(width: 20)
            SecureField("", text: text)
                .placeholder(when: text.wrappedValue.isEmpty) { Text(placeholder).foregroundColor(.white.opacity(0.3)) }
                .foregroundColor(.white)
        }
        .padding(.horizontal, 18).padding(.vertical, 16)
        .background(Color.white.opacity(0.07)).cornerRadius(14)
    }

    func register() {
        let url = URL(string: "http://192.168.3.10:3000/api/auth/register/attendee")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["name": name, "email": email, "password": password, "phone_number": phone, "city": city, "date_of_birth": dateOfBirth, "gender": gender]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { DispatchQueue.main.async { errorMessage = error.localizedDescription }; return }
            guard let data = data else { DispatchQueue.main.async { errorMessage = "no response from server" }; return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if let _ = result["message"] as? String { showOTP = true }
                    else if let err = result["error"] as? String { errorMessage = err }
                }
            }
        }.resume()
    }
}

struct OrganizerRegisterView: View {
    @Binding var selectedType: String
    var presentationMode: Binding<PresentationMode>
    @State private var entityName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var licenseNum = ""
    @State private var address = ""
    @State private var contactName = ""
    @State private var errorMessage = ""
    @State private var showOTP = false

    var body: some View {
        if showOTP { OTPView(email: email, role: "organizer") }
        else {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 20)

                        // Back button
                        HStack {
                            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.07))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 24)

                        VStack(spacing: 8) {
                            Text("Organizer Registration")
                                .font(.system(size: 30, weight: .heavy))
                                .foregroundColor(.white)
                            Text("Set up your organizer account")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                        }

                        HStack(spacing: 10) {
                            Button(action: { selectedType = "attendee" }) {
                                Text("Attendee")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(selectedType == "attendee" ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.white.opacity(0.07))
                                    .foregroundColor(selectedType == "attendee" ? Color(red: 0.08, green: 0.11, blue: 0.08) : Color.white.opacity(0.6))
                                    .cornerRadius(12)
                            }
                            Button(action: { selectedType = "organizer" }) {
                                Text("Organizer")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(selectedType == "organizer" ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.white.opacity(0.07))
                                    .foregroundColor(selectedType == "organizer" ? Color(red: 0.08, green: 0.11, blue: 0.08) : Color.white.opacity(0.6))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 24)

                        VStack(spacing: 14) {
                            darkField(icon: "building.fill", placeholder: "Entity Name", text: $entityName)
                            darkField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboard: .emailAddress)
                            darkSecureField(icon: "lock.fill", placeholder: "Password", text: $password)
                            darkField(icon: "phone.fill", placeholder: "Phone Number", text: $phone, keyboard: .phonePad)
                            darkField(icon: "doc.fill", placeholder: "License Number", text: $licenseNum)
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

                        Button(action: { register() }) {
                            Text("Register")
                                .font(.headline).fontWeight(.bold)
                                .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                .frame(maxWidth: .infinity).padding(.vertical, 18)
                                .background(Color(red: 0.6, green: 1.0, blue: 0.0)).cornerRadius(16)
                        }
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarHidden(true)
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

    func darkSecureField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0)).frame(width: 20)
            SecureField("", text: text)
                .placeholder(when: text.wrappedValue.isEmpty) { Text(placeholder).foregroundColor(.white.opacity(0.3)) }
                .foregroundColor(.white)
        }
        .padding(.horizontal, 18).padding(.vertical, 16)
        .background(Color.white.opacity(0.07)).cornerRadius(14)
    }

    func register() {
        let url = URL(string: "http://192.168.3.10:3000/api/auth/register/organizer")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["entity_name": entityName, "email": email, "password": password, "phone_number": phone, "license_num": licenseNum, "address": address, "contact_name": contactName]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { DispatchQueue.main.async { errorMessage = error.localizedDescription }; return }
            guard let data = data else { DispatchQueue.main.async { errorMessage = "no response from server" }; return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if let _ = result["message"] as? String { showOTP = true }
                    else if let err = result["error"] as? String { errorMessage = err }
                }
            }
        }.resume()
    }
}

#Preview { RegisterView() }

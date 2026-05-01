import SwiftUI

struct RegisterView: View {
    @State private var selectedType = "attendee"
    
    var body: some View {
        if selectedType == "attendee" {
            AttendeeRegisterView(selectedType: $selectedType)
        } else {
            OrganizerRegisterView(selectedType: $selectedType)
        }
    }
}

struct AttendeeRegisterView: View {
    @Binding var selectedType: String
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
        if showOTP {
            OTPView(email: email, role: "attendee")
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                    
                    Picker("Account Type", selection: $selectedType) {
                        Text("Attendee").tag("attendee")
                        Text("Organizer").tag("organizer")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("Full Name", text: $name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
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
                    
                    Button(action: {
                        register()
                    }) {
                        Text("Register")
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
    
    func register() {
        let url = URL(string: "http://localhost:3000/api/auth/register/attendee")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "phone_number": phone,
            "city": city,
            "date_of_birth": dateOfBirth,
            "gender": gender
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "no response from server"
                }
                return
            }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if let _ = result["message"] as? String {
                        showOTP = true
                    } else if let err = result["error"] as? String {
                        errorMessage = err
                    }
                }
            }
        }.resume()
    }
}

struct OrganizerRegisterView: View {
    @Binding var selectedType: String
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
        if showOTP {
            OTPView(email: email, role: "organizer")
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Organizer Registration")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                    
                    Picker("Account Type", selection: $selectedType) {
                        Text("Attendee").tag("attendee")
                        Text("Organizer").tag("organizer")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("Entity Name", text: $entityName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    TextField("Phone Number", text: $phone)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    TextField("License Number", text: $licenseNum)
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
                    
                    Button(action: {
                        register()
                    }) {
                        Text("Register")
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
    
    func register() {
        let url = URL(string: "http://localhost:3000/api/auth/register/organizer")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "entity_name": entityName,
            "email": email,
            "password": password,
            "phone_number": phone,
            "license_num": licenseNum,
            "address": address,
            "contact_name": contactName
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "no response from server"
                }
                return
            }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if let _ = result["message"] as? String {
                        showOTP = true
                    } else if let err = result["error"] as? String {
                        errorMessage = err
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    RegisterView()
}

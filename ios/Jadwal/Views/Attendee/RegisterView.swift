import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var city = ""
    @State private var dateOfBirth = ""
    @State private var gender = "male"
    let genders = ["male", "female"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
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
                                
                                Button(action: {
                                    // TODO: connect to API
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

                #Preview {
                    RegisterView()
                }


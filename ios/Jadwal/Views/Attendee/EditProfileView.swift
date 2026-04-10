import SwiftUI

struct EditProfileView: View {
    @State private var name = "Majed Test"
    @State private var phone = "0501111111"
    @State private var city = "Riyadh"
    @State private var dateOfBirth = "2000-01-01"
    @State private var gender = "male"
    let genders = ["male", "female"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
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
            
            Button(action: {
                // TODO: connect to API
            }) {
                Text("Save Changes")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
    EditProfileView()
}

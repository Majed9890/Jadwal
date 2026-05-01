import SwiftUI

struct OTPView: View {
    let email: String
    let role: String
    @State private var otp = ""
    @State private var errorMessage = ""
    @State private var isVerified = false
    
    var body: some View {
        if isVerified {
            LoginView()
        } else {
            VStack(spacing: 20) {
                Text("Verify Your Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 60)
                
                Text("Enter the OTP sent to your Email")
                    .foregroundColor(.gray)
                
                Spacer()
                
                TextField("Enter OTP", text: $otp)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.numberPad)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    verifyOTP()
                }) {
                    Text("Verify")
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
    
    func verifyOTP() {
        let url = URL(string: "http://localhost:3000/api/auth/verify-otp")!
        var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body: [String: Any] = [
                    "email": email,
                    "otp_code": otp,
                    "role": role
                ]
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data else { return }
                    
                    if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        DispatchQueue.main.async {
                            if let message = result["message"] as? String, message.contains("successfully") {
                                isVerified = true
                            } else if let err = result["error"] as? String {
                                errorMessage = err
                            }
                        }
                    }
                }.resume()
            }
        }

        #Preview {
            OTPView(email: "test@test.com", role: "attendee")
        }

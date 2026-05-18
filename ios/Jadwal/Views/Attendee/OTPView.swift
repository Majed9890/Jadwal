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
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 60)

                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.15))
                                .frame(width: 80, height: 80)
                            Image(systemName: "envelope.badge.fill")
                                .font(.system(size: 34))
                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                        }

                        // Title
                        VStack(spacing: 8) {
                            Text("Check Your Email")
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundColor(.white)
                            Text("We sent a 6-digit code to")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                            Text(email)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                        }

                        // OTP field
                        VStack(spacing: 14) {
                            HStack(spacing: 12) {
                                Image(systemName: "number")
                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                    .frame(width: 20)
                                TextField("", text: $otp)
                                    .placeholder(when: otp.isEmpty) {
                                        Text("Enter 6-digit OTP").foregroundColor(.white.opacity(0.3))
                                    }
                                    .foregroundColor(.white)
                                    .keyboardType(.numberPad)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(16)

                            if !errorMessage.isEmpty {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button(action: { verifyOTP() }) {
                                Text("Verify Account")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color(red: 0.6, green: 1.0, blue: 0.0))
                                    .cornerRadius(16)
                            }
                            .padding(.top, 6)
                        }
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    func verifyOTP() {
        let url = URL(string: "\(APIConfig.baseURL)/api/auth/verify-otp")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["email": email, "otp_code": otp, "role": role]
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

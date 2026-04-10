import SwiftUI

struct OTPView: View {
    @State private var otp = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Verify Your Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 60)
            
            Text("Enter the OTP sent to your phone")
                .foregroundColor(.gray)
            
            Spacer()
            
            TextField("Enter OTP", text: $otp)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .keyboardType(.numberPad)
            
            Button(action: {
                // TODO: connect to API
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

#Preview {
    OTPView()
}


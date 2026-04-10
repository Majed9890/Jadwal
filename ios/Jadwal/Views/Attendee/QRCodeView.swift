import SwiftUI

struct QRCodeView: View {
    let ticket: [String: String]
    @State private var otp = ""
    @State private var showQR = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(ticket["event"] ?? "")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Tier: \(ticket["tier"] ?? "")")
                .foregroundColor(.gray)
            
            if showQR {
                // dummy QR code placeholder
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text("QR Code")
                            .foregroundColor(.gray)
                    )
            } else {
                TextField("Enter OTP", text: $otp)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.numberPad)
                
                Button(action: {
                    // TODO: connect to API
                    showQR = true
                }) {
                    Text("View QR Code")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationTitle("QR Code")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    QRCodeView(ticket: ["event": "Rock Concert", "tier": "VIP", "price": "150", "status": "active"])
}

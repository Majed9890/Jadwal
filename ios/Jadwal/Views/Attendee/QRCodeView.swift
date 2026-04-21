import SwiftUI

struct QRCodeView: View {
    let ticket: [String: Any]
    @State private var otp = ""
    @State private var qrImageData: Data? = nil
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var showQR = false
    @State private var timestamp = ""
    
    var body: some View {
        VStack(spacing: 20) {
            let eventInfo = ticket["Event"] as? [String: Any]
            Text(eventInfo?["event_name"] as? String ?? "Ticket")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Tier: \(ticket["tier"] as? String ?? "")")
                .foregroundColor(.gray)
            
            Text("Status: \(ticket["ticket_status"] as? String ?? "")")
                .foregroundColor(.green)
            
            if showQR {
                if let imageData = qrImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 200, height: 200)
                }
                if !timestamp.isEmpty {
                    Text("Generated at: \(timestamp)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                Text("OTP sent to your email")
                    .foregroundColor(.green)
                    .font(.caption)
                
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
                    viewQRCode()
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
        .onAppear {
            refreshOTP()
        }
    }
    
    func refreshOTP() {
        guard let ticketId = ticket["ticket_id"] as? String else { return }
        
        let url = URL(string: "http://localhost:3000/api/tickets/refresh-otp")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["ticket_id": ticketId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }
    
    func viewQRCode() {
        guard let ticketId = ticket["ticket_id"] as? String else { return }
        
        let url = URL(string: "http://localhost:3000/api/tickets/qr-code")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "ticket_id": ticketId,
            "otp_code": otp
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if let qrString = result["qr_code"] as? String {
                        let base64String = qrString.replacingOccurrences(of: "data:image/png;base64,", with: "")
                        if let imageData = Data(base64Encoded: base64String) {
                            qrImageData = imageData
                            showQR = true
                        }
                        timestamp = result["timestamp"] as? String ?? ""
                    } else if let err = result["error"] as? String {
                        errorMessage = err
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    QRCodeView(ticket: ["ticket_id": "123", "tier": "VIP", "ticket_status": "active"])
}

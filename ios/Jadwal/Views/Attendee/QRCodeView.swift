import SwiftUI
import Combine

struct QRCodeView: View {
    let ticket: [String: Any]
    @State private var otp = ""
    @State private var qrImageData: Data? = nil
    @State private var errorMessage = ""
    @State private var showQR = false
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Riyadh")
        return formatter.string(from: currentTime)
    }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.08)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    let eventInfo = ticket["Event"] as? [String: Any]

                    // Event name + tier
                    VStack(spacing: 8) {
                        Text(eventInfo?["event_name"] as? String ?? "Ticket")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 8) {
                            Text(ticket["tier"] as? String ?? "")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.15))
                                .cornerRadius(8)

                            Text(ticket["ticket_status"] as? String ?? "")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 24)

                    if showQR {
                        // QR code display
                        VStack(spacing: 16) {
                            if let imageData = qrImageData, let uiImage = UIImage(data: imageData) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .frame(width: 230, height: 230)
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 200, height: 200)
                                }
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                Text(formattedTime)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .onReceive(timer) { _ in currentTime = Date() }
                        }
                        .padding(24)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(20)
                        .padding(.horizontal, 24)

                    } else {
                        // OTP entry
                        VStack(spacing: 16) {
                            HStack(spacing: 10) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                Text("OTP sent to your email")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(12)
                            .background(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.08))
                            .cornerRadius(10)

                            HStack(spacing: 12) {
                                Image(systemName: "number")
                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                    .frame(width: 20)
                                TextField("", text: $otp)
                                    .placeholder(when: otp.isEmpty) {
                                        Text("Enter OTP code").foregroundColor(.white.opacity(0.3))
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

                            Button(action: { viewQRCode() }) {
                                Text("View QR Code")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color(red: 0.6, green: 1.0, blue: 0.0))
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("QR Code")
        .onAppear { refreshOTP() }
    }

    func refreshOTP() {
        guard let ticketId = ticket["ticket_id"] as? String else { return }
        let url = URL(string: "\(APIConfig.baseURL)/api/tickets/refresh-otp")!
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
        let url = URL(string: "\(APIConfig.baseURL)/api/tickets/qr-code")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = ["ticket_id": ticketId, "otp_code": otp]
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

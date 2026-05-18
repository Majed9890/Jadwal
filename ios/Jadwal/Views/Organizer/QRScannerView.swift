import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @State private var scannedCode = ""
    @State private var resultMessage = ""
    @State private var resultSuccess = true
    @State private var isScanning = true
    @State private var cameraPermissionGranted = false
    @State private var scannerID = UUID()

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.08)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 10)

                Text("Scan Attendee QR Code")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)

                // Camera view
                ZStack {
                    if cameraPermissionGranted {
                        CameraPreview(scannedCode: $scannedCode, isScanning: $isScanning)
                            .id(scannerID)
                            .frame(height: 300)
                            .cornerRadius(20)
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.07))
                            .frame(height: 300)
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.2))
                                    Text("Camera access required")
                                        .foregroundColor(.white.opacity(0.4))
                                        .font(.subheadline)
                                }
                            )
                    }

                    // Scanning frame overlay
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.6, green: 1.0, blue: 0.0), lineWidth: 3)
                        .frame(height: 300)
                }
                .padding(.horizontal, 20)

                // Result message
                if !resultMessage.isEmpty {
                    HStack(spacing: 12) {
                        Image(systemName: resultSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(resultSuccess ? Color(red: 0.6, green: 1.0, blue: 0.0) : .red)
                            .font(.system(size: 20))
                        Text(resultMessage)
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(resultSuccess ? Color(red: 0.6, green: 1.0, blue: 0.0) : .red)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(16)
                    .background((resultSuccess ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.red).opacity(0.1))
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
                }

                Button(action: {
                    scannedCode = ""
                    resultMessage = ""
                    isScanning = true
                    scannerID = UUID()
                }) {
                    Text("Scan Again")
                        .font(.headline).fontWeight(.bold)
                        .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 0.6, green: 1.0, blue: 0.0))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .navigationTitle("Check In")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { checkCameraPermission() }
        .onChange(of: scannedCode) { newValue in
            if !newValue.isEmpty && isScanning { isScanning = false; checkInTicket(qrString: newValue) }
        }
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: cameraPermissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { cameraPermissionGranted = granted }
            }
        default: cameraPermissionGranted = false
        }
    }

    func checkInTicket(qrString: String) {
        guard let jsonData = qrString.data(using: .utf8),
              let qrInfo = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let ticketId = qrInfo["ticket_id"] as? String else {
            resultMessage = "Invalid QR code"; resultSuccess = false; return
        }
        let url = URL(string: "\(APIConfig.baseURL)/api/tickets/checkin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = ["ticket_id": ticketId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if let message = result["message"] as? String { resultMessage = message; resultSuccess = true }
                    else if let err = result["error"] as? String { resultMessage = err; resultSuccess = false }
                }
            }
        }.resume()
    }
}

struct CameraPreview: UIViewRepresentable {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool

    func makeCoordinator() -> Coordinator { Coordinator(scannedCode: $scannedCode, isScanning: $isScanning) }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        guard let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: device) else { return view }
        let session = AVCaptureSession()
        session.addInput(input)
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
        output.metadataObjectTypes = [.qr]
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = UIScreen.main.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        DispatchQueue.global(qos: .background).async { session.startRunning() }
        context.coordinator.session = session
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        @Binding var scannedCode: String
        @Binding var isScanning: Bool
        var session: AVCaptureSession?
        init(scannedCode: Binding<String>, isScanning: Binding<Bool>) { _scannedCode = scannedCode; _isScanning = isScanning }
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let code = object.stringValue, isScanning {
                session?.stopRunning(); scannedCode = code
            }
        }
    }
}

#Preview { QRScannerView() }

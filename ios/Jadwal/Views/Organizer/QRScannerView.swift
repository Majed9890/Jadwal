import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @State private var scannedCode = ""
    @State private var resultMessage = ""
    @State private var resultColor = Color.green
    @State private var isScanning = true
    @State private var cameraPermissionGranted = false
    @State private var scannerID = UUID()

    var body: some View {
        VStack(spacing: 20) {
            Text("Scan Attendee QR Code")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)

            if cameraPermissionGranted {
                ZStack {
                    CameraPreview(scannedCode: $scannedCode, isScanning: $isScanning)
                        .id(scannerID)
                        .frame(height: 300)
                        .cornerRadius(12)

                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(height: 300)
                }
                .padding(.horizontal, 16)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(height: 300)
                    .overlay(
                        Text("Camera access required")
                            .foregroundColor(.gray)
                    )
                    .padding(.horizontal, 16)
            }

            if !resultMessage.isEmpty {
                Text(resultMessage)
                    .foregroundColor(resultColor)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
            }

            Button(action: {
                scannedCode = ""
                resultMessage = ""
                isScanning = true
                scannerID = UUID()
            }) {
                Text("Scan Again")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .navigationTitle("Check In")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkCameraPermission()
        }
        .onChange(of: scannedCode) { newValue in
            if !newValue.isEmpty && isScanning {
                isScanning = false
                checkInTicket(qrString: newValue)
            }
        }
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionGranted = granted
                }
            }
        default:
            cameraPermissionGranted = false
        }
    }

    func checkInTicket(qrString: String) {
        guard let jsonData = qrString.data(using: .utf8),
              let qrInfo = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let ticketId = qrInfo["ticket_id"] as? String else {
            resultMessage = "invalid QR code"
            resultColor = .red
            return
        }

        let url = URL(string: "http://192.168.3.10:3000/api/tickets/checkin")!
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
                    if let message = result["message"] as? String {
                        resultMessage = "✅ " + message
                        resultColor = .green
                    } else if let err = result["error"] as? String {
                        resultMessage = "❌ " + err
                        resultColor = .red
                    }
                }
            }
        }.resume()
    }
}

struct CameraPreview: UIViewRepresentable {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scannedCode, isScanning: $isScanning)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return view
        }

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

        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }

        context.coordinator.session = session

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        @Binding var scannedCode: String
        @Binding var isScanning: Bool
        var session: AVCaptureSession?

        init(scannedCode: Binding<String>, isScanning: Binding<Bool>) {
            _scannedCode = scannedCode
            _isScanning = isScanning
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let code = object.stringValue,
               isScanning {
                session?.stopRunning()
                scannedCode = code
            }
        }
    }
}

import SwiftUI

struct PendingOrganizersView: View {
    @State private var organizers: [[String: Any]] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08)
                    .ignoresSafeArea()

                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.6, green: 1.0, blue: 0.0)))
                            .scaleEffect(1.4)
                        Text("Loading...")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.subheadline)
                    }
                } else if organizers.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.clock")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.15))
                        Text("No pending organizers")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.4))
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(0..<organizers.count, id: \.self) { index in
                                let organizer = organizers[index]
                                VStack(alignment: .leading, spacing: 14) {

                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.15))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: "building.fill")
                                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(organizer["entity_name"] as? String ?? "")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                            Text(organizer["email"] as? String ?? "")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                        Spacer()
                                        Text("Pending")
                                            .font(.caption).fontWeight(.semibold)
                                            .foregroundColor(.orange)
                                            .padding(.horizontal, 10).padding(.vertical, 4)
                                            .background(Color.orange.opacity(0.15))
                                            .cornerRadius(8)
                                    }

                                    VStack(spacing: 8) {
                                        infoRow(label: "Contact", value: organizer["contact_name"] as? String ?? "")
                                        infoRow(label: "Phone", value: organizer["phone_number"] as? String ?? "")
                                        infoRow(label: "License", value: organizer["license_num"] as? String ?? "")
                                        infoRow(label: "Address", value: organizer["address"] as? String ?? "")
                                    }

                                    HStack(spacing: 10) {
                                        Button(action: {
                                            updateStatus(organizer_id: organizer["organizer_id"] as? String ?? "", status: "approved")
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "checkmark.circle.fill")
                                                Text("Approve")
                                            }
                                            .font(.subheadline).fontWeight(.bold)
                                            .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color(red: 0.6, green: 1.0, blue: 0.0))
                                            .cornerRadius(12)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())

                                        Button(action: {
                                            updateStatus(organizer_id: organizer["organizer_id"] as? String ?? "", status: "rejected")
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "xmark.circle.fill")
                                                Text("Reject")
                                            }
                                            .font(.subheadline).fontWeight(.bold)
                                            .foregroundColor(.red)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(12)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                .padding(16)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Pending Organizers")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { fetchOrganizers() }
        }
    }

    func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
        }
    }

    func fetchOrganizers() {
        let url = URL(string: "http://192.168.3.10:3000/api/admin/organizers/pending")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let list = result["organizers"] as? [[String: Any]] {
                DispatchQueue.main.async { organizers = list; isLoading = false }
            }
        }.resume()
    }

    func updateStatus(organizer_id: String, status: String) {
        let url = URL(string: "http://192.168.3.10:3000/api/admin/organizers/status")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = ["organizer_id": organizer_id, "status": status]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async { fetchOrganizers() }
        }.resume()
    }
}

#Preview { PendingOrganizersView() }

import SwiftUI

struct PendingOrganizersView: View {
    @State private var organizers: [[String: Any]] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                } else if organizers.isEmpty {
                    Text("No pending organizers")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(0..<organizers.count, id: \.self) { index in
                                let organizer = organizers[index]
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(organizer["entity_name"] as? String ?? "")
                                        .font(.headline)
                                    Text(organizer["email"] as? String ?? "")
                                        .foregroundColor(.gray)
                                    Text("Contact: \(organizer["contact_name"] as? String ?? "")")
                                        .font(.caption)
                                    Text("Phone: \(organizer["phone_number"] as? String ?? "")")
                                        .font(.caption)
                                    Text("License: \(organizer["license_num"] as? String ?? "")")
                                        .font(.caption)
                                    Text("Address: \(organizer["address"] as? String ?? "")")
                                        .font(.caption)

                                    HStack(spacing: 10) {
                                        Button {
                                            updateStatus(organizer_id: organizer["organizer_id"] as? String ?? "", status: "approved")
                                        } label: {
                                            Text("Approve")
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(10)
                                                .background(Color.green)
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())

                                        Button {
                                            updateStatus(organizer_id: organizer["organizer_id"] as? String ?? "", status: "rejected")
                                        } label: {
                                            Text("Reject")
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(10)
                                                .background(Color.red)
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .navigationTitle("Pending Organizers")
            .onAppear {
                fetchOrganizers()
            }
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
                DispatchQueue.main.async {
                    organizers = list
                    isLoading = false
                }
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

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                fetchOrganizers()
            }
        }.resume()
    }
}

#Preview {
    PendingOrganizersView()
}

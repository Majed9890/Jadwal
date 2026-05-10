import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [[String: Any]] = []
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
                        Text("Loading notifications...")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.subheadline)
                    }
                } else if notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.15))
                        Text("No notifications yet")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.4))
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(0..<notifications.count, id: \.self) { index in
                                let notification = notifications[index]
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.15))
                                            .frame(width: 42, height: 42)
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                    }

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(notification["message"] as? String ?? "")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text(notification["created_at"] as? String ?? "")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.4))
                                    }

                                    Spacer()
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
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { fetchNotifications() }
        }
    }

    func fetchNotifications() {
        let url = URL(string: "http://192.168.3.10:3000/api/notifications")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let notifList = result["notifications"] as? [[String: Any]] {
                DispatchQueue.main.async { notifications = notifList; isLoading = false }
            }
        }.resume()
    }
}

#Preview { NotificationsView() }

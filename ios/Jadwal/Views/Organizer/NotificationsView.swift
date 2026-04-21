import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [[String: Any]] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading notifications...")
                } else if notifications.isEmpty {
                    Text("No notifications yet")
                        .foregroundColor(.gray)
                } else {
                    List(0..<notifications.count, id: \.self) { index in
                        let notification = notifications[index]
                        VStack(alignment: .leading, spacing: 5) {
                            Text(notification["message"] as? String ?? "")
                                .font(.subheadline)
                            Text(notification["created_at"] as? String ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Notifications")
            .onAppear {
                fetchNotifications()
            }
        }
    }
    
    func fetchNotifications() {
        let url = URL(string: "http://localhost:3000/api/notifications")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let notifList = result["notifications"] as? [[String: Any]] {
                DispatchQueue.main.async {
                    notifications = notifList
                    isLoading = false
                }
            }
        }.resume()
    }
}

#Preview {
    NotificationsView()
}

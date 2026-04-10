import SwiftUI

struct NotificationsView: View {
    let dummyNotifications = [
        ["message": "Your event Rock Concert has been approved!", "date": "2026-04-01"],
        ["message": "Your event Art Exhibition has been rejected.", "date": "2026-04-02"],
        ["message": "Your event Tech Conference is under review.", "date": "2026-04-03"]
    ]
    
    var body: some View {
        NavigationView {
            List(dummyNotifications, id: \.self) { notification in
                VStack(alignment: .leading, spacing: 5) {
                    Text(notification["message"] ?? "")
                        .font(.subheadline)
                    Text(notification["date"] ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Notifications")
        }
    }
}

#Preview {
    NotificationsView()
}


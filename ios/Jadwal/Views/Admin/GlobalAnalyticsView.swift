import SwiftUI

struct GlobalAnalyticsView: View {
    @State private var totalAttendees = 0
    @State private var totalOrganizers = 0
    @State private var totalTickets = 0
    @State private var totalRevenue = 0.0
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
                        Text("Loading analytics...")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.subheadline)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            Spacer().frame(height: 10)

                            // Top 2 cards
                            HStack(spacing: 14) {
                                analyticsCard(
                                    icon: "person.3.fill",
                                    title: "Total Attendees",
                                    value: "\(totalAttendees)",
                                    color: Color(red: 0.6, green: 1.0, blue: 0.0)
                                )
                                analyticsCard(
                                    icon: "building.2.fill",
                                    title: "Total Organizers",
                                    value: "\(totalOrganizers)",
                                    color: Color(red: 0.6, green: 1.0, blue: 0.0)
                                )
                            }

                            // Bottom 2 cards
                            HStack(spacing: 14) {
                                analyticsCard(
                                    icon: "ticket.fill",
                                    title: "Tickets Sold",
                                    value: "\(totalTickets)",
                                    color: Color(red: 0.6, green: 1.0, blue: 0.0)
                                )
                                analyticsCard(
                                    icon: "banknote.fill",
                                    title: "Total Revenue",
                                    value: "SAR \(Int(totalRevenue))",
                                    color: Color(red: 0.6, green: 1.0, blue: 0.0)
                                )
                            }

                            // Summary bar
                            VStack(spacing: 14) {
                                Text("Platform Overview")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                summaryRow(label: "Avg Revenue per Ticket", value: totalTickets > 0 ? "SAR \(Int(totalRevenue / Double(totalTickets)))" : "N/A")
                                summaryRow(label: "Avg Tickets per Organizer", value: totalOrganizers > 0 ? "\(totalTickets / totalOrganizers)" : "N/A")
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(16)

                            Spacer().frame(height: 30)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { fetchAnalytics() }
        }
    }

    func analyticsCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }

    func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }

    func fetchAnalytics() {
        let url = URL(string: "http://192.168.3.10:3000/api/admin/analytics")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    totalAttendees = result["total_attendees"] as? Int ?? 0
                    totalOrganizers = result["total_organizers"] as? Int ?? 0
                    totalTickets = result["total_tickets_sold"] as? Int ?? 0
                    totalRevenue = result["total_revenue"] as? Double ?? 0.0
                    isLoading = false
                }
            }
        }.resume()
    }
}

#Preview { GlobalAnalyticsView() }

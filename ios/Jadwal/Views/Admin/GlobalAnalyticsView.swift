import SwiftUI
import Charts

struct GlobalAnalyticsView: View {
    @Binding var isLoggedIn: Bool
    @State private var totalAttendees = 0
    @State private var totalOrganizers = 0
    @State private var totalTickets = 0
    @State private var totalRevenue = 0.0
    @State private var avgRevenuePerTicket = 0
    @State private var ticketsPerOrganizer: [[String: Any]] = []
    @State private var isLoading = true
    @State private var selectedOrgSlice: String? = nil

    let pieColors: [Color] = [
        Color(red: 0.6, green: 1.0, blue: 0.0),
        Color.orange,
        Color.blue,
        Color.purple,
        Color.red,
        Color.cyan
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08).ignoresSafeArea()
                if isLoading {
                    loadingView
                } else {
                    contentScroll
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        AuthManager.shared.logout()
                        isLoggedIn = false
                    }) {
                        Text("Sign Out")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
            .onAppear { fetchAnalytics() }
        }
    }

    var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.6, green: 1.0, blue: 0.0)))
                .scaleEffect(1.4)
            Text("Loading analytics...")
                .foregroundColor(.white.opacity(0.5))
                .font(.subheadline)
        }
    }

    var contentScroll: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Spacer().frame(height: 10)
                statCardsSection
                if !ticketsPerOrganizer.isEmpty {
                    organizerBarChart
                    organizerPieChart
                }
                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 20)
        }
    }

    var statCardsSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                analyticsCard(icon: "person.3.fill", title: "Total Attendees", value: "\(totalAttendees)")
                analyticsCard(icon: "building.2.fill", title: "Total Organizers", value: "\(totalOrganizers)")
            }
            HStack(spacing: 14) {
                analyticsCard(icon: "ticket.fill", title: "Tickets Sold", value: "\(totalTickets)")
                analyticsCard(icon: "banknote.fill", title: "Total Revenue", value: "SAR \(Int(totalRevenue))")
            }
            analyticsCard(icon: "chart.line.uptrend.xyaxis", title: "Avg Revenue / Ticket", value: "SAR \(avgRevenuePerTicket)")
        }
    }

    var organizerBarChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tickets Sold per Organizer")
                .font(.headline)
                .foregroundColor(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                Chart {
                    ForEach(0..<ticketsPerOrganizer.count, id: \.self) { index in
                        let item = ticketsPerOrganizer[index]
                        BarMark(
                            x: .value("Organizer", item["organizer_name"] as? String ?? ""),
                            y: .value("Tickets", item["tickets_sold"] as? Int ?? 0)
                        )
                        .foregroundStyle(Color(red: 0.6, green: 1.0, blue: 0.0))
                        .cornerRadius(6)
                        .annotation(position: .top) {
                            Text("\(item["tickets_sold"] as? Int ?? 0)")
                                .font(.caption).foregroundColor(.white)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel().foregroundStyle(Color.white.opacity(0.7)).font(.caption)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine().foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel().foregroundStyle(Color.white.opacity(0.7)).font(.caption)
                    }
                }
                .frame(width: max(CGFloat(ticketsPerOrganizer.count) * 100, 300), height: 220)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }

    var organizerPieChart: some View {
        let totalT = ticketsPerOrganizer.reduce(0) { $0 + ($1["tickets_sold"] as? Int ?? 0) }
        return VStack(alignment: .leading, spacing: 12) {
            Text("Tickets Distribution")
                .font(.headline)
                .foregroundColor(.white)
            ZStack {
                Chart {
                    ForEach(0..<ticketsPerOrganizer.count, id: \.self) { index in
                        let item = ticketsPerOrganizer[index]
                        let name = item["organizer_name"] as? String ?? ""
                        SectorMark(
                            angle: .value("Tickets", item["tickets_sold"] as? Int ?? 0),
                            innerRadius: .ratio(0.5),
                            angularInset: 3
                        )
                        .foregroundStyle(by: .value("Organizer", name))
                        .cornerRadius(4)
                        .opacity(selectedOrgSlice == nil || selectedOrgSlice == name ? 1.0 : 0.4)
                    }
                }
                .chartForegroundStyleScale(orgColorScale())
                .chartLegend(.hidden)
                .frame(height: 200)
                pieCenterLabel(totalT: totalT)
            }
            VStack(spacing: 8) {
                ForEach(0..<ticketsPerOrganizer.count, id: \.self) { index in
                    organizerLegendRow(index: index, totalT: totalT)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }

    func pieCenterLabel(totalT: Int) -> some View {
        Group {
            if let slice = selectedOrgSlice,
               let item = ticketsPerOrganizer.first(where: { $0["organizer_name"] as? String == slice }) {
                let sold = item["tickets_sold"] as? Int ?? 0
                let pct = totalT > 0 ? Int(Double(sold) / Double(totalT) * 100) : 0
                VStack(spacing: 4) {
                    Text(slice)
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("\(sold) tickets")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                    Text("\(pct)%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(width: 100)
            }
        }
    }

    func organizerLegendRow(index: Int, totalT: Int) -> some View {
        let item = ticketsPerOrganizer[index]
        let name = item["organizer_name"] as? String ?? ""
        let sold = item["tickets_sold"] as? Int ?? 0
        let pct = totalT > 0 ? Int(Double(sold) / Double(totalT) * 100) : 0
        let isSelected = selectedOrgSlice == name
        return Button(action: {
            selectedOrgSlice = isSelected ? nil : name
        }) {
            HStack(spacing: 10) {
                Circle()
                    .fill(orgColor(index: index))
                    .frame(width: 12, height: 12)
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(sold) tickets")
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                Text("(\(pct)%)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(10)
            .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
    }

    func orgColor(index: Int) -> Color {
        return pieColors[index % pieColors.count]
    }

    func orgColorScale() -> KeyValuePairs<String, Color> {
        guard !ticketsPerOrganizer.isEmpty else { return [:] }
        if ticketsPerOrganizer.count == 1 {
            let n = ticketsPerOrganizer[0]["organizer_name"] as? String ?? ""
            return [n: pieColors[0]]
        } else if ticketsPerOrganizer.count == 2 {
            let n0 = ticketsPerOrganizer[0]["organizer_name"] as? String ?? ""
            let n1 = ticketsPerOrganizer[1]["organizer_name"] as? String ?? ""
            return [n0: pieColors[0], n1: pieColors[1]]
        } else if ticketsPerOrganizer.count == 3 {
            let n0 = ticketsPerOrganizer[0]["organizer_name"] as? String ?? ""
            let n1 = ticketsPerOrganizer[1]["organizer_name"] as? String ?? ""
            let n2 = ticketsPerOrganizer[2]["organizer_name"] as? String ?? ""
            return [n0: pieColors[0], n1: pieColors[1], n2: pieColors[2]]
        } else {
            let n0 = ticketsPerOrganizer[0]["organizer_name"] as? String ?? ""
            let n1 = ticketsPerOrganizer[1]["organizer_name"] as? String ?? ""
            let n2 = ticketsPerOrganizer[2]["organizer_name"] as? String ?? ""
            let n3 = ticketsPerOrganizer[3]["organizer_name"] as? String ?? ""
            return [n0: pieColors[0], n1: pieColors[1], n2: pieColors[2], n3: pieColors[3]]
        }
    }

    func analyticsCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
            }
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(.white)
            Text(title)
                .font(.caption).fontWeight(.medium)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }

    func fetchAnalytics() {
        let url = URL(string: "\(APIConfig.baseURL)/api/admin/analytics")!
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
                    avgRevenuePerTicket = result["avg_revenue_per_ticket"] as? Int ?? 0
                    ticketsPerOrganizer = result["tickets_per_organizer"] as? [[String: Any]] ?? []
                    isLoading = false
                }
            }
        }.resume()
    }
}

#Preview { GlobalAnalyticsView(isLoggedIn: .constant(true)) }

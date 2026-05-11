import SwiftUI
import Charts

struct OrganizerDashboardView: View {
    @State private var allEvents: [[String: Any]] = []
    @State private var selectedEventId: String = ""
    @State private var stats: [[String: Any]] = []
    @State private var eventStats: EventStatsData? = nil
    @State private var genderStats: [GenderStatItem] = []
    @State private var isLoading = true
    @State private var selectedSlice: String? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08).ignoresSafeArea()
                VStack(spacing: 0) {
                    filterPills
                    contentArea
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { fetchAllEvents() }
        }
    }

    // MARK: - Filter Pills
    var filterPills: some View {
        Group {
            if !allEvents.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        allEventsPill
                        ForEach(0..<allEvents.count, id: \.self) { index in
                            eventPill(index: index)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
            }
        }
    }

    var allEventsPill: some View {
        Button(action: {
            selectedEventId = ""
            eventStats = nil
            fetchDashboard(eventId: nil)
            fetchAllGenderStats()
        }) {
            Text("All Events")
                .font(.subheadline).fontWeight(.semibold)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(selectedEventId.isEmpty ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.white.opacity(0.07))
                .foregroundColor(selectedEventId.isEmpty ? Color(red: 0.08, green: 0.11, blue: 0.08) : .white.opacity(0.7))
                .cornerRadius(20)
        }
    }

    func eventPill(index: Int) -> some View {
        let event = allEvents[index]
        let eventId = event["event_id"] as? String ?? ""
        let eventName = event["event_name"] as? String ?? ""
        let isSelected = selectedEventId == eventId

        return Button(action: {
            selectedEventId = eventId
            fetchDashboard(eventId: eventId)
            fetchEventStats(eventId: eventId)
            fetchSingleGenderStats(eventId: eventId, eventName: eventName)
        }) {
            Text(eventName)
                .font(.subheadline).fontWeight(.semibold)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(isSelected ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.white.opacity(0.07))
                .foregroundColor(isSelected ? Color(red: 0.08, green: 0.11, blue: 0.08) : .white.opacity(0.7))
                .cornerRadius(20)
        }
    }

    // MARK: - Content
    var contentArea: some View {
        Group {
            if isLoading {
                loadingView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if selectedEventId.isEmpty && !stats.isEmpty {
                            salesPerEventChart
                        }
                        if !genderStats.isEmpty {
                            genderChart
                        }
                        if let es = eventStats {
                            eventDetailStats(es: es)
                        }
                        if selectedEventId.isEmpty && stats.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.6, green: 1.0, blue: 0.0)))
                .scaleEffect(1.4)
            Spacer()
        }
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.15))
            Text("No data yet")
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.top, 40)
    }

    // MARK: - Sales per Event Chart
    var salesPerEventChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sales per Event (SAR)")
                .font(.headline)
                .foregroundColor(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                Chart {
                    ForEach(0..<stats.count, id: \.self) { index in
                        let stat = stats[index]
                        BarMark(
                            x: .value("Event", stat["event_name"] as? String ?? ""),
                            y: .value("Sales", stat["sales"] as? Int ?? 0)
                        )
                        .foregroundStyle(Color(red: 0.6, green: 1.0, blue: 0.0))
                        .cornerRadius(6)
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
                .frame(width: max(CGFloat(stats.count) * 80, 300), height: 200)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }

    // MARK: - Gender Chart
    var genderChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attendees by Gender")
                .font(.headline)
                .foregroundColor(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                Chart {
                    ForEach(genderStats, id: \.eventName) { item in
                        BarMark(
                            x: .value("Event", item.eventName),
                            y: .value("Count", item.male)
                        )
                        .foregroundStyle(by: .value("Gender", "Male"))
                        .position(by: .value("Gender", "Male"))
                        .cornerRadius(4)

                        BarMark(
                            x: .value("Event", item.eventName),
                            y: .value("Count", item.female)
                        )
                        .foregroundStyle(by: .value("Gender", "Female"))
                        .position(by: .value("Gender", "Female"))
                        .cornerRadius(4)
                    }
                }
                .chartForegroundStyleScale([
                    "Male": Color(red: 0.6, green: 1.0, blue: 0.0),
                    "Female": Color.orange
                ])
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
                .chartLegend(position: .bottom, alignment: .center) {
                    HStack(spacing: 20) {
                        legendItem(color: Color(red: 0.6, green: 1.0, blue: 0.0), label: "Male")
                        legendItem(color: .orange, label: "Female")
                    }
                }
                .frame(width: max(CGFloat(genderStats.count) * 100, 300), height: 220)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }

    func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label).font(.caption).foregroundColor(.white)
        }
    }

    // MARK: - Event Detail Stats
    func eventDetailStats(es: EventStatsData) -> some View {
        VStack(spacing: 16) {
            statCardsRow(es: es)
            soldVsRemainingChart(es: es)
            if !es.tierStats.isEmpty {
                tierBreakdownChart(es: es)
                revenuePieChart(es: es)
            }
        }
    }

    func statCardsRow(es: EventStatsData) -> some View {
        HStack(spacing: 0) {
            statBox(title: "Capacity", value: "\(es.totalCapacity)")
            Divider().background(Color.white.opacity(0.1))
            statBox(title: "Sold", value: "\(es.ticketsSold)")
            Divider().background(Color.white.opacity(0.1))
            statBox(title: "Available", value: "\(es.availableTickets)")
            Divider().background(Color.white.opacity(0.1))
            statBox(title: "Revenue", value: "SAR \(es.totalSales)")
        }
        .frame(height: 70)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }

    func soldVsRemainingChart(es: EventStatsData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tickets Sold vs Remaining")
                .font(.headline)
                .foregroundColor(.white)
            Chart {
                BarMark(x: .value("Type", "Sold"), y: .value("Count", es.ticketsSold))
                    .foregroundStyle(Color(red: 0.6, green: 1.0, blue: 0.0))
                    .cornerRadius(6)
                BarMark(x: .value("Type", "Remaining"), y: .value("Count", es.availableTickets))
                    .foregroundStyle(Color.white.opacity(0.3))
                    .cornerRadius(6)
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
            .frame(height: 200)
        }
        .padding(16)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }

    func tierBreakdownChart(es: EventStatsData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ticket Tier Breakdown")
                .font(.headline)
                .foregroundColor(.white)
            Chart {
                ForEach(es.tierStats, id: \.tier) { tier in
                    BarMark(x: .value("Tier", tier.tier), y: .value("Sold", tier.count))
                        .foregroundStyle(Color(red: 0.6, green: 1.0, blue: 0.0))
                        .cornerRadius(6)
                        .annotation(position: .top) {
                            Text("\(tier.count)").font(.caption).foregroundColor(.white)
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
            .frame(height: 180)
        }
        .padding(16)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }

    func revenuePieChart(es: EventStatsData) -> some View {
        let totalRevenue = es.tierStats.reduce(0) { $0 + $1.revenue }
        return VStack(alignment: .leading, spacing: 12) {
            Text("Revenue per Tier (SAR)")
                .font(.headline)
                .foregroundColor(.white)

            ZStack {
                Chart {
                    ForEach(es.tierStats, id: \.tier) { tier in
                        SectorMark(
                            angle: .value("Revenue", tier.revenue),
                            innerRadius: .ratio(0.5),
                            angularInset: 3
                        )
                        .foregroundStyle(by: .value("Tier", tier.tier))
                        .cornerRadius(4)
                        .opacity(selectedSlice == nil || selectedSlice == tier.tier ? 1.0 : 0.4)
                    }
                }
                .chartForegroundStyleScale(tierColorScale(tiers: es.tierStats))
                .chartLegend(.hidden)
                .frame(height: 200)

                pieCenterLabel(es: es, totalRevenue: totalRevenue)
            }

            VStack(spacing: 8) {
                ForEach(es.tierStats, id: \.tier) { tier in
                    tierLegendRow(tier: tier, totalRevenue: totalRevenue, tiers: es.tierStats)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }

    func pieCenterLabel(es: EventStatsData, totalRevenue: Int) -> some View {
        Group {
            if let slice = selectedSlice, let tier = es.tierStats.first(where: { $0.tier == slice }) {
                VStack(spacing: 4) {
                    Text(tier.tier)
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("SAR \(tier.revenue)")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                    let pct = totalRevenue > 0 ? Int(Double(tier.revenue) / Double(totalRevenue) * 100) : 0
                    Text("\(pct)%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
    }

    func tierLegendRow(tier: TierStat, totalRevenue: Int, tiers: [TierStat]) -> some View {
        let pct = totalRevenue > 0 ? Int(Double(tier.revenue) / Double(totalRevenue) * 100) : 0
        let isSelected = selectedSlice == tier.tier
        return Button(action: {
            selectedSlice = isSelected ? nil : tier.tier
        }) {
            HStack(spacing: 10) {
                Circle()
                    .fill(tierColor(tier: tier.tier, tiers: tiers))
                    .frame(width: 12, height: 12)
                Text(tier.tier)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Text("SAR \(tier.revenue)")
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

    func tierColorScale(tiers: [TierStat]) -> KeyValuePairs<String, Color> {
        if tiers.count >= 2 {
            return [tiers[0].tier: Color(red: 0.6, green: 1.0, blue: 0.0), tiers[1].tier: Color.orange]
        } else if tiers.count == 1 {
            return [tiers[0].tier: Color(red: 0.6, green: 1.0, blue: 0.0)]
        }
        return ["": Color.clear]
    }

    func tierColor(tier: String, tiers: [TierStat]) -> Color {
        if tiers.first?.tier == tier { return Color(red: 0.6, green: 1.0, blue: 0.0) }
        return Color.orange
    }

    func statBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
            Text(title).font(.caption).foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Networking
    func fetchAllEvents() {
        let url = URL(string: "http://192.168.3.10:3000/api/events/my-events")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let eventList = result["events"] as? [[String: Any]] {
                DispatchQueue.main.async {
                    allEvents = eventList
                    fetchDashboard(eventId: nil)
                    fetchAllGenderStats()
                }
            }
        }.resume()
    }

    func fetchDashboard(eventId: String?) {
        var urlString = "http://192.168.3.10:3000/api/events/dashboard"
        if let id = eventId { urlString += "?event_id=\(id)" }
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dashboard = result["dashboard"] as? [[String: Any]] {
                DispatchQueue.main.async { stats = dashboard; isLoading = false }
            }
        }.resume()
    }

    func fetchAllGenderStats() {
        genderStats = []
        for event in allEvents {
            guard let eventId = event["event_id"] as? String,
                  let eventName = event["event_name"] as? String else { continue }
            let url = URL(string: "http://192.168.3.10:3000/api/events/gender-stats/\(eventId)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else { return }
                if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let item = GenderStatItem(
                        eventName: eventName,
                        male: result["male"] as? Int ?? 0,
                        female: result["female"] as? Int ?? 0
                    )
                    DispatchQueue.main.async { genderStats.append(item) }
                }
            }.resume()
        }
    }

    func fetchSingleGenderStats(eventId: String, eventName: String) {
        let url = URL(string: "http://192.168.3.10:3000/api/events/gender-stats/\(eventId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let item = GenderStatItem(
                    eventName: eventName,
                    male: result["male"] as? Int ?? 0,
                    female: result["female"] as? Int ?? 0
                )
                DispatchQueue.main.async { genderStats = [item] }
            }
        }.resume()
    }

    func fetchEventStats(eventId: String) {
        let url = URL(string: "http://192.168.3.10:3000/api/events/stats/\(eventId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let capacityStats = result["capacity_stats"] as? [String: Any] {
                let tierStatsRaw = result["tier_stats"] as? [[String: Any]] ?? []
                let tierStats = tierStatsRaw.map { t in
                    TierStat(
                        tier: t["tier"] as? String ?? "",
                        count: t["count"] as? Int ?? 0,
                        revenue: t["revenue"] as? Int ?? 0
                    )
                }
                let parsed = EventStatsData(
                    totalCapacity: capacityStats["total_capacity"] as? Int ?? 0,
                    ticketsSold: capacityStats["tickets_sold"] as? Int ?? 0,
                    availableTickets: capacityStats["available_tickets"] as? Int ?? 0,
                    totalSales: capacityStats["total_sales"] as? Int ?? 0,
                    tierStats: tierStats
                )
                DispatchQueue.main.async { eventStats = parsed }
            }
        }.resume()
    }
}

struct EventStatsData {
    let totalCapacity: Int
    let ticketsSold: Int
    let availableTickets: Int
    let totalSales: Int
    let tierStats: [TierStat]
}

struct TierStat {
    let tier: String
    let count: Int
    let revenue: Int
}

struct GenderStatItem {
    let eventName: String
    let male: Int
    let female: Int
}

#Preview { OrganizerDashboardView() }

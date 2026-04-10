import SwiftUI

struct OrganizerDashboardView: View {
    let dummyStats = [
        ["event": "Rock Concert", "sold": "150", "revenue": "22500", "capacity": "500"],
        ["event": "Art Exhibition", "sold": "80", "revenue": "4000", "capacity": "200"],
    ]
    
    var body: some View {
        NavigationView {
            List(dummyStats, id: \.self) { stat in
                VStack(alignment: .leading, spacing: 8) {
                    Text(stat["event"] ?? "")
                        .font(.headline)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Tickets Sold")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(stat["sold"] ?? "")
                                .fontWeight(.bold)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Revenue")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("SAR \(stat["revenue"] ?? "")")
                                .fontWeight(.bold)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Capacity")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(stat["capacity"] ?? "")
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    OrganizerDashboardView()
}


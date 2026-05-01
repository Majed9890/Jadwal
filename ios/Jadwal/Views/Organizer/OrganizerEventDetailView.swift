import SwiftUI

struct OrganizerEventDetailView: View {
    let event: [String: Any]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(event["event_name"] as? String ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                
                Group {
                    detailRow(label: "Category", value: event["category"] as? String ?? "")
                    detailRow(label: "Description", value: event["description"] as? String ?? "")
                    detailRow(label: "Location", value: event["location"] as? String ?? "")
                    detailRow(label: "City", value: event["city"] as? String ?? "")
                    detailRow(label: "District", value: event["district"] as? String ?? "")
                    detailRow(label: "Road", value: event["road_name"] as? String ?? "")
                    detailRow(label: "Start Date", value: event["start_date"] as? String ?? "")
                    detailRow(label: "End Date", value: event["end_date"] as? String ?? "")
                    detailRow(label: "Time", value: event["time"] as? String ?? "")
                    detailRow(label: "Base Price", value: "SAR \(event["base_price"] as? Int ?? 0)")
                    detailRow(label: "Capacity", value: "\(event["event_capacity"] as? Int ?? 0)")
                    detailRow(label: "Available Tickets", value: "\(event["available_tickets"] as? Int ?? 0)")
                    detailRow(label: "Tickets Sold", value: "\(event["ticket_sold"] as? Int ?? 0)")
                }
                
                HStack {
                    Text("Status:")
                        .foregroundColor(.gray)
                    Spacer()
                    let status = event["event_status"] as? String ?? ""
                    Text(status.capitalized)
                        .fontWeight(.bold)
                        .foregroundColor(status == "approved" ? .green : status == "rejected" ? .red : .orange)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func detailRow(label: String, value: String) -> some View {
        HStack {
            Text("\(label):")
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    OrganizerEventDetailView(event: ["event_name": "Test Event", "category": "music", "city": "Riyadh", "event_status": "pending"])
}

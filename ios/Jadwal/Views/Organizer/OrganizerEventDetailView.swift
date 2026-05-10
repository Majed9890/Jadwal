import SwiftUI

struct OrganizerEventDetailView: View {
    let event: [String: Any]

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.08)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // Image
                    if let imageUrl = event["image_url"] as? String, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color(red: 0.15, green: 0.18, blue: 0.15)
                        }
                        .frame(width: UIScreen.main.bounds.width, height: 220)
                        .clipped()
                    }

                    VStack(spacing: 14) {

                        // Status badge
                        let status = event["event_status"] as? String ?? ""
                        HStack {
                            Text(status.capitalized)
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(statusColor(status))
                                .padding(.horizontal, 14).padding(.vertical, 6)
                                .background(statusColor(status).opacity(0.15))
                                .cornerRadius(10)
                            Spacer()
                        }

                        // Event name
                        Text(event["event_name"] as? String ?? "")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Info card
                        VStack(spacing: 12) {
                            detailRow(icon: "tag.fill", label: "Category", value: event["category"] as? String ?? "")
                            detailRow(icon: "mappin.circle.fill", label: "Location", value: event["location"] as? String ?? "")
                            detailRow(icon: "building.2.fill", label: "City", value: event["city"] as? String ?? "")
                            detailRow(icon: "map.fill", label: "District", value: event["district"] as? String ?? "")
                            detailRow(icon: "road.lanes", label: "Road", value: event["road_name"] as? String ?? "")
                            detailRow(icon: "calendar", label: "Start Date", value: event["start_date"] as? String ?? "")
                            detailRow(icon: "calendar.badge.checkmark", label: "End Date", value: event["end_date"] as? String ?? "")
                            detailRow(icon: "clock.fill", label: "Time", value: event["time"] as? String ?? "")
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)

                        // Stats card
                        HStack(spacing: 0) {
                            statBox(title: "Capacity", value: "\(event["event_capacity"] as? Int ?? 0)")
                            Divider().background(Color.white.opacity(0.1))
                            statBox(title: "Available", value: "\(event["available_tickets"] as? Int ?? 0)")
                            Divider().background(Color.white.opacity(0.1))
                            statBox(title: "Sold", value: "\(event["ticket_sold"] as? Int ?? 0)")
                        }
                        .frame(height: 70)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)

                        // Description
                        if let desc = event["description"] as? String, !desc.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.headline).foregroundColor(.white)
                                Text(desc)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                                    .lineSpacing(5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                        }

                        // Ticket types
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ticket Types")
                                .font(.headline).foregroundColor(.white)

                            if let t1name = event["ticket_type1_name"] as? String, let t1price = event["ticket_type1_price"] as? Int {
                                HStack {
                                    Text(t1name).fontWeight(.semibold).foregroundColor(.white)
                                    Spacer()
                                    Text("SAR \(t1price)").fontWeight(.bold).foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                }
                                .padding(14).background(Color.white.opacity(0.05)).cornerRadius(12)
                            }

                            if let t2name = event["ticket_type2_name"] as? String, let t2price = event["ticket_type2_price"] as? Int, !t2name.isEmpty {
                                HStack {
                                    Text(t2name).fontWeight(.semibold).foregroundColor(.white)
                                    Spacer()
                                    Text("SAR \(t2price)").fontWeight(.bold).foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                }
                                .padding(14).background(Color.white.opacity(0.05)).cornerRadius(12)
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundColor(.white.opacity(0.4))
                Text(value).font(.subheadline).fontWeight(.medium).foregroundColor(.white)
            }
            Spacer()
        }
    }

    func statBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            Text(title).font(.caption).foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    func statusColor(_ status: String) -> Color {
        switch status {
        case "approved": return Color(red: 0.6, green: 1.0, blue: 0.0)
        case "rejected": return .red
        default: return .orange
        }
    }
}

#Preview { OrganizerEventDetailView(event: ["event_name": "Test Event", "category": "Music", "city": "Riyadh", "event_status": "pending"]) }

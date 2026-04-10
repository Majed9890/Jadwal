import SwiftUI

struct MyEventsView: View {
    let dummyEvents = [
        ["name": "Rock Concert", "category": "music", "city": "Riyadh", "status": "approved"],
        ["name": "Art Exhibition", "category": "art", "city": "Jeddah", "status": "pending"],
        ["name": "Tech Conference", "category": "technology", "city": "Dammam", "status": "rejected"]
    ]
    
    var body: some View {
        NavigationView {
            List(dummyEvents, id: \.self) { event in
                VStack(alignment: .leading, spacing: 5) {
                    Text(event["name"] ?? "")
                        .font(.headline)
                    Text(event["category"] ?? "")
                        .foregroundColor(.gray)
                    HStack {
                        Text(event["city"] ?? "")
                        Spacer()
                        Text(event["status"] ?? "")
                            .font(.caption)
                            .padding(5)
                            .background(statusColor(event["status"] ?? ""))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("My Events")
        }
    }
    
    func statusColor(_ status: String) -> Color {
        switch status {
        case "approved": return .green
        case "rejected": return .red
        default: return .orange
        }
    }
}

#Preview {
    MyEventsView()
}

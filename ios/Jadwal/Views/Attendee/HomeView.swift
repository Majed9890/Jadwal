import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    
    let dummyEvents = [
        ["name": "Rock Concert", "category": "music", "city": "Riyadh", "price": "150"],
        ["name": "Art Exhibition", "category": "art", "city": "Jeddah", "price": "50"],
        ["name": "Football Match", "category": "sports", "city": "Riyadh", "price": "200"],
        ["name": "Tech Conference", "category": "technology", "city": "Dammam", "price": "300"]
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // search bar
                TextField("Search events...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                
                // event list
                List(dummyEvents, id: \.self) { event in
                    NavigationLink(destination: EventDetailsView(event: event)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(event["name"] ?? "")
                                .font(.headline)
                            Text(event["category"] ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            HStack {
                                Text(event["city"] ?? "")
                                Spacer()
                                Text("SAR \(event["price"] ?? "")")
                                    .fontWeight(.bold)
                            }
                            .font(.caption)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Jadwal")
        }
    }
}

#Preview {
    HomeView()
}


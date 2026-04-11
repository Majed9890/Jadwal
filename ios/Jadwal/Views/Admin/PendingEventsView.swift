import SwiftUI

struct PendingEventsView: View {
    let dummyEvents = [
        ["name": "Rock Concert", "category": "music", "city": "Riyadh", "price": "150"],
        ["name": "Art Exhibition", "category": "art", "city": "Jeddah", "price": "50"]
    ]
    
    var body: some View {
        NavigationView {
            List(dummyEvents, id: \.self) { event in
                VStack(alignment: .leading, spacing: 8) {
                    Text(event["name"] ?? "")
                        .font(.headline)
                    Text(event["category"] ?? "")
                        .foregroundColor(.gray)
                    HStack {
                        Text(event["city"] ?? "")
                        Spacer()
                        Text("SAR \(event["price"] ?? "")")
                            .fontWeight(.bold)
                    }
                    .font(.caption)
                    
                    HStack {
                        Button(action: {
                            // TODO: connect to API
                        }) {
                            Text("Approve")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            // TODO: connect to API
                        }) {
                            Text("Reject")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Pending Events")
                    }
                }
            }

            #Preview {
                PendingEventsView()
            }

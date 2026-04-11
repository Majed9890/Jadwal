import SwiftUI

struct PendingOrganizersView: View {
    let dummyOrganizers = [
        ["name": "Test Org", "email": "organizer@test.com", "license": "LIC123", "status": "pending"],
        ["name": "Events Co", "email": "events@test.com", "license": "LIC456", "status": "pending"]
    ]
    
    var body: some View {
        NavigationView {
            List(dummyOrganizers, id: \.self) { organizer in
                VStack(alignment: .leading, spacing: 8) {
                    Text(organizer["name"] ?? "")
                        .font(.headline)
                    Text(organizer["email"] ?? "")
                        .foregroundColor(.gray)
                    Text("License: \(organizer["license"] ?? "")")
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
            .navigationTitle("Pending Organizers")
        }
    }
}

#Preview {
    PendingOrganizersView()
}

import SwiftUI

struct UpdateInterestsView: View {
    let allInterests = ["Music", "Sports", "Art", "Technology", "Food", "Travel", "Fashion", "Gaming"]
    @State private var selectedInterests: Set<String> = []
    @State private var errorMessage = ""
    @State private var successMessage = ""

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.08)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 20)

                    VStack(spacing: 8) {
                        Text("Your Interests")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundColor(.white)
                        Text("Select at least one interest")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    // Interest grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(allInterests, id: \.self) { interest in
                            Button(action: {
                                if selectedInterests.contains(interest) {
                                    selectedInterests.remove(interest)
                                } else {
                                    selectedInterests.insert(interest)
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: iconFor(interest))
                                        .font(.system(size: 16))
                                        .foregroundColor(selectedInterests.contains(interest) ? Color(red: 0.08, green: 0.11, blue: 0.08) : Color(red: 0.6, green: 1.0, blue: 0.0))
                                    Text(interest)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(selectedInterests.contains(interest) ? Color(red: 0.08, green: 0.11, blue: 0.08) : .white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(selectedInterests.contains(interest) ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.white.opacity(0.07))
                                .cornerRadius(14)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    if !errorMessage.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                            Text(errorMessage).font(.caption).foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                    }

                    if !successMessage.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                            Text(successMessage).font(.caption).foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                    }

                    Button(action: { saveInterests() }) {
                        Text("Save Interests")
                            .font(.headline).fontWeight(.bold)
                            .foregroundColor(selectedInterests.isEmpty ? .white.opacity(0.4) : Color(red: 0.08, green: 0.11, blue: 0.08))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(selectedInterests.isEmpty ? Color.white.opacity(0.07) : Color(red: 0.6, green: 1.0, blue: 0.0))
                            .cornerRadius(16)
                    }
                    .disabled(selectedInterests.isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Interests")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { fetchInterests() }
    }

    func iconFor(_ interest: String) -> String {
        switch interest {
        case "Music": return "music.note"
        case "Sports": return "sportscourt.fill"
        case "Art": return "paintbrush.fill"
        case "Technology": return "cpu.fill"
        case "Food": return "fork.knife"
        case "Travel": return "airplane"
        case "Fashion": return "tshirt.fill"
        case "Gaming": return "gamecontroller.fill"
        default: return "star.fill"
        }
    }

    func fetchInterests() {
        let url = URL(string: "http://192.168.3.10:3000/api/attendee/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let attendee = result["attendee"] as? [String: Any],
               let interests = attendee["interests"] as? [String] {
                DispatchQueue.main.async { selectedInterests = Set(interests) }
            }
        }.resume()
    }

    func saveInterests() {
        let url = URL(string: "http://192.168.3.10:3000/api/attendee/update-interests")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = ["interests": Array(selectedInterests)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if let message = result["message"] as? String { successMessage = message; errorMessage = "" }
                    else if let err = result["error"] as? String { errorMessage = err; successMessage = "" }
                }
            }
        }.resume()
    }
}

#Preview {
    UpdateInterestsView()
}

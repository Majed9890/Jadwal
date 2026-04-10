import SwiftUI

struct UpdateInterestsView: View {
    let allInterests = ["music", "sports", "art", "technology", "food", "travel", "fashion", "gaming"]
    @State private var selectedInterests: Set<String> = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Update Interests")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Select at least one interest")
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(allInterests, id: \.self) { interest in
                    Button(action: {
                        if selectedInterests.contains(interest) {
                            selectedInterests.remove(interest)
                        } else {
                            selectedInterests.insert(interest)
                        }
                    }) {
                        Text(interest.capitalized)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedInterests.contains(interest) ? Color.blue : Color(.systemGray6))
                            .foregroundColor(selectedInterests.contains(interest) ? .white : .black)
                            .cornerRadius(10)
                    }
                }
            }
            
            Button(action: {
                // TODO: connect to API
            }) {
                Text("Save Changes")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedInterests.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(selectedInterests.isEmpty)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
#Preview {
    UpdateInterestsView()
}

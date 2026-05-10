import SwiftUI

struct MainTabView: View {
    let role: String
    @Binding var isLoggedIn: Bool

    var body: some View {
        TabView {
            if role == "attendee" {
                HomeView()
                    .tabItem { Image(systemName: "house.fill"); Text("Home") }
                MyTicketsView()
                    .tabItem { Image(systemName: "ticket.fill"); Text("My Tickets") }
                EditProfileView(isLoggedIn: $isLoggedIn)
                    .tabItem { Image(systemName: "person.fill"); Text("Profile") }

            } else if role == "organizer" {
                MyEventsView()
                    .tabItem { Image(systemName: "calendar"); Text("My Events") }
                CreateEventView()
                    .tabItem { Image(systemName: "plus.circle.fill"); Text("Create Event") }
                QRScannerView()
                    .tabItem { Image(systemName: "qrcode.viewfinder"); Text("Scan") }
                OrganizerDashboardView()
                    .tabItem { Image(systemName: "chart.bar.fill"); Text("Dashboard") }
                OrganizerMoreView(isLoggedIn: $isLoggedIn)
                    .tabItem { Image(systemName: "ellipsis.circle.fill"); Text("More") }

            } else if role == "admin" {
                PendingOrganizersView()
                    .tabItem { Image(systemName: "person.badge.clock.fill"); Text("Organizers") }
                PendingEventsView()
                    .tabItem { Image(systemName: "clock.fill"); Text("Events") }
                GlobalAnalyticsView()
                    .tabItem { Image(systemName: "chart.pie.fill"); Text("Analytics") }
            }
        }
        .accentColor(Color(red: 0.6, green: 1.0, blue: 0.0))
    }
}

struct OrganizerMoreView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    NavigationLink(destination: NotificationsView()) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "bell.fill")
                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                            }
                            Text("Notifications")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(14)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    NavigationLink(destination: OrganizerProfileView(isLoggedIn: $isLoggedIn)) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "person.fill")
                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                            }
                            Text("Profile")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(14)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Spacer()
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    MainTabView(role: "organizer", isLoggedIn: .constant(true))
}

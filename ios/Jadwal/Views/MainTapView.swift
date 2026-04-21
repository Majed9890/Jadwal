import SwiftUI

struct MainTabView: View {
    let role: String
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        TabView {
            if role == "attendee" {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                
                MyTicketsView()
                    .tabItem {
                        Image(systemName: "ticket")
                        Text("My Tickets")
                    }
                
                EditProfileView(isLoggedIn: $isLoggedIn)
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                
            } else if role == "organizer" {
                MyEventsView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("My Events")
                    }
                
                CreateEventView()
                    .tabItem {
                        Image(systemName: "plus.circle")
                        Text("Create Event")
                    }
                
                OrganizerDashboardView()
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Dashboard")
                    }
                
                NotificationsView()
                    .tabItem {
                        Image(systemName: "bell")
                        Text("Notifications")
                    }
                
            } else if role == "admin" {
                PendingOrganizersView()
                    .tabItem {
                        Image(systemName: "person.badge.clock")
                        Text("Organizers")
                                            }
                                        
                                        PendingEventsView()
                                            .tabItem {
                                                Image(systemName: "clock")
                                                Text("Events")
                                            }
                                        
                                        GlobalAnalyticsView()
                                            .tabItem {
                                                Image(systemName: "chart.pie")
                                                Text("Analytics")
                                            }
                                    }
                                }
                            }
                        }

                        #Preview {
                            MainTabView(role: "attendee", isLoggedIn: .constant(true))
                        }

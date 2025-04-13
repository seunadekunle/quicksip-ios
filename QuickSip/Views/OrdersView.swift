import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var viewModel: UserViewModel
    @State private var selectedStatus = "All"
    
    private let statusOptions = ["All", "Placed", "In Progress", "Delivered"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Status filter picker
            Picker("Status", selection: $selectedStatus) {
                ForEach(statusOptions, id: \.self) { status in
                    Text(status).tag(status)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else if viewModel.ordersWithStatus(selectedStatus).isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No orders found")
                        .font(.headline)
                    Text("Your \(selectedStatus.lowercased()) orders will appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.ordersWithStatus(selectedStatus)) { order in
                            OrderRowView(order: order)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Your Orders")
        .onAppear {
            viewModel.fetchUserOrders()
            viewModel.setupOrderUpdates() // Start listening for updates
        }
        .refreshable {
            await withCheckedContinuation { continuation in
                viewModel.fetchUserOrders {
                    continuation.resume()
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    NavigationStack {
        OrdersView()
            .environmentObject(UserViewModel())
    }
} 
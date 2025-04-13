//
//  OrderHistoryListView.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import SwiftUI

struct OrderHistoryListView: View {
    @ObservedObject var viewModel: UserViewModel
    @State private var searchText = ""
    @State private var sortOption = SortOption.dateDesc
    @State private var filterOption = FilterOption.all
    
    // Sort options
    enum SortOption: String, CaseIterable, Identifiable {
        case dateAsc = "Date (Oldest)"
        case dateDesc = "Date (Newest)"
        case priceAsc = "Price (Low to High)"
        case priceDesc = "Price (High to Low)"
        
        var id: String { self.rawValue }
    }
    
    // Filter options
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All Orders"
        case pending = "Pending"
        case preparing = "Preparing"
        case ready = "Ready"
        case delivered = "Delivered"
        case cancelled = "Cancelled"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search orders", text: $searchText)
                    .foregroundColor(.primary)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(AppColors.secondaryBackground)
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Filter and sort controls
            HStack {
                // Sort menu
                Menu {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(AppColors.secondary)
                        .foregroundColor(AppColors.primary)
                        .cornerRadius(6)
                }
                
                Spacer()
                
                // Filter menu
                Menu {
                    Picker("Filter By", selection: $filterOption) {
                        ForEach(FilterOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(AppColors.secondary)
                        .foregroundColor(AppColors.primary)
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Orders list with pull-to-refresh
            if viewModel.isLoading && viewModel.userOrders.isEmpty {
                ProgressView()
                    .padding()
            } else if filteredOrders.isEmpty {
                VStack {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.primary.opacity(0.5))
                        .padding()
                    
                    Text(viewModel.userOrders.isEmpty ? "No orders yet" : "No matching orders")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            } else {
                List {
                    ForEach(filteredOrders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            OrderRowView(order: order)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await refreshOrders()
                }
            }
        }
        .navigationTitle("Order History")
    }
    
    // Filtered and sorted orders
    private var filteredOrders: [Order] {
        var result = viewModel.userOrders
        
        // Apply filter
        if filterOption != .all {
            let filterString = filterOption.rawValue.lowercased()
            result = result.filter { $0.status.lowercased() == filterString.lowercased() }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter {
                $0.drinkType.lowercased().contains(searchText.lowercased()) ||
                $0.location.lowercased().contains(searchText.lowercased()) ||
                $0.size.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateAsc:
            result.sort { $0.timestamp < $1.timestamp }
        case .dateDesc:
            result.sort { $0.timestamp > $1.timestamp }
        case .priceAsc:
            result.sort { $0.price < $1.price }
        case .priceDesc:
            result.sort { $0.price > $1.price }
        }
        
        return result
    }
    
    // Refresh orders asynchronously
    private func refreshOrders() async {
        await withCheckedContinuation { continuation in
            viewModel.fetchUserOrders {
                continuation.resume()
            }
        }
    }
}

#Preview {
    NavigationStack {
        OrderHistoryListView(viewModel: UserViewModel())
    }
} 
//
//  ParentProfileView.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//
import SwiftUI
import SwiftData


struct ParentProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ParentProfileViewModel?
    private let maxParentNameLength = 44
    
    var body: some View {
        ZStack{
            Color(.secondarySystemBackground)
                .ignoresSafeArea()
            if let viewModel, let parent = viewModel.parent
            {
                ScrollView {
                    VStack {
                        VStack(spacing: 4) {
                            Image(parent.parentRole == .ayah ? "Father" : "Mother")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 155)
                                .offset(y: 8)
                                .frame(width: 144, height: 144)
                                .clipShape(Circle())
                            Text(String(parent.name.prefix(maxParentNameLength)))
                                .font(.largeTitle)
                                .multilineTextAlignment(.center)
                            Text(parent.parentRole == .ayah ? "Ayah" : "Ibu")
                                .font(.body)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 35)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Daftar lencana")
                                .font(.headline)
                            BadgeGridView(counts: viewModel.badgeCounts)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
                // Tidak memantul kalau isinya sudah muat di layar.
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button{
                    viewModel?.isShowingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .task {
            if viewModel == nil {
                let vm = ParentProfileViewModel(modelContext: modelContext)
                vm.createParentIfNeeded()
                viewModel = vm
            } else {
                // Lencana bisa bertambah saat layar ini tidak terlihat, jadi
                // dibaca ulang tiap kali layar muncul — bukan sekali di init.
                viewModel?.fetchBadges()
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.isShowingEditSheet ?? false },
            set: { viewModel?.isShowingEditSheet = $0 }
        )) {
            if let viewModel, let parent = viewModel.parent {
                EditParentProfileView(
                    name: parent.name,
                    role: parent.parentRole,
                    onSave: { newName, newRole in
                        viewModel.updateParent(name: newName, role: newRole)
                    },
                    onClose: {
                        // Optional: perform something when sheet closes
                    }
                )
            }
        }
    }
}
    
#Preview {
    ParentProfileView()
}

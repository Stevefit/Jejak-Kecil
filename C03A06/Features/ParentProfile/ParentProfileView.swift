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
    
    var body: some View {
        ZStack{
            Color(.secondarySystemBackground)
                .ignoresSafeArea()
            if let viewModel, let parent = viewModel.parent
            {
                VStack{
                    VStack(spacing:4){
                        Image(systemName: "face.smiling.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        Text(parent.name)
                            .font(.largeTitle)
                        Text(parent.parentRole == .ayah ? "Ayah" : "Ibu")
                            .font(.body)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 35)
                    VStack(alignment: .leading,spacing : 8){
                        Text("Daftar lencana")
                            .font(.headline)
                        BadgeGridView(counts: viewModel.badgeCounts)
                    }
                    .padding(.horizontal, 20)
                }
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

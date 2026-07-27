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
                        Image(parent.parentRole == .ayah ? "Father" : "Mother")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
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
                        BadgeGridView()
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
        .onAppear {
            if viewModel == nil {
                let vm = ParentProfileViewModel(modelContext: modelContext)
                vm.createParentIfNeeded()
                viewModel = vm
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

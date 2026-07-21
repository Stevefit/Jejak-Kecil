import SwiftUI
import SwiftData

struct CreateMomentView: View {
    // MARK: - Environments & States
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel = CreateMomentViewModel()
    
    // States untuk Image Picker
    @State private var showActionSheet = false
    @State private var showingImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: Area Upload Foto
                    PhotoUploadArea(photoData: viewModel.photoData, action: {showActionSheet = true})
                    
                    // MARK: Area Tanggal
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tanggal")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        // Membatasi tanggal agar tidak bisa memilih di masa depan
                        DatePicker("", selection: $viewModel.date, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    
                    // MARK: Area Kategori
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kategori")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Picker("Kategori", selection: $viewModel.selectedCategory) {
                            Section{
                                Text("Pilih Kategori")
                                    .tag(MomentCategory?.none) // Placeholder ketika nil
                                
                            }
                            Section{
                                ForEach(MomentCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue)
                                        .tag(MomentCategory?.some(category))
                                }
                            }
                            
                        }
                        .tint(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    
                    // MARK: Area Deskripsi
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Deskripsi")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        TextField("Apa yang terjadi di momen ini?", text: $viewModel.description)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
                .padding(24)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Tambahkan Momen")
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: TOOL BAR
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.save(context: modelContext)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!viewModel.isFormValid) // Disable jika form belum valid
                }
            }
            
            // MARK: Action Sheet & Image Picker
            .confirmationDialog("Pilih Sumber Foto", isPresented: $showActionSheet, titleVisibility: .visible) {
                Button("Kamera") {
                    imageSourceType = .camera
                    showingImagePicker = true
                }
                Button("Galeri") {
                    imageSourceType = .photoLibrary
                    showingImagePicker = true
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: imageSourceType, selectedImageData: $viewModel.photoData)
            }
        }
    }
}

#Preview {
    CreateMomentView()
}

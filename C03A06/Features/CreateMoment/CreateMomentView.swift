import SwiftUI
import SwiftData

struct CreateMomentView: View {
    // MARK: - Environments & States
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel: CreateMomentViewModel
    
    @State private var showCancelAlert = false
    
    // States untuk Image Picker
    @State private var showActionSheet = false
    @State private var showingImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    init(date: Date = .now) {
        _viewModel = State(initialValue: CreateMomentViewModel(date: date))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Area Upload Foto
                Section {
                    PhotoUploadArea(photoData: viewModel.photoData, action: {showActionSheet = true})
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // MARK: Area Tanggal & Kategori
                Section {
                    // Membatasi tanggal agar tidak bisa memilih di masa depan
                    DatePicker("Tanggal", selection: $viewModel.date, in: ...Date(), displayedComponents: .date)
                    HStack{
                        Text("Kategori")
                        
                        Spacer()
                        
                        Picker(selection: $viewModel.selectedCategory,label: EmptyView()) {
                            Section{
                                Text("None").tag(MomentCategory?.none)
                            }
                            ForEach(MomentCategory.allCases, id: \.self) { category in
                                Text(category.rawValue)
                                    .tag(MomentCategory?.some(category))
                            }
                        }
                    }
                }
                
                // MARK: Area Deskripsi
                Section {
                    TextField("Apa yang terjadi di momen ini?\n(Maksimal 54 karakter)", text: $viewModel.description, axis: .vertical)
                        .lineLimit(2...2) //dua baris max dua  untuk textfieldnya
                        .onChange(of: viewModel.description) {
                            if viewModel.description.count > CreateMomentViewModel.maxDescriptionLength {
                                viewModel.description = String(viewModel.description.prefix(CreateMomentViewModel.maxDescriptionLength))
                            }
                        }
                } header: {
                    Text("Deskripsi")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
            }
            .scrollDismissesKeyboard(.interactively) //Fix ketika ngisi deskripsi bisa close keyboard
            .navigationTitle("Tambahkan Momen")
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: TOOL BAR
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if viewModel.hasChanges {
                            showCancelAlert = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .confirmationDialog("Apakah Anda yakin ingin membatalkan momen baru ini?", isPresented: $showCancelAlert, titleVisibility: .visible) {
                        Button("Batalkan Perubahan", role: .destructive) {
                            dismiss()
                        }
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
            
            // MARK: Action Sheet  Image Picker
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
        }.interactiveDismissDisabled(viewModel.hasChanges) //fix: ketika ada perubahan tidak bisa di swipe untuk dissmiss modal (harus di navstacknya)
    }
}

#Preview {
    CreateMomentView()
}

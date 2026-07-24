import SwiftUI
import SwiftData

struct EditMomentView: View {
    @Bindable var moment: Moment
    @Binding var isPresented: Bool
    var viewModel: ReviewMomentViewModel

    @State private var descriptionInput: String = ""
    @State private var dateInput: Date = Date()
    @State private var categoryInput: MomentCategory? = nil
    @State private var photoDataInput: Data? = nil
    
    @State private var showCancelAlert = false
    @State private var showActionSheet = false
    @State private var showingImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary

    private var isFormValid: Bool {
        let isDescriptionValid = !descriptionInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isPhotoValid = photoDataInput != nil
        let isCategoryValid = categoryInput != nil
        return isDescriptionValid && isPhotoValid && isCategoryValid
    }

    private var hasChanges: Bool {
        descriptionInput != moment.shortDescription ||
        dateInput != moment.timestamp ||
        categoryInput != moment.category ||
        photoDataInput != moment.photo
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotoUploadArea(photoData: photoDataInput, action: { showActionSheet = true })
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                Section {
                    DatePicker("Tanggal", selection: $dateInput, in: ...Date(), displayedComponents: .date)
                    
                    HStack {
                        Text("Kategori")
                        Spacer()
                        Picker(selection: $categoryInput, label: EmptyView()) {
                            Section {
                                Text("None").tag(MomentCategory?.none)
                            }
                            ForEach(MomentCategory.allCases, id: \.self) { category in
                                Text(category.rawValue)
                                    .tag(MomentCategory?.some(category))
                            }
                        }
                    }
                }
                
                Section {
                    TextField("Apa yang terjadi di momen ini?\n(Maksimal 54 karakter)", text: $descriptionInput, axis: .vertical)
                        .lineLimit(2...2)
                        .onChange(of: descriptionInput) {
                            if descriptionInput.count > CreateMomentViewModel.maxDescriptionLength {
                                descriptionInput = String(descriptionInput.prefix(CreateMomentViewModel.maxDescriptionLength))
                            }
                        }
                } header: {
                    Text("Deskripsi")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                }
            }
            .navigationTitle("Ubah Momen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if hasChanges {
                            showCancelAlert = true
                        } else {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .confirmationDialog("Apakah Anda yakin ingin membatalkan perubahan?", isPresented: $showCancelAlert, titleVisibility: .visible) {
                        Button("Batalkan Perubahan", role: .destructive) {
                            isPresented = false
                        }
                        Button("Kembali", role: .cancel) { }
                    }
                    .interactiveDismissDisabled(hasChanges)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if let category = categoryInput {
                            moment.category = category
                        }
                        viewModel.updateMoment(
                            moment,
                            withDescription: descriptionInput,
                            date: dateInput,
                            photoData: photoDataInput
                        )
                        isPresented = false
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!isFormValid)
                }
            }
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
                ImagePicker(sourceType: imageSourceType, selectedImageData: $photoDataInput)
            }
            .onAppear {
                descriptionInput = moment.shortDescription
                dateInput = moment.timestamp
                categoryInput = moment.category
                photoDataInput = moment.photo
            }
        }
    }
}

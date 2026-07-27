import SwiftUI
import SwiftData

struct EditMomentView: View {
    @Bindable var moment: Moment
    @Binding var isPresented: Bool
    var viewModel: ReviewMomentViewModel
    var onDelete: (() -> Void)? = nil

    @State private var descriptionInput: String = ""
    @State private var dateInput: Date = Date()
    @State private var categoryInput: MomentCategory? = nil
    
    @State private var photoDataInput: Data? = nil
    @State private var rawPhotoData: Data? = nil
    
    @State private var showCancelAlert = false
    @State private var showDeleteAlert = false
    @State private var showActionSheet = false
    @State private var showingImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary

    @State private var tempPickedImageData: Data? = nil
    @State private var showingCropper = false

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
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(
                    title: "Simpan Perubahan",
                    isEnabled: isFormValid && hasChanges,
                    action: {
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
                    }
                )
                .padding(.bottom, 12)
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
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.red)
                    .confirmationDialog("Apakah Anda yakin ingin menghapus momen ini?", isPresented: $showDeleteAlert, titleVisibility: .visible) {
                        Button("Hapus Momen", role: .destructive) {
                            viewModel.deleteMoment(moment)
                            isPresented = false
                            onDelete?()
                        }
                        Button("Batal", role: .cancel) { }
                    }
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
                if rawPhotoData != nil || photoDataInput != nil {
                    Button("Atur Ulang Bingkai Foto (3:4)") {
                        tempPickedImageData = rawPhotoData ?? photoDataInput
                        showingCropper = true
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: {
                if tempPickedImageData != nil {
                    rawPhotoData = tempPickedImageData
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(250))
                        showingCropper = true
                    }
                }
            }) {
                ImagePicker(sourceType: imageSourceType, selectedImageData: $tempPickedImageData)
            }
            .sheet(isPresented: $showingCropper) {
                if let rawData = tempPickedImageData, let uiImage = UIImage(data: rawData) {
                    ImageCropperView(
                        inputImage: uiImage,
                        onCrop: { croppedData in
                            self.photoDataInput = croppedData
                            self.tempPickedImageData = nil
                            self.showingCropper = false
                        },
                        onCancel: {
                            self.tempPickedImageData = nil
                            self.showingCropper = false
                        }
                    )
                }
            }
            .onAppear {
                descriptionInput = moment.shortDescription
                dateInput = moment.timestamp
                categoryInput = moment.category
                photoDataInput = moment.photo
                rawPhotoData = moment.photo
            }
        }
    }
}

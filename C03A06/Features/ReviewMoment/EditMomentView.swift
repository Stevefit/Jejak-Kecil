import SwiftUI
import SwiftData

struct EditMomentView: View {
    var moment: Moment
    @Binding var isPresented: Bool
    var viewModel: ReviewMomentViewModel

    @State private var descriptionInput: String
    @State private var dateInput: Date
    @State private var photoDataInput: Data?
    
    @State private var showActionSheet = false
    @State private var showingImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary

    init(moment: Moment, isPresented: Binding<Bool>, viewModel: ReviewMomentViewModel) {
        self.moment = moment
        self._isPresented = isPresented
        self.viewModel = viewModel
        self._descriptionInput = State(initialValue: moment.shortDescription)
        self._dateInput = State(initialValue: moment.timestamp)
        self._photoDataInput = State(initialValue: moment.photo)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Group {
                        if let data = photoDataInput, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(height: 240)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .onTapGesture {
                        showActionSheet = true
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tanggal")
                                .font(.headline)
                            
                            DatePicker("", selection: $dateInput, displayedComponents: [.date])
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(24)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deskripsi")
                                .font(.headline)
                            TextField("", text: $descriptionInput)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(24)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle("Ubah Momen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        viewModel.updateMoment(
                            moment,
                            withDescription: descriptionInput,
                            date: dateInput,
                            photoData: photoDataInput
                        )
                        isPresented = false
                    }) {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
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
        }
    }
}

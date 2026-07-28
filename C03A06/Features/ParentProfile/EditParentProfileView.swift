import SwiftUI

struct EditParentProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var role: ParentRole
    @State private var showDiscardConfirmation = false

    private let maxNameLength = 44
    private let originalName: String
    private let originalRole: ParentRole
    let onSave: (String, ParentRole) -> Void
    let onClose: () -> Void

    init(
        name: String,
        role: ParentRole,
        onSave: @escaping (String, ParentRole) -> Void,
        onClose: @escaping () -> Void
    ) {
        _name = State(initialValue: name)
        _role = State(initialValue: role)
        self.originalName = name
        self.originalRole = role
        self.onSave = onSave
        self.onClose = onClose
    }

    private var hasChanges: Bool {
        name != originalName || role != originalRole
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isNameEmpty: Bool {
        trimmedName.isEmpty
    }

    private var isNameTooLong: Bool {
        name.count > maxNameLength
    }

    private var isSaveDisabled: Bool {
        isNameEmpty || isNameTooLong
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Nama")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TextField("Masukkan nama", text: $name)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    if isNameTooLong {
                        Text("Nama maksimal \(maxNameLength) karakter.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Role")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Menu {
                        Button("Ayah") { role = .ayah }
                        Button("Ibu") { role = .ibu }
                    } label: {
                        HStack {
                            Text(role == .ayah ? "Ayah" : "Ibu")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        close()
                    } label: {
                        Label("Tutup", systemImage: "xmark")
                    }
                    .labelStyle(.iconOnly)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave(trimmedName, role)
                        dismiss()
                    } label: {
                        Label("Simpan", systemImage: "checkmark")
                    }
                    .labelStyle(.iconOnly)
                    .disabled(isSaveDisabled)
                }
            }
        }
        .confirmationDialog(
            "Buang perubahan?",
            isPresented: $showDiscardConfirmation,
            titleVisibility: .visible
        ) {
            Button("Buang Perubahan", role: .destructive) {
                dismiss()
            }
            Button("Lanjut Edit", role: .cancel) {}
        } message: {
            Text("Perubahan yang kamu buat belum disimpan.")
        }
        .interactiveDismissDisabled(hasChanges)
    }

    private func close() {
        onClose()
        if hasChanges {
            showDiscardConfirmation = true
        } else {
            dismiss()
        }
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            EditParentProfileView(
                name: "Budi Santoso",
                role: .ayah,
                onSave: { _, _ in },
                onClose: {}
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
        }
}

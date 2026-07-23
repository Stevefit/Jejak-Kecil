import SwiftUI

struct EditParentProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var role: ParentRole
    @State private var showDiscardConfirmation = false

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

    private var isNameEmpty: Bool {
        name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    if hasChanges {
                        showDiscardConfirmation = true
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 32, height: 32)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Circle())
                }

                Spacer()

                Text("Edit Profile")
                    .font(.headline)

                Spacer()

                Button {
                    onSave(name, role)
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(isNameEmpty ? Color.blue.opacity(0.4) : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(isNameEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)

            // Fields
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
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color(.secondarySystemBackground))
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
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            EditParentProfileView(
                name: "Budi Santoso",
                role: .ayah,
                onSave: { _, _ in },
                onClose: {}
            )                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
}

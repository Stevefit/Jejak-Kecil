//
//  ImageCropperView.swift
//  C03A06
//

import SwiftUI
import UIKit

struct ImageCropperView: View {
    let inputImage: UIImage
    let onCrop: (Data) -> Void
    let onCancel: () -> Void

    // Gesture States
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    // Container geometry
    @State private var currentContainerSize: CGSize = CGSize(width: 300, height: 400)

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // MARK: Crop Frame (3:4 Ratio)
                GeometryReader { geo in
                    let cropWidth = geo.size.width - 32
                    let cropHeight = cropWidth * (4.0 / 3.0)
                    let containerSize = CGSize(width: cropWidth, height: cropHeight)

                    ZStack {
                        Color.black.ignoresSafeArea()

                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                SimultaneousGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let rawOffset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                            offset = clampOffset(rawOffset, scale: scale, containerSize: containerSize)
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        },
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            let newScale = max(1.0, scale * delta)
                                            scale = newScale
                                            offset = clampOffset(offset, scale: newScale, containerSize: containerSize)
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                            lastOffset = offset
                                        }
                                )
                            )

                        // 3:4 Frame Border
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 2)
                            .shadow(color: .black.opacity(0.5), radius: 4)
                            .allowsHitTesting(false)
                    }
                    .frame(width: cropWidth, height: cropHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .onChange(of: geo.size) { _, _ in
                        currentContainerSize = containerSize
                    }
                    .onAppear {
                        currentContainerSize = containerSize
                    }
                }
                .aspectRatio(3/4, contentMode: .fit)
                .padding(.horizontal, 16)

                Text("Seret dan jepit foto untuk menyesuaikan bagian 3:4")
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.top, 8)
            .background(Color(.systemBackground))
            .navigationTitle("Atur Foto (3:4)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onCancel()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if let croppedData = renderCroppedImage(containerSize: currentContainerSize) {
                            onCrop(croppedData)
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                }
            }
        }
    }

    // MARK: - Clamping Logic
    private func clampOffset(_ targetOffset: CGSize, scale: CGFloat, containerSize: CGSize) -> CGSize {
        guard containerSize.width > 0, containerSize.height > 0 else { return targetOffset }

        let imageAspect = inputImage.size.width / inputImage.size.height
        let cropAspect = containerSize.width / containerSize.height

        var baseWidth: CGFloat
        var baseHeight: CGFloat

        if imageAspect > cropAspect {
            baseHeight = containerSize.height
            baseWidth = baseHeight * imageAspect
        } else {
            baseWidth = containerSize.width
            baseHeight = baseWidth / imageAspect
        }

        let currentWidth = baseWidth * scale
        let currentHeight = baseHeight * scale

        let maxX = max(0, (currentWidth - containerSize.width) / 2.0)
        let maxY = max(0, (currentHeight - containerSize.height) / 2.0)

        let clampedX = min(max(targetOffset.width, -maxX), maxX)
        let clampedY = min(max(targetOffset.height, -maxY), maxY)

        return CGSize(width: clampedX, height: clampedY)
    }

    // MARK: - Crop Renderer
    private func renderCroppedImage(containerSize: CGSize) -> Data? {
        let validContainer = containerSize.width > 0 ? containerSize : CGSize(width: 300, height: 400)
        let targetSize = CGSize(width: 900, height: 1200)

        // Fix potential orientation issues on UIImages
        let normalizedImage = fixOrientation(inputImage)

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        let imageAspect = normalizedImage.size.width / normalizedImage.size.height
        let cropAspect: CGFloat = 3.0 / 4.0

        var baseDrawWidth: CGFloat
        var baseDrawHeight: CGFloat

        if imageAspect > cropAspect {
            baseDrawHeight = targetSize.height
            baseDrawWidth = baseDrawHeight * imageAspect
        } else {
            baseDrawWidth = targetSize.width
            baseDrawHeight = baseDrawWidth / imageAspect
        }

        let scaledDrawWidth = baseDrawWidth * scale
        let scaledDrawHeight = baseDrawHeight * scale

        let factor = targetSize.width / validContainer.width
        let drawX = (targetSize.width - scaledDrawWidth) / 2.0 + (offset.width * factor)
        let drawY = (targetSize.height - scaledDrawHeight) / 2.0 + (offset.height * factor)

        let drawRect = CGRect(x: drawX, y: drawY, width: scaledDrawWidth, height: scaledDrawHeight)

        let croppedImage = renderer.image { _ in
            normalizedImage.draw(in: drawRect)
        }

        return croppedImage.jpegData(compressionQuality: 0.85)
    }

    private func fixOrientation(_ img: UIImage) -> UIImage {
        if img.imageOrientation == .up { return img }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        img.draw(in: CGRect(origin: .zero, size: img.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? img
    }
}

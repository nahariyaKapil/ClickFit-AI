import SwiftUI
import PhotosUI
@preconcurrency import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @EnvironmentObject var dataController: DataController
    @State private var showingAnalysis = false
    @State private var selectedImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showingPermissionAlert = false
    @State private var isCameraActive = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Modern Gradient Background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.05, green: 0.05, blue: 0.1),
                            Color.black
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("ClickFit AI")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 28))
                                .foregroundColor(.cyan)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                        
                        // Camera Preview or Selected Image
                        if let image = selectedImage {
                            // Selected Image View
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.1),
                                                Color.white.opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: geometry.size.height * 0.55)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: geometry.size.height * 0.5)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                // Clear button
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: clearSelectedImage) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.black.opacity(0.7))
                                                    .frame(width: 40, height: 40)
                                                
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding()
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 20)
                        } else if isCameraActive && viewModel.isAuthorized {
                            // Live Camera Preview
                            ZStack {
                                if viewModel.isSessionReady {
                                    CameraPreviewView(session: viewModel.session)
                                        .frame(height: geometry.size.height * 0.55)
                                        .cornerRadius(25)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
                                        )
                                        .shadow(color: .cyan.opacity(0.3), radius: 10, x: 0, y: 5)
                                    
                                    // Camera overlay
                                    CameraOverlay()
                                } else {
                                    // Loading state while camera is initializing
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.black)
                                        .frame(height: geometry.size.height * 0.55)
                                        .overlay(
                                            VStack(spacing: 20) {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                    .scaleEffect(1.5)
                                                
                                                Text("Initializing Camera...")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                        )
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            // Camera Ready / Permission Required View
                            ModernCameraPlaceholder(isAuthorized: viewModel.isAuthorized)
                                .frame(height: geometry.size.height * 0.55)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                        
                        // Modern Action Buttons
                        HStack(spacing: 50) {
                            // Gallery Button
                            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                                ModernActionButton(
                                    icon: "photo.stack",
                                    label: "Gallery",
                                    isActive: false
                                )
                            }
                            .onChange(of: photosPickerItem) { _, newValue in
                                Task {
                                    closeCameraSession()
                                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        selectedImage = image
                                    }
                                }
                            }
                            
                            // Camera Capture Button
                            Button(action: handleCameraButtonPress) {
                                ZStack {
                                    // Outer ring with gradient
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    isCameraActive ? Color.red : Color.cyan,
                                                    isCameraActive ? Color.orange : Color.blue
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 4
                                        )
                                        .frame(width: 85, height: 85)
                                    
                                    // Inner circle
                                    Circle()
                                        .fill(isCameraActive ? Color.red : Color.white)
                                        .frame(width: 70, height: 70)
                                        .shadow(color: isCameraActive ? .red.opacity(0.5) : .white.opacity(0.3), 
                                               radius: 10, x: 0, y: 5)
                                    
                                    if viewModel.isCapturing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: isCameraActive ? .white : .black))
                                            .scaleEffect(1.5)
                                    } else {
                                        Image(systemName: isCameraActive ? "stop.fill" : "camera.fill")
                                            .font(.system(size: 28, weight: .medium))
                                            .foregroundColor(isCameraActive ? .white : .black)
                                    }
                                }
                            }
                            .disabled(viewModel.isCapturing || (isCameraActive && !viewModel.isSessionReady))
                            .scaleEffect(viewModel.isCapturing ? 0.95 : 1.0)
                            .animation(.spring(response: 0.3), value: viewModel.isCapturing)
                            
                            // Analyze Button
                            Button(action: {
                                closeCameraSession()
                                if selectedImage != nil {
                                    showingAnalysis = true
                                }
                            }) {
                                ModernActionButton(
                                    icon: "sparkles",
                                    label: "Analyze",
                                    isActive: selectedImage != nil
                                )
                            }
                            .disabled(selectedImage == nil)
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Camera Permission Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable camera access in Settings to take photos of your meals.")
            }
            .sheet(isPresented: $showingAnalysis) {
                if let image = selectedImage {
                    AnalysisView(image: image, onSave: { analysis in
                        dataController.save(analysis)
                        clearSelectedImage()
                        showingAnalysis = false
                    })
                }
            }
            .onDisappear {
                closeCameraSession()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func handleCameraButtonPress() {
        if viewModel.isAuthorized {
            if isCameraActive {
                if viewModel.isSessionReady && viewModel.isSessionRunning {
                    viewModel.capturePhoto { image in
                        if let capturedImage = image {
                            selectedImage = capturedImage
                            closeCameraSession()
                        }
                    }
                }
            } else {
                clearSelectedImage()
                isCameraActive = true
                viewModel.startSession()
            }
        } else {
            showingPermissionAlert = true
        }
    }
    
    private func closeCameraSession() {
        isCameraActive = false
        viewModel.stopSession()
    }
    
    private func clearSelectedImage() {
        selectedImage = nil
        photosPickerItem = nil
    }
}

// MARK: - Modern Camera Placeholder
struct ModernCameraPlaceholder: View {
    let isAuthorized: Bool
    @State private var animate = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.05),
                        Color.white.opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(
                VStack(spacing: 25) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 100, height: 100)
                            .scaleEffect(animate ? 1.1 : 0.9)
                            .opacity(animate ? 0.3 : 0.5)
                        
                        Image(systemName: isAuthorized ? "camera.fill" : "camera.badge.ellipsis")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    VStack(spacing: 10) {
                        Text(isAuthorized ? "Camera Ready" : "Camera Access Required")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(isAuthorized ? "Press the camera button to start" : "Please enable camera access in Settings")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    
                    if !isAuthorized {
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Open Settings")
                            }
                            .padding(.horizontal, 25)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                    }
                }
                .padding()
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
    }
}

// MARK: - Modern Action Button
struct ModernActionButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(isActive ? 0.15 : 0.05),
                                Color.white.opacity(isActive ? 0.1 : 0.02)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(isActive ? 0.3 : 0.1), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isActive ? .white : .white.opacity(0.5))
            }
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isActive ? .white : .white.opacity(0.5))
        }
    }
}

// MARK: - Camera Overlay
struct CameraOverlay: View {
    @State private var animateCorners = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Corner brackets
                ForEach(0..<4) { index in
                    CameraBracket()
                        .stroke(Color.cyan, lineWidth: 3)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(Double(index) * 90))
                        .position(cornerPosition(for: index, in: geometry.size))
                        .opacity(animateCorners ? 1 : 0.3)
                        .scaleEffect(animateCorners ? 1 : 0.8)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animateCorners = true
            }
        }
    }
    
    func cornerPosition(for index: Int, in size: CGSize) -> CGPoint {
        let padding: CGFloat = 30
        switch index {
        case 0: return CGPoint(x: padding, y: padding)
        case 1: return CGPoint(x: size.width - padding, y: padding)
        case 2: return CGPoint(x: size.width - padding, y: size.height - padding)
        case 3: return CGPoint(x: padding, y: size.height - padding)
        default: return .zero
        }
    }
}

struct CameraBracket: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length: CGFloat = 20
        
        // Top left corner
        path.move(to: CGPoint(x: 0, y: length))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: length, y: 0))
        
        return path
    }
}

// MARK: - Camera Preview View - Fixed
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.videoPreviewLayer.connection?.videoRotationAngle = 90
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        // Update orientation if needed
        DispatchQueue.main.async {
            uiView.videoPreviewLayer.connection?.videoRotationAngle = 90
        }
    }
}

// MARK: - Camera ViewModel (Improved)
@MainActor
class CameraViewModel: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isCapturing = false
    @Published var isSessionReady = false
    @Published var isSessionRunning = false
    
    nonisolated let session = AVCaptureSession()
    private nonisolated let photoOutput = AVCapturePhotoOutput()
    private var photoCompletionHandler: ((UIImage?) -> Void)?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    override init() {
        super.init()
        checkCameraAuthorization()
    }
    
    func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }
    
    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            // Add video input
            do {
                guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    print("Failed to get camera device")
                    self.session.commitConfiguration()
                    return
                }
                
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                } else {
                    print("Couldn't add video input")
                    self.session.commitConfiguration()
                    return
                }
            } catch {
                print("Couldn't create video input: \(error)")
                self.session.commitConfiguration()
                return
            }
            
            // Add photo output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)
            } else {
                print("Couldn't add photo output")
                self.session.commitConfiguration()
                return
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.isSessionReady = true
            }
        }
    }
    
    func startSession() {
        guard isAuthorized && isSessionReady else { return }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if !self.session.isRunning {
                self.session.startRunning()
                
                DispatchQueue.main.async {
                    self.isSessionRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.session.isRunning {
                self.session.stopRunning()
                
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                }
            }
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard !isCapturing && isAuthorized && isSessionReady && isSessionRunning else {
            completion(nil)
            return
        }
        
        isCapturing = true
        photoCompletionHandler = completion
        
        sessionQueue.async { [weak self] in
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .auto
            self?.photoOutput.capturePhoto(with: settings, delegate: self!)
        }
    }
}

// MARK: - Photo Capture Delegate
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, 
                                didFinishProcessingPhoto photo: AVCapturePhoto, 
                                error: Error?) {
        Task { @MainActor in
            defer { isCapturing = false }
            
            guard error == nil,
                  let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else {
                photoCompletionHandler?(nil)
                return
            }
            
            let fixedImage = image.fixedOrientation()
            photoCompletionHandler?(fixedImage)
        }
    }
}

// MARK: - UIImage Extension for Orientation Fix
extension UIImage {
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
}
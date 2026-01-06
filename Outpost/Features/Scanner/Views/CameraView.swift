//
//  CameraView.swift
//  Outpost
//
//  Created by Leonardo Solís on 28/12/25.
//


import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    var onCodeScanned: (String) -> Void
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        if !uiView.isScanning {
            uiView.startScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // MARK: Coordinator
    class Coordinator: NSObject, CameraPreviewDelegate {
        var parent: CameraView
        var hasScanned = false
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func didFoundCode(_ code: String) {
            guard !hasScanned else { return }
            hasScanned = true
            
            // Haptic Feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            parent.onCodeScanned(code)
            
            // Reset lock after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.hasScanned = false
            }
        }
    }
}

protocol CameraPreviewDelegate: AnyObject {
    func didFoundCode(_ code: String)
}

// MARK: UIKit
class CameraPreviewView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    weak var delegate: CameraPreviewDelegate?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var isScanning = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCamera()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = self.bounds
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean13, .code128]
        }
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(layer)
        
        self.previewLayer = layer
        self.captureSession = session
        
        startScanning()
    }
    
    func startScanning() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
            DispatchQueue.main.async { self.isScanning = true }
        }
    }
    
    func stopScanning() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.stopRunning()
            DispatchQueue.main.async { self.isScanning = false }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            delegate?.didFoundCode(stringValue)
        }
    }
}

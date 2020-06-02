//
//  MetalImageView.swift
//  crowd protect
//
//  Source: https://maysamsh.me/2018/12/16/ios-image-filters-using-coreimage-and-metalkitview/

import UIKit
import MetalKit
import AVFoundation

class MetalImageView: MTKView {

    private var commanQueue: MTLCommandQueue?
    private var ciContext: CIContext?
    var mtlTexture: MTLTexture?

    init(frame: CGRect) {
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        self.isOpaque = false
        self.enableSetNeedsDisplay = true
        self.framebufferOnly = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image : UIImage) {
        if let device = device,
            let ciImage = CIImage(image: image) {
            let context = CIContext(mtlDevice: device)
            render(image: ciImage, context: context, device: device)
            setNeedsDisplay()
        }
    }

    func render(image: CIImage, context: CIContext, device: MTLDevice) {
        #if !targetEnvironment(simulator)
        self.ciContext = context
        self.device = device

        var size = self.bounds
        size.size = self.drawableSize
        size = AVMakeRect(aspectRatio: image.extent.size, insideRect: size)
        let filteredImage = image.transformed(by: CGAffineTransform(
            scaleX: size.size.width/image.extent.size.width,
            y: size.size.height/image.extent.size.height))
        let x = -size.origin.x
        let y = -size.origin.y

        self.commanQueue = device.makeCommandQueue()

        let buffer = self.commanQueue!.makeCommandBuffer()!
        self.mtlTexture = self.currentDrawable!.texture
        self.ciContext!.render(filteredImage,
                               to: self.currentDrawable!.texture,
                               commandBuffer: buffer,
                               bounds: CGRect(origin:CGPoint(x:x, y:y), size:self.drawableSize),
                               colorSpace: CGColorSpaceCreateDeviceRGB())
        buffer.present(self.currentDrawable!)
        buffer.commit()
        #endif
    }

    func getUIImage(texture: MTLTexture, context: CIContext) -> UIImage?{
        let kciOptions = [CIImageOption.colorSpace: CGColorSpaceCreateDeviceRGB(),
                          CIContextOption.outputPremultiplied: true,
                          CIContextOption.useSoftwareRenderer: false] as! [CIImageOption : Any]

        if let ciImageFromTexture = CIImage(mtlTexture: texture, options: kciOptions) {
            if let cgImage = context.createCGImage(ciImageFromTexture, from: ciImageFromTexture.extent) {
                let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .downMirrored)
                return uiImage
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

}

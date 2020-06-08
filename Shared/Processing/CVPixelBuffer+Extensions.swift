import UIKit
import AVFoundation
import CoreGraphics
import CoreImage.CIFilterBuiltins
import Vision

extension CGColorSpace {
    static var deviceGray: CGColorSpace {
        CGColorSpaceCreateDeviceGray()
    }
    
    static var deviceRGB: CGColorSpace {
        CGColorSpaceCreateDeviceRGB()
    }
}

extension CGBitmapInfo {
    func with(alphaInfo: CGImageAlphaInfo) -> CGBitmapInfo {
        return CGBitmapInfo(rawValue: rawValue | alphaInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue)
    }
}

extension CVPixelBuffer {
    struct IntegralSize {
        var width: Int
        var height: Int
    }
    
    struct Format {
        var bitsPerComponent: Int
        var bitmapInfo: CGBitmapInfo
        var colorSpace: CGColorSpace
        
        init(bitsPerComponent: Int, bitmapInfo: CGBitmapInfo, alphaInfo: CGImageAlphaInfo, colorSpace: CGColorSpace) {
            self.init(bitsPerComponent: bitsPerComponent, bitmapInfo: bitmapInfo.with(alphaInfo: alphaInfo), colorSpace: colorSpace)
        }
        
        init(bitsPerComponent: Int, bitmapInfo: CGBitmapInfo, colorSpace: CGColorSpace) {
            self.bitsPerComponent = bitsPerComponent
            self.bitmapInfo = bitmapInfo
            self.colorSpace = colorSpace
        }
        
        static var mask: Format {
            Format(bitsPerComponent: 8, bitmapInfo: CGBitmapInfo(rawValue: 0), colorSpace: .deviceGray)
        }
    }
    
    var baseAddress: UnsafeMutableRawPointer? {
        CVPixelBufferGetBaseAddress(self)
    }
    
    var size: IntegralSize {
        IntegralSize(width: CVPixelBufferGetWidth(self), height: CVPixelBufferGetHeight(self))
    }
    
    var bytesPerRow: Int {
        CVPixelBufferGetBytesPerRow(self)
    }
    
    var format: Format? {
        switch CVPixelBufferGetPixelFormatType(self) {
        case kCVPixelFormatType_32ARGB:
            return Format(bitsPerComponent: 8, bitmapInfo: .byteOrder32Little, alphaInfo: .premultipliedFirst, colorSpace: .deviceRGB)
        default:
            return nil
        }
    }
}

extension CGSize {
    init(integralSize: CVPixelBuffer.IntegralSize) {
        self.init(width: integralSize.width, height: integralSize.height)
    }
}

extension CGContext {
    static func context(buffer: CVPixelBuffer) -> CGContext? {
        guard let format = buffer.format else { return nil }
        return self.context(data: buffer.baseAddress, size: buffer.size, bytesPerRow: buffer.bytesPerRow, format: format)
    }
    
    static func context(data: UnsafeMutableRawPointer?, size: CVPixelBuffer.IntegralSize, bytesPerRow: Int, format: CVPixelBuffer.Format) -> CGContext? {
        Self(data: data, width: size.width, height: size.height, bitsPerComponent: format.bitsPerComponent, bytesPerRow: bytesPerRow, space: format.colorSpace, bitmapInfo: format.bitmapInfo.rawValue)
    }
}

extension CVPixelBuffer {
    enum ConversionError: Error {
        case incompatibleWithContext
    }
    
    func draw(with block: (CGContext) throws -> Void) throws {
        CVPixelBufferLockBaseAddress(self, [])
        defer {
            CVPixelBufferUnlockBaseAddress(self, [])
        }
        
        guard let context = CGContext.context(buffer: self) else {
            throw ConversionError.incompatibleWithContext
        }
        
        try block(context)
    }
}

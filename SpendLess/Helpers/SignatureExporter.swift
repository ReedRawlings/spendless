//
//  SignatureExporter.swift
//  SpendLess
//
//  Helper for exporting PencilKit signatures as PNG images
//

import PencilKit
import UIKit

func exportSignature(from canvas: PKCanvasView, scale: CGFloat = 2.0) -> Data? {
    let drawing = canvas.drawing
    
    // If no strokes, return nil
    guard !drawing.strokes.isEmpty else {
        return nil
    }
    
    // Get the bounds of the drawing
    let bounds = drawing.bounds
    
    // Add padding around the signature
    let padding: CGFloat = 20
    let paddedBounds = CGRect(
        x: bounds.origin.x - padding,
        y: bounds.origin.y - padding,
        width: bounds.width + (padding * 2),
        height: bounds.height + (padding * 2)
    )
    
    // Create image at 2x scale
    let imageSize = CGSize(
        width: paddedBounds.width * scale,
        height: paddedBounds.height * scale
    )
    
    // Create image renderer
    let renderer = UIGraphicsImageRenderer(size: imageSize)
    
    let image = renderer.image { context in
        // Fill with transparent background
        context.cgContext.clear(CGRect(origin: .zero, size: imageSize))
        
        // Scale the context to match the drawing
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        context.cgContext.concatenate(scaleTransform)
        
        // Translate to account for padding
        let translateTransform = CGAffineTransform(
            translationX: -paddedBounds.origin.x,
            y: -paddedBounds.origin.y
        )
        context.cgContext.concatenate(translateTransform)
        
        // Draw the signature
        drawing.image(from: bounds, scale: scale)
    }
    
    // Convert to PNG data
    return image.pngData()
}


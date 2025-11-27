//
//  DesignSystemFonts.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 27/11/25.
//

import Foundation

import SwiftUI

extension Font {
    
    // MARK: - SF Pro (System Fonts)
    // Mapeando exatamente a imagem que você mandou:
    
    /// SF Pro | Light | 34px
    static let appLargeTitle = Font.system(size: 34, weight: .light)
    
    /// SF Pro | Light | 28px
    static let appTitle1 = Font.system(size: 28, weight: .light)
    
    /// SF Pro | Light | 22px
    static let appTitle2 = Font.system(size: 22, weight: .light)
    
    /// SF Pro | Light | 20px
    static let appTitle3 = Font.system(size: 20, weight: .light)
    
    /// SF Pro | Medium | 17px
    static let appHeadline = Font.system(size: 17, weight: .medium)
    
    /// SF Pro | Light | 17px
    static let appBody = Font.system(size: 17, weight: .light)
    
    /// SF Pro | Light | 16px
    static let appCallout = Font.system(size: 16, weight: .light)
    
    /// SF Pro | Light | 15px
    static let appSubheadline = Font.system(size: 15, weight: .light)
    
    /// SF Pro | Light | 13px
    static let appFootnote = Font.system(size: 13, weight: .light)
    
    /// SF Pro | Light | 12px
    static let appCaption1 = Font.system(size: 12, weight: .light)
    
    /// SF Pro | Light | 11px
    static let appCaption2 = Font.system(size: 11, weight: .light)
    
    
    // MARK: - Covered By Your Grace (Custom Fonts)
    
    /// Covered By Your Grace | Regular | 32px
    static let handwrittenTitle = Font.custom("Covered By Your Grace", size: 32)
    
    /// Covered By Your Grace | Regular | 22px
    static let handwrittenSignature = Font.custom("Covered By Your Grace", size: 22)
}

//
//  BottomSheet.swift
//  BottomSheet
//
//  Created by Tieda Wei on 2020-04-25.
//  Copyright © 2020 Tieda Wei. All rights reserved.
//

import SwiftUI

#if !os(macOS)
public struct BottomSheet<Content: View>: View {
    
    private var grayBackgroundOpacity: Double { isPresented ? 0.4 : 0 }
    
    @Binding var isPresented: Bool
    
    @State var calculatedHeight: CGFloat = .zero
    
    private let fixedHeight: CGFloat?
    
    private let content: Content
    private let contentBackgroundColor: Color
    private let topBarBackgroundColor: Color
    private let animation: Animation
    private let onDismiss: (() -> Void)?
    
    public init(
        isPresented: Binding<Bool>,
        height: CGFloat? = nil,
        topBarHeight: CGFloat = 30,
        topBarCornerRadius: CGFloat? = nil,
        topBarBackgroundColor: Color = Color(.systemBackground),
        contentBackgroundColor: Color = Color(.systemBackground),
        showTopIndicator: Bool,
        animation: Animation = .easeInOut(duration: 0.3),
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.topBarBackgroundColor = topBarBackgroundColor
        self.contentBackgroundColor = contentBackgroundColor
        self._isPresented = isPresented
        
        self.animation = animation
        self.onDismiss = onDismiss
        self.content = content()
        self.fixedHeight = height
    }
    
    public var body: some View {
        GeometryReader { geometry in
            if geometry.size != .zero {
                ZStack {
                    self.fullScreenLightGrayOverlay()
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            Spacer()
                            self.content
                            Color.clear.frame(height: geometry.safeAreaInsets.bottom)
                            Spacer()
                        }
                    }
                    .modifier(GetHeightModifier(height: $calculatedHeight))
                    .frame(height: sheetHeight(in: geometry))
                    .background(self.contentBackgroundColor)
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .animation(animation)
                    .offset(y: self.isPresented ? (geometry.size.height/2 - sheetHeight(in: geometry)/2 + geometry.safeAreaInsets.bottom) : (geometry.size.height/2 + sheetHeight(in: geometry)/2 + geometry.safeAreaInsets.bottom))
                }
            } else {
                EmptyView()
            }
        }
    }
    
    fileprivate func sheetHeight(in geometry: GeometryProxy) -> CGFloat {
        let height: CGFloat = {
            if let fixedHeight, fixedHeight > 0 {
                return fixedHeight
            }
            return calculatedHeight
        }()
        
        return min(height, geometry.size.height)
    }
    
    fileprivate func fullScreenLightGrayOverlay() -> some View {
        Color
            .black
            .opacity(grayBackgroundOpacity)
            .edgesIgnoringSafeArea(.all)
            .animation(animation)
//            .onTapGesture {
//                self.isPresented = false
//                onDismiss?()
//            }
    }
}

public struct GetHeightModifier: ViewModifier {
    public init(height: Binding<CGFloat>) {
        self._height = height
    }
    
    @Binding var height: CGFloat

    public func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                    height = geo.size.height
                }
                return Color.clear
            }
        )
    }
}

#endif

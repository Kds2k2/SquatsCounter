//
//  SplashView.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 14.11.2025.
//

import SwiftUI

struct SplashView: View {
    @State var isAnimationStart: Bool = false
    @State var isAnimationEnd: Bool = false
    @State var isShrink: Bool = false
    
    @State var logoOffset: CGFloat = 0
    @State private var titleText = ""
    
    var body: some View {
        if (isAnimationEnd) {
            ContentView()
        } else {
            ZStack(alignment: .center) {
                Color(AppColors.background)
                
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                    .offset(y: logoOffset)
                    .animation(.easeOut(duration: 0.8), value: logoOffset)
                    .scaleEffect(isShrink ? 0 : 1)
                    .animation(.spring(response: 1.0, dampingFraction: 0.825), value: isShrink)
                
                Text(titleText)
                    .foregroundStyle(AppColors.textPrimary)
                    .font(.title3)
                    .opacity(isAnimationStart ? 1 : 0)
                    .animation(.easeIn(duration: 0.4), value: isAnimationStart)
                    .offset(y: 30)
                    .scaleEffect(isShrink ? 0 : 1)
                    .animation(.spring(response: 1.0, dampingFraction: 0.825), value: isShrink)
            }
            .ignoresSafeArea()
            .onAppear {
                startAnimation()
            }
        }
    }
    
    private func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            logoOffset = -40
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isAnimationStart = true
                titleAnimation()
            }
        }
    }
    
    private func titleAnimation() {
        titleText = ""
        
        for (index, letter) in AppString.title.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.08) {
                titleText.append(letter)
                if titleText == AppString.title {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isShrink = true
                        }
                        
                        withAnimation(.easeInOut(duration: 1.5)) {
                            isAnimationEnd = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}

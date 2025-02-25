//
//  SkeletonCellView.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//

import SwiftUI

struct SkeletonCellView: View {
    let baseDelay: Int // Add base delay parameter
    
    init(baseDelay: Int = 0) {
        self.baseDelay = baseDelay
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Circle()
                        .frame(width: 44, height: 44)
                        .foregroundColor(BPColor.customGrey)
                        .shimmer(delay: baseDelay) // Apply base delay
                        .clipShape(Circle())
                        .padding(.top,1)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 120, height: 19)
                            .foregroundColor(BPColor.customGrey)
                            .shimmer(delay: baseDelay + 90) // Add base delay to individual delay
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.bottom, -1)
                            .padding(.leading, 2)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 80, height: 14)
                            .foregroundColor(BPColor.customGrey)
                            .shimmer(delay: baseDelay + 180) // Add base delay
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.top, 2.5)
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 200, height: 28)
                        .foregroundColor(BPColor.customGrey)
                        .shimmer(delay: baseDelay + 220) // Add base delay
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 7)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 200, height: 28)
                        .foregroundColor(BPColor.customGrey)
                        .shimmer(delay: baseDelay + 190) // Add base delay
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 60, height: 20)
                                .foregroundColor(BPColor.customGrey)
                                .shimmer(delay: baseDelay + 190 + (index * 110)) // Add base delay
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 12)
                }
            }
            Circle()
                .frame(width: 78, height: 78)
                .foregroundColor(BPColor.customGrey)
                .shimmer(delay: baseDelay + 360) // Add base delay
                .clipShape(Circle())
                .padding(.trailing, 18)
                .padding(.leading, 19)
                .padding(.top, 12)
        }
        .padding(.vertical, 9)
        .padding(.leading, 11)
        .padding(.trailing, 1)
        .padding()
        .background(BPColor.customWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }
}

struct SkeletonCellView_Previews: PreviewProvider {
    static var previews: some View {
        SkeletonCellView(baseDelay: 0)
            .frame(width: 370)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

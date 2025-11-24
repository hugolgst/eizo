import SwiftUI

struct VideoFeedView: View {
    @State private var currentIndex: Int = 0
    @State private var cardOffsets: [CGSize] = Array(repeating: .zero, count: dummyData.count)
    @State private var swipeDirections: [SwipeDirection] = Array(repeating: .none, count: dummyData.count)
    @State private var isDragging = false
    @State private var isSubtitleInteractionActive = false
    let videos = dummyData
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(white: isDragging ? 0.15 : 0.0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.2), value: isDragging)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(videos.enumerated()), id: \.offset) { index, video in
                            VideoCardView(
                                snippet: video,
                                isCurrentVideo: currentIndex == index,
                                offset: $cardOffsets[index],
                                swipeDirection: $swipeDirections[index],
                                isDragging: $isDragging,
                                isSubtitleInteractionActive: $isSubtitleInteractionActive
                            )
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .simultaneousGesture(cardSwipeGesture(for: index, videos: videos, isSubtitleInteractionActive: isSubtitleInteractionActive))
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollDisabled(isDragging)
            }
        }
        .ignoresSafeArea()
    }
}

private extension VideoFeedView {
    func cardSwipeGesture(for index: Int, videos: [VideoSnippet], isSubtitleInteractionActive: Bool) -> some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                guard currentIndex == index, !isSubtitleInteractionActive else { return }
                
                let isHorizontalSwipe = abs(value.translation.width) > abs(value.translation.height) * 1.5
                
                if isHorizontalSwipe {
                    isDragging = true
                    cardOffsets[index] = CGSize(
                        width: value.translation.width,
                        height: value.translation.height
                    )
                    
                    if value.translation.width > 50 {
                        swipeDirections[index] = .like
                    } else if value.translation.width < -50 {
                        swipeDirections[index] = .dislike
                    } else {
                        swipeDirections[index] = .none
                    }
                }
            }
            .onEnded { value in
                guard currentIndex == index, !isSubtitleInteractionActive else {
                    cardOffsets[index] = .zero
                    swipeDirections[index] = .none
                    isDragging = false
                    return
                }
                
                let isHorizontalSwipe = abs(value.translation.width) > abs(value.translation.height) * 1.5
                
                if isHorizontalSwipe {
                    let threshold: CGFloat = 120
                    
                    if abs(value.translation.width) > threshold {
                        let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            cardOffsets[index] = CGSize(
                                width: direction * 500,
                                height: value.translation.height
                            )
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if currentIndex < videos.count - 1 {
                                currentIndex += 1
                            }
                            cardOffsets[index] = .zero
                            swipeDirections[index] = .none
                            isDragging = false
                        }
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            cardOffsets[index] = .zero
                            swipeDirections[index] = .none
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            cardOffsets[index] = .zero
                            isDragging = false
                        }
                    }
                } else {
                    cardOffsets[index] = .zero
                    swipeDirections[index] = .none
                    isDragging = false
                }
            }
    }
}


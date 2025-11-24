import SwiftUI

enum SwipeDirection {
    case none
    case like
    case dislike
}

struct VideoCardView: View {
    let snippet: VideoSnippet
    let isCurrentVideo: Bool
    @Binding var offset: CGSize
    @Binding var swipeDirection: SwipeDirection
    @Binding var isDragging: Bool
    @State private var currentTime: Double = 0.0
    @State private var aspectMode: VideoAspectMode = .square
    @State private var isSubscribed = false
    @AppStorage("subtitlePositionRatioY") private var storedSubtitleRatioY: Double = 0.5
    @State private var subtitlePosition: CGPoint = .zero
    @State private var subtitleSize: CGSize = .zero
    @State private var hasInitializedSubtitlePosition = false
    @State private var headerHeight: CGFloat = 0
    @State private var isSubtitleBeingDragged = false
    @State private var subtitleDragStartPosition: CGPoint = .zero
    @State private var isShowingWiggle = false
    @Binding var isSubtitleInteractionActive: Bool
    private let subtitleEdgePadding: CGFloat = 16
    private let reservedTabBarHeight: CGFloat = 220
    
    private var currentSubtitle: Subtitle? {
        snippet.subtitles.first { subtitle in
            currentTime >= subtitle.startTime && currentTime < subtitle.endTime
        }
    }
    
    private var rotation: Angle {
        Angle(degrees: Double(offset.width / 20))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    YouTubePlayerView(
                        videoId: snippet.videoId,
                        startTime: snippet.startTime,
                        endTime: snippet.endTime,
                        isVisible: .constant(isCurrentVideo),
                        currentTime: $currentTime,
                        aspectMode: $aspectMode
                    )
                    .frame(height: aspectMode == .fullVertical ? geometry.size.height : (aspectMode == .original ? geometry.size.width * 0.5625 : geometry.size.width))
                    .clipped()
                    Spacer()
                }
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            if value > 1.05 {
                                aspectMode = .fullVertical
                            } else if value < 0.95 {
                                aspectMode = .original
                            } else {
                                aspectMode = .square
                            }
                        }
                )
                
                if swipeDirection == .like {
                    VStack {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.green)
                            .shadow(color: .black.opacity(0.5), radius: 10)
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                } else if swipeDirection == .dislike {
                    VStack {
                        Spacer()
                        Image(systemName: "hand.thumbsdown.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.red)
                            .shadow(color: .black.opacity(0.5), radius: 10)
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 12) {
                            Text(snippet.title)
                                .font(.system(size: 20, weight: .bold))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Button(action: {
                                if let url = URL(string: "https://www.youtube.com/watch?v=\(snippet.videoId)&t=\(Int(snippet.startTime))") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("🔗")
                                    .font(.system(size: 16))
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                    )
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Text(snippet.channelName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    isSubscribed.toggle()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: isSubscribed ? "checkmark" : "plus")
                                        .font(.system(size: 10, weight: .bold))
                                    Text(isSubscribed ? "Subscribed" : "Subscribe")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundColor(isSubscribed ? .white : .black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(isSubscribed ? Color.white.opacity(0.3) : Color.white)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: HeaderHeightPreferenceKey.self, value: proxy.size.height)
                        }
                    )
                    
                    Spacer()
                    
                    if let currentSubtitle = currentSubtitle {
                        SubtitleView(subtitle: currentSubtitle)
                            .scaleEffect(1)
                            .rotationEffect(.degrees(isShowingWiggle ? 3 : 0))
                            .animation(isShowingWiggle ? .easeInOut(duration: 0.12).repeatForever(autoreverses: true) : .default, value: isShowingWiggle)
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSubtitleBeingDragged)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            subtitleSize = proxy.size
                                            subtitlePosition = clampedSubtitlePosition(
                                                subtitlePosition == .zero ? defaultSubtitlePosition(for: geometry) : subtitlePosition,
                                                in: geometry
                                            )
                                        }
                                        .onChange(of: proxy.size) { _, newSize in
                                            subtitleSize = newSize
                                            subtitlePosition = clampedSubtitlePosition(subtitlePosition, in: geometry)
                                        }
                                }
                            )
                            .position(subtitlePosition == .zero ? defaultSubtitlePosition(for: geometry) : subtitlePosition)
                            .contentShape(Rectangle())
                            .gesture(subtitleDragGesture(in: geometry))
                            .animation(.easeInOut(duration: 0.2), value: currentSubtitle.id)
                    }
                }
                .onPreferenceChange(HeaderHeightPreferenceKey.self) { value in
                    headerHeight = value
                }
            }
            .foregroundColor(.white)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
            .cornerRadius(isDragging ? 39 : 0)
            .shadow(radius: isDragging ? 20 : 0)
            .offset(x: offset.width, y: offset.height * 0.4)
            .rotationEffect(rotation)
            .onChange(of: isCurrentVideo) { _, newValue in
                if !newValue {
                    currentTime = snippet.startTime
                    aspectMode = .square
                } else {
                    currentTime = snippet.startTime
                }
            }
            .onAppear {
                initializeSubtitlePositionIfNeeded(using: geometry)
            }
            .onChange(of: geometry.size) { _, _ in
                guard hasInitializedSubtitlePosition else { return }
                let recalculatedPoint = CGPoint(
                    x: geometry.size.width / 2,  // Always center horizontally
                    y: geometry.size.height * storedSubtitleRatioY
                )
                subtitlePosition = clampedSubtitlePosition(recalculatedPoint, in: geometry)
            }
        }
    }
}

private struct HeaderHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

extension VideoCardView {
    private func initializeSubtitlePositionIfNeeded(using geometry: GeometryProxy) {
        guard !hasInitializedSubtitlePosition else { return }
        let point = defaultSubtitlePosition(for: geometry)
        subtitlePosition = point
        storedSubtitleRatioY = min(max(Double(point.y / geometry.size.height), 0), 1)
        hasInitializedSubtitlePosition = true
    }
    
    private func defaultSubtitlePosition(for geometry: GeometryProxy) -> CGPoint {
        let x = geometry.size.width / 2  // Always center horizontally
        let y = geometry.size.height * storedSubtitleRatioY
        let point = CGPoint(x: x, y: y)
        return clampedSubtitlePosition(point, in: geometry)
    }
    
    private func clampedSubtitlePosition(_ point: CGPoint, in geometry: GeometryProxy) -> CGPoint {
        let halfWidth = max(subtitleSize.width / 2, 1)
        let halfHeight = max(subtitleSize.height / 2, 1)
        
        // Always center horizontally
        let clampedX = geometry.size.width / 2
        
        let topRestricted = geometry.safeAreaInsets.top + 30
        let bottomRestricted = geometry.size.height - (geometry.safeAreaInsets.bottom + reservedTabBarHeight + halfHeight + subtitleEdgePadding)
        
        let clampedY = min(max(point.y, topRestricted), bottomRestricted)
        return CGPoint(x: clampedX, y: clampedY)
    }
    
    private func subtitleDragGesture(in geometry: GeometryProxy) -> some Gesture {
        LongPressGesture(minimumDuration: 1.0)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                switch value {
                case .second(true, let drag?):
                    if !isSubtitleBeingDragged {
                        beginSubtitleDrag(in: geometry)
                    }
                    
                    // Only allow vertical movement
                    let proposedPoint = CGPoint(
                        x: geometry.size.width / 2,  // Keep centered horizontally
                        y: subtitleDragStartPosition.y + drag.translation.height
                    )
                    subtitlePosition = clampedSubtitlePosition(proposedPoint, in: geometry)
                case .second(true, nil):
                    if !isSubtitleBeingDragged {
                        beginSubtitleDrag(in: geometry)
                    }
                default:
                    break
                }
            }
            .onEnded { value in
                isSubtitleBeingDragged = false
                isSubtitleInteractionActive = false
                isShowingWiggle = false  // Stop wiggle when finger is lifted
                
                guard case .second(true, _) = value else { return }
                let ratioY = min(max(Double(subtitlePosition.y / geometry.size.height), 0), 1)
                storedSubtitleRatioY = ratioY
            }
    }
    
    private func beginSubtitleDrag(in geometry: GeometryProxy) {
        isSubtitleBeingDragged = true
        isSubtitleInteractionActive = true
        subtitleDragStartPosition = subtitlePosition == .zero ? defaultSubtitlePosition(for: geometry) : subtitlePosition
        isShowingWiggle = true  // Start continuous wiggle
    }
}

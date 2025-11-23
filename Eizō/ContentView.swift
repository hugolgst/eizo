//
//  ContentView.swift
//  Eizō
//
//  Created by Hugo on 23.11.2025.
//

import SwiftUI
import WebKit

// MARK: - 1. Data Structures

struct Subtitle: Identifiable {
    let id = UUID()
    let startTime: Double
    let endTime: Double
    let japanese: String
    let english: String
}

struct VideoSnippet: Identifiable {
    let id = UUID()
    let videoId: String
    let startTime: Double
    let endTime: Double
    let title: String
    let channelName: String // ADDED: Channel Name
    let subtitles: [Subtitle]
}

// MARK: - 2. Dummy Data

let dummyData: [VideoSnippet] = [
    .init(
        videoId: "6mWt-7HAYCc",
        startTime: 0.0,
        endTime: 15.0,
        title: "Me at the zoo",
        channelName: "Jawed", // ADDED
        subtitles: [
            .init(startTime: 0.0, endTime: 3.0, japanese: "こんにちは、動物園です", english: "Hello, this is the zoo"),
            .init(startTime: 3.0, endTime: 6.0, japanese: "象の前にいます", english: "We're in front of the elephants"),
            .init(startTime: 6.0, endTime: 9.0, japanese: "とても面白いですね", english: "This is very interesting"),
            .init(startTime: 9.0, endTime: 12.0, japanese: "長い鼻を持っています", english: "They have really long trunks"),
            .init(startTime: 12.0, endTime: 15.0, japanese: "それだけです", english: "That's pretty much it")
        ]
    ),
    .init(
        videoId: "OPf0YbXqDm0",
        startTime: 10.0,
        endTime: 25.0,
        title: "Mark Rober: Back to School Science",
        channelName: "Mark Rober", // ADDED
        subtitles: [
            .init(startTime: 10.0, endTime: 13.0, japanese: "科学は素晴らしい", english: "Science is amazing"),
            .init(startTime: 13.0, endTime: 16.0, japanese: "実験を始めましょう", english: "Let's start the experiment"),
            .init(startTime: 16.0, endTime: 19.0, japanese: "これを見てください", english: "Look at this"),
            .init(startTime: 19.0, endTime: 22.0, japanese: "信じられない結果です", english: "The results are incredible"),
            .init(startTime: 22.0, endTime: 25.0, japanese: "試してみてください", english: "Try this yourself")
        ]
    ),
    .init(
        videoId: "aqz-KE-bpKQ",
        startTime: 5.0,
        endTime: 20.0,
        title: "Big Buck Bunny Short Film",
        channelName: "Blender Foundation", // ADDED
        subtitles: [
            .init(startTime: 5.0, endTime: 8.0, japanese: "美しい朝です", english: "It's a beautiful morning"),
            .init(startTime: 8.0, endTime: 11.0, japanese: "ウサギが目を覚ました", english: "The bunny wakes up"),
            .init(startTime: 11.0, endTime: 14.0, japanese: "森の中を歩いています", english: "Walking through the forest"),
            .init(startTime: 14.0, endTime: 17.0, japanese: "何かが起こる", english: "Something is about to happen"),
            .init(startTime: 17.0, endTime: 20.0, japanese: "冒険が始まる", english: "The adventure begins")
        ]
    ),
    .init(
        videoId: "9bZkp7q19f0",
        startTime: 30.0,
        endTime: 50.0,
        title: "PSY - GANGNAM STYLE (강남스타일) M/V",
        channelName: "officialpsy", // ADDED
        subtitles: [
            .init(startTime: 30.0, endTime: 33.0, japanese: "江南スタイル", english: "Gangnam Style"),
            .init(startTime: 33.0, endTime: 36.0, japanese: "踊りましょう", english: "Let's dance"),
            .init(startTime: 36.0, endTime: 39.0, japanese: "リズムに乗って", english: "Feel the rhythm"),
            .init(startTime: 39.0, endTime: 42.0, japanese: "オッパ江南スタイル", english: "Oppa Gangnam Style"),
            .init(startTime: 42.0, endTime: 45.0, japanese: "みんな一緒に", english: "Everyone together"),
            .init(startTime: 45.0, endTime: 50.0, japanese: "楽しもう", english: "Let's have fun")
        ]
    ),
]

// MARK: - 3. YouTube Player Coordinator

class YouTubeCoordinator: NSObject, WKScriptMessageHandler {
    var parent: YouTubePlayerView
    
    init(_ parent: YouTubePlayerView) {
        self.parent = parent
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "playerReady" {
            parent.isPlayerReady = true
        } else if message.name == "timeUpdate" {
            if let timeString = message.body as? String,
               let time = Double(timeString) {
                DispatchQueue.main.async {
                    self.parent.currentTime = time
                }
            }
        }
    }
}

// MARK: - 4. YouTube Player View

struct YouTubePlayerView: UIViewRepresentable {
    let videoId: String
    let startTime: Double
    let endTime: Double
    @Binding var isVisible: Bool
    @Binding var isPaused: Bool
    @State var isPlayerReady = false
    @Binding var currentTime: Double
    
    func makeCoordinator() -> YouTubeCoordinator {
        YouTubeCoordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "playerReady")
        contentController.add(context.coordinator, name: "timeUpdate")
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if isVisible && webView.url == nil {
            let embedHTML = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <style>
                    * { margin: 0; padding: 0; overflow: hidden; }
                    body { 
                        background-color: black; 
                        width: 100vw; 
                        height: 100vh; 
                        position: relative;
                    }
                    /* This CSS implements the aspect-fill/crop-to-vertical-screen behavior */
                    #player { 
                        position: absolute;
                        top: 50%;
                        left: 50%;
                        transform: translate(-50%, -50%);
                        width: 100vh;
                        height: 177.78vh;
                        pointer-events: none;
                    }
                    @media (max-aspect-ratio: 9/16) {
                        #player {
                            width: 177.78vw;
                            height: 100vw;
                        }
                    }
                </style>
            </head>
            <body>
                <div id="player"></div>
                <script>
                    var tag = document.createElement('script');
                    tag.src = "https://www.youtube.com/iframe_api";
                    var firstScriptTag = document.getElementsByTagName('script')[0];
                    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
                    
                    var player;
                    var loopTimer;
                    var timeUpdateInterval;
                    var isPaused = false;
                    
                    function onYouTubeIframeAPIReady() {
                        player = new YT.Player('player', {
                            videoId: '\(videoId)',
                            playerVars: {
                                'autoplay': 1,
                                'controls': 0,
                                'disablekb': 1,
                                'showinfo': 0,
                                'modestbranding': 1,
                                'fs': 0,
                                'cc_load_policy': 0,
                                'iv_load_policy': 3,
                                'start': \(Int(startTime)),
                                'playsinline': 1,
                                'rel': 0,
                                'origin': window.location.origin
                            },
                            events: {
                                'onReady': onPlayerReady,
                                'onStateChange': onPlayerStateChange
                            }
                        });
                    }
                    
                    function onPlayerReady(event) {
                        event.target.mute();
                        event.target.playVideo();
                        window.webkit.messageHandlers.playerReady.postMessage('ready');
                        checkLoop();
                        startTimeUpdate();
                    }
                    
                    function startTimeUpdate() {
                        if (timeUpdateInterval) {
                            clearInterval(timeUpdateInterval);
                        }
                        timeUpdateInterval = setInterval(function() {
                            if (player && player.getCurrentTime) {
                                var time = player.getCurrentTime();
                                window.webkit.messageHandlers.timeUpdate.postMessage(time.toString());
                            }
                        }, 100);
                    }
                    
                    function checkLoop() {
                        if (player && player.getCurrentTime && !isPaused) {
                            var currentTime = player.getCurrentTime();
                            if (currentTime >= \(endTime)) {
                                player.seekTo(\(startTime), true);
                            }
                        }
                        loopTimer = setTimeout(checkLoop, 100);
                    }
                    
                    function onPlayerStateChange(event) {
                        if (event.data == YT.PlayerState.PLAYING && !isPaused) {
                            checkLoop();
                            startTimeUpdate();
                        }
                    }
                    
                    function togglePlayPause() {
                        if (player) {
                            isPaused = !isPaused;
                            if (isPaused) {
                                player.pauseVideo();
                            } else {
                                player.playVideo();
                                checkLoop();
                                startTimeUpdate();
                            }
                        }
                    }
                </script>
            </body>
            </html>
            """
            webView.loadHTMLString(embedHTML, baseURL: URL(string: "https://localhost"))
        }
        
        // Handle play/pause state changes
        if isPlayerReady && isPaused {
            webView.evaluateJavaScript("togglePlayPause();")
        }
    }
}

// MARK: - 5. Subtitle View

struct SubtitleView: View {
    let subtitle: Subtitle?
    
    var body: some View {
        if let subtitle = subtitle {
            VStack(spacing: 4) {
                Text(subtitle.japanese)
                    .font(.system(size: 24, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(subtitle.english)
                    .font(.system(size: 16, weight: .regular))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(white: 0.2, opacity: 0.9))
            )
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }
}

// MARK: - 6. Progress Bar View

struct ProgressBarView: View {
    let currentTime: Double
    let startTime: Double
    let endTime: Double
    
    var progress: Double {
        let duration = endTime - startTime
        guard duration > 0 else { return 0 }
        return min(max((currentTime - startTime) / duration, 0), 1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 3)
                
                // Progress
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * progress, height: 3)
            }
        }
        .frame(height: 3)
    }
}

// MARK: - 7. Swipe Feedback View (NEW)

struct SwipeFeedbackView: View {
    let isLike: Bool
    let opacity: Double

    var body: some View {
        VStack {
            Spacer()
            // Green Heart for Like, Red Thumbs Down for Dislike
            Image(systemName: isLike ? "heart.fill" : "hand.thumbsdown.fill")
                .font(.system(size: 80))
                .foregroundColor(isLike ? .green : .red)
                .opacity(opacity)
                .shadow(color: .black.opacity(0.4), radius: 10)
                .padding(.bottom, 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


// MARK: - 8. Video View (MAJOR CHANGES)

struct VideoView: View {
    let snippet: VideoSnippet
    let isCurrentVideo: Bool
    let onSwipeCompleted: (_ direction: SwipeDirection) -> Void // NEW: Swipe completion handler
    
    enum SwipeDirection { case left, right }
    enum SwipeResult { case like, dislike } // For animation control

    // Video Playback States
    @State private var isPaused = false
    @State private var showPauseIcon = false
    @State private var currentTime: Double = 0.0
    @State private var lastTapTime: Date = .distantPast

    // Pinch-to-Zoom States (NEW)
    @State private var videoScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 3.0 // Allows up to 3x zoom

    // Tinder Swipe States (NEW)
    @State private var offset: CGSize = .zero
    @State private var feedbackOpacity: Double = 0 // Controls feedback icon visibility based on drag
    private let swipeThreshold: CGFloat = 150 // Distance to confirm a swipe

    var currentSubtitle: Subtitle? {
        snippet.subtitles.first { subtitle in
            currentTime >= subtitle.startTime && currentTime < subtitle.endTime
        }
    }
    
    // Magnification Gesture for Pinch-to-Zoom
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                videoScale = min(max(newScale, minScale), maxScale) // Clamps scale
            }
            .onEnded { _ in
                lastScale = videoScale
            }
    }

    // Drag Gesture for Tinder Swipe
    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                // Only allow horizontal drag
                offset = CGSize(width: gesture.translation.width, height: 0)
                feedbackOpacity = Double(min(abs(offset.width) / swipeThreshold / 1.5, 1.0))
            }
            .onEnded { gesture in
                let endOffset = gesture.translation.width
                let swipeDirection: SwipeDirection?
                
                if endOffset > swipeThreshold { // Swipe Right (Like)
                    swipeDirection = .right
                } else if endOffset < -swipeThreshold { // Swipe Left (Dislike)
                    swipeDirection = .left
                } else {
                    swipeDirection = nil
                }

                if let direction = swipeDirection {
                    // Trigger exit animation and call completion
                    withAnimation(.easeInOut(duration: 0.4)) {
                        offset = CGSize(width: direction == .right ? 500 : -500, height: 0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onSwipeCompleted(direction)
                    }
                } else {
                    // Snap back
                    withAnimation(.spring()) {
                        offset = .zero
                        feedbackOpacity = 0
                    }
                }
            }
    }

    var body: some View {
        ZStack {
            // YouTube Player
            YouTubePlayerView(
                videoId: snippet.videoId,
                startTime: snippet.startTime,
                endTime: snippet.endTime,
                isVisible: .constant(isCurrentVideo),
                isPaused: $isPaused,
                currentTime: $currentTime
            )
            .scaleEffect(videoScale) // Apply zoom/scale effect
            .ignoresSafeArea()
            .clipped()
            
            // Tap to pause/play and Pinch-to-Zoom Gesture
            Color.clear
                .contentShape(Rectangle())
                .gesture(magnification) // Pinch-to-Zoom
                .onTapGesture {
                    let now = Date()
                    if now.timeIntervalSince(lastTapTime) > 0.3 {
                        isPaused.toggle()
                        showPauseIcon = true
                        lastTapTime = now
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showPauseIcon = false
                        }
                    }
                }
            
            // Pause icon indicator
            if showPauseIcon {
                Image(systemName: isPaused ? "pause.fill" : "play.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Swipe Feedback (Heart/Thumbs Down)
            if offset.width != 0 || offset.width.isFinite {
                // Show feedback while dragging or after completion
                SwipeFeedbackView(
                    isLike: offset.width > 0,
                    opacity: feedbackOpacity
                )
                .allowsHitTesting(false)
            }

            // Overlay UI
            VStack(alignment: .leading, spacing: 0) {
                
                // Title and Link Button
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        // Title
                        Text(snippet.title)
                            .font(.system(size: 20, weight: .bold))
                            .lineLimit(2)
                            .padding(.bottom, 2)
                        
                        // Channel Name and Subscribe Button (NEW)
                        HStack(spacing: 8) {
                            Text(snippet.channelName)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Button(action: {
                                print("Dummy subscribe action for \(snippet.channelName)")
                            }) {
                                HStack(spacing: 4) {
                                    Text("SUBSCRIBE")
                                        .font(.caption.weight(.bold))
                                    // Using a system icon for the "plus" emoji-like button
                                    Image(systemName: "plus.circle.fill")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.red)
                                .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // External Link Button
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
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Subtitles
                if let currentSubtitle = currentSubtitle {
                    SubtitleView(subtitle: currentSubtitle)
                        .padding(.bottom, 120) // Space for bottom nav bar
                        .animation(.easeInOut(duration: 0.2), value: currentSubtitle.id)
                }
            }
            
            // Progress bar at bottom
            if isPaused {
                VStack {
                    Spacer()
                    ProgressBarView(
                        currentTime: currentTime,
                        startTime: snippet.startTime,
                        endTime: snippet.endTime
                    )
                    .padding(.horizontal, 0)
                    .padding(.bottom, 80) // Space for nav bar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .foregroundColor(.white)
        .rotationEffect(.degrees(Double(offset.width / 20))) // Tilt the video card
        .offset(offset) // Move the video card
        .gesture(drag) // Tinder swipe gesture
        .onChange(of: isCurrentVideo) { _, newValue in
            // Reset states when a new video is scrolled to
            if !newValue {
                isPaused = false
                currentTime = snippet.startTime
                // Reset drag and zoom states for the next view
                offset = .zero
                videoScale = 1.0
                lastScale = 1.0
            } else {
                currentTime = snippet.startTime
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPaused)
        .animation(.default, value: videoScale) // Animate zoom changes
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: offset) // Spring animation for drag
    }
}

// MARK: - 9. Navigation Tab Enum

enum NavigationTab: String, CaseIterable {
    case video = "Video"
    case glossary = "Glossary"
    case settings = "Settings"
    
    var icon: String {
        switch self {
        case .video:
            return "play.rectangle.fill"
        case .glossary:
            return "book.fill"
        case .settings:
            return "gear"
        }
    }
}

// MARK: - 10. Bottom Navigation Bar

struct BottomNavigationBar: View {
    @Binding var selectedTab: NavigationTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(NavigationTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 24))
                        Text(tab.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color.black.opacity(0.9))
    }
}

// MARK: - 11. Glossary View

struct GlossaryView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Glossary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                Text("Your saved words and phrases will appear here")
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
        }
    }
}

// MARK: - 12. Settings View

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                Text("App settings and preferences")
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
        }
    }
}

// MARK: - 13. Video Feed View (MODIFIED)

struct VideoFeedView: View {
    @State private var currentIndex: Int = 0
    let videos = dummyData
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in // Added ScrollViewReader to manually scroll
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(videos.enumerated()), id: \.offset) { index, video in
                            VideoView(
                                snippet: video,
                                isCurrentVideo: currentIndex == index,
                                onSwipeCompleted: { direction in
                                    // Navigate to the next video (loop to start if at the end)
                                    if currentIndex < videos.count - 1 {
                                        let newIndex = currentIndex + 1
                                        currentIndex = newIndex
                                        // Scroll to the new index immediately for a continuous feed
                                        withAnimation {
                                            proxy.scrollTo(newIndex, anchor: .top)
                                        }
                                    } else {
                                        // Optional: loop back to the first video
                                        currentIndex = 0
                                        withAnimation {
                                            proxy.scrollTo(0, anchor: .top)
                                        }
                                    }
                                }
                            )
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .id(index) // Required for ScrollViewReader
                        }
                    }
                    .background(
                        // Logic to detect which video is currently visible (for manual up/down scrolling)
                        GeometryReader { scrollProxy in
                            Color.clear.onAppear {} // Necessary for the next line to work
                                .onChange(of: scrollProxy.frame(in: .global).minY) { _, newValue in
                                    // A robust method for tracking scroll position in a vertical feed.
                                    let contentOffset = -newValue
                                    let newIndex = Int(round(contentOffset / geometry.size.height))
                                    if newIndex != currentIndex && newIndex >= 0 && newIndex < videos.count {
                                        currentIndex = newIndex
                                    }
                                }
                        }
                    )
                    .scrollTargetLayout()
                }
                // .scrollTargetBehavior(.paging) // Removed to allow smooth integration with ScrollViewReader
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - 14. Main Content View

struct ContentView: View {
    @State private var selectedTab: NavigationTab = .video
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content based on selected tab
            Group {
                switch selectedTab {
                case .video:
                    VideoFeedView()
                case .glossary:
                    GlossaryView()
                case .settings:
                    SettingsView()
                }
            }
            .ignoresSafeArea()
            
            // Bottom navigation bar
            BottomNavigationBar(selectedTab: $selectedTab)
                .frame(height: 80)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

// MARK: - 15. Preview

#Preview {
    ContentView()
}

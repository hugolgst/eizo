import SwiftUI
import WebKit

class YouTubeCoordinator: NSObject, WKScriptMessageHandler {
    var parent: YouTubePlayerView
    
    init(_ parent: YouTubePlayerView) {
        self.parent = parent
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "timeUpdate" {
            if let timeString = message.body as? String,
               let time = Double(timeString) {
                DispatchQueue.main.async {
                    self.parent.currentTime = time
                }
            }
        }
    }
}

enum VideoAspectMode {
    case fullVertical
    case square
    case original
}

struct YouTubePlayerView: UIViewRepresentable {
    let videoId: String
    let startTime: Double
    let endTime: Double
    @Binding var isVisible: Bool
    @Binding var currentTime: Double
    @Binding var aspectMode: VideoAspectMode
    
    func makeCoordinator() -> YouTubeCoordinator {
        YouTubeCoordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let contentController = WKUserContentController()
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
            loadPlayer(in: webView)
        }
        
        if isVisible && webView.url != nil {
            updatePlayerStyle(in: webView)
        }
    }
    
    private func loadPlayer(in webView: WKWebView) {
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
                    overflow: hidden;
                }
                #player {
                    position: absolute;
                    top: 50%;
                    left: 50%;
                    transform: translate(-50%, -50%);
                    width: 100vw;
                    height: 100vw;
                    pointer-events: auto;
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
                
                function onYouTubeIframeAPIReady() {
                    player = new YT.Player('player', {
                        videoId: '\(videoId)',
                        playerVars: {
                            'autoplay': 1,
                            'controls': 1,
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
                    if (player && player.getCurrentTime) {
                        var currentTime = player.getCurrentTime();
                        if (currentTime >= \(endTime)) {
                            player.seekTo(\(startTime), true);
                        }
                    }
                    loopTimer = setTimeout(checkLoop, 100);
                }
                
                function onPlayerStateChange(event) {
                    if (event.data == YT.PlayerState.PLAYING) {
                        checkLoop();
                        startTimeUpdate();
                    }
                }
                
                function updatePlayerStyle(mode) {
                    var playerEl = document.getElementById('player');
                    if (mode === 'fullVertical') {
                        playerEl.style.width = '177.78vh';
                        playerEl.style.height = '100vh';
                    } else if (mode === 'square') {
                        playerEl.style.width = '100vw';
                        playerEl.style.height = '100vw';
                    } else if (mode === 'original') {
                        playerEl.style.width = '100vw';
                        playerEl.style.height = '56.25vw';
                    }
                }
            </script>
        </body>
        </html>
        """
        webView.loadHTMLString(embedHTML, baseURL: URL(string: "https://localhost"))
    }
    
    private func updatePlayerStyle(in webView: WKWebView) {
        let mode: String
        switch aspectMode {
        case .fullVertical:
            mode = "fullVertical"
        case .square:
            mode = "square"
        case .original:
            mode = "original"
        }
        webView.evaluateJavaScript("updatePlayerStyle('\(mode)');")
    }
}


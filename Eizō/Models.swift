import Foundation

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
    let channelName: String
    let subtitles: [Subtitle]
}

let dummyData: [VideoSnippet] = [
    .init(
        videoId: "6mWt-7HAYCc",
        startTime: 0.0,
        endTime: 15.0,
        title: "Me at the zoo",
        channelName: "jawed",
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
        title: "Mark Rober",
        channelName: "Mark Rober",
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
        title: "Big Buck Bunny",
        channelName: "Blender Foundation",
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
        title: "Gangnam Style",
        channelName: "officialpsy",
        subtitles: [
            .init(startTime: 30.0, endTime: 33.0, japanese: "江南スタイル", english: "Gangnam Style"),
            .init(startTime: 33.0, endTime: 36.0, japanese: "踊りましょう", english: "Let's dance"),
            .init(startTime: 36.0, endTime: 39.0, japanese: "リズムに乗って", english: "Feel the rhythm"),
            .init(startTime: 39.0, endTime: 42.0, japanese: "オッパ江南スタイル", english: "Oppa Gangnam Style"),
            .init(startTime: 42.0, endTime: 45.0, japanese: "みんな一緒に", english: "Everyone together"),
            .init(startTime: 45.0, endTime: 50.0, japanese: "楽しもう", english: "Let's have fun")
        ]
    )
]


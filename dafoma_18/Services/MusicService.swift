import Foundation
import CoreLocation
import Combine
import AVFoundation
import MediaPlayer

class MusicService: ObservableObject {
    @Published var currentPlaylist: Playlist?
    @Published var isPlaying: Bool = false
    @Published var currentTrack: Track?
    
    private var cancellables = Set<AnyCancellable>()
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // Sample tracks for demo purposes
    private let sampleTracks: [Track] = [
        Track(title: "Morning Energy", artist: "LifeTunes", duration: 210, genre: "Electronic", mood: "Energetic"),
        Track(title: "City Vibes", artist: "Urban Sounds", duration: 180, genre: "Hip Hop", mood: "Happy"),
        Track(title: "Peaceful Moments", artist: "Calm Collective", duration: 240, genre: "Ambient", mood: "Calm"),
        Track(title: "Workout Beast", artist: "Fitness Beats", duration: 195, genre: "Electronic", mood: "Energetic"),
        Track(title: "Study Focus", artist: "Concentration", duration: 300, genre: "Lo-fi", mood: "Focused"),
        Track(title: "Evening Chill", artist: "Relaxation", duration: 270, genre: "Jazz", mood: "Relaxed"),
        Track(title: "Adventure Time", artist: "Explorer", duration: 220, genre: "Rock", mood: "Adventurous"),
        Track(title: "Creative Flow", artist: "Inspiration", duration: 260, genre: "Instrumental", mood: "Creative")
    ]
    
    func generateGeoTunedPlaylist(for location: CLLocationCoordinate2D, mood: String = "", completion: @escaping (Playlist) -> Void) {
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let filteredTracks = self.getTracksForLocation(location, mood: mood)
            let locationName = self.getLocationBasedName(for: location)
            
            let playlist = Playlist(
                name: "\(locationName) Mix",
                tracks: filteredTracks,
                location: location,
                mood: mood,
                genre: "Mixed",
                isGeoTuned: true
            )
            
            completion(playlist)
        }
    }
    
    func generateMoodBasedPlaylist(mood: Mood, completion: @escaping (Playlist) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let filteredTracks = self.sampleTracks.filter { track in
                track.mood.lowercased() == mood.rawValue.lowercased()
            }
            
            let playlist = Playlist(
                name: "\(mood.rawValue) Playlist",
                tracks: filteredTracks.isEmpty ? Array(self.sampleTracks.prefix(4)) : filteredTracks,
                mood: mood.rawValue,
                genre: "Mixed"
            )
            
            completion(playlist)
        }
    }
    
    func getRecommendedTracks(for challenge: Challenge, completion: @escaping ([Track]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let categoryTracks = self.sampleTracks.filter { track in
                switch challenge.category {
                case .fitness:
                    return track.mood == "Energetic" || track.genre == "Electronic"
                case .mindfulness:
                    return track.mood == "Calm" || track.mood == "Relaxed"
                case .creativity:
                    return track.mood == "Creative" || track.genre == "Instrumental"
                case .learning:
                    return track.mood == "Focused" || track.genre == "Lo-fi"
                default:
                    return true
                }
            }
            
            completion(Array(categoryTracks.prefix(3)))
        }
    }
    
    func playTrack(_ track: Track) {
        currentTrack = track
        
        // Generate a simple tone for demo purposes since we don't have actual audio files
        playDemoTone(for: track)
        
        isPlaying = true
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTrack = nil
    }
    
    private func playDemoTone(for track: Track) {
        // Generate a simple demo tone based on the track's mood
        let frequency: Float = moodToFrequency(track.mood)
        let duration: TimeInterval = min(track.duration, 30) // Limit to 30 seconds for demo
        
        if let audioData = generateTone(frequency: frequency, duration: duration) {
            do {
                audioPlayer = try AVAudioPlayer(data: audioData)
                audioPlayer?.numberOfLoops = 0
                audioPlayer?.play()
                
                // Setup media player info
                setupNowPlayingInfo(for: track)
                
            } catch {
                print("Error playing audio: \(error)")
                // Fallback: just update UI state
                isPlaying = true
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.isPlaying = false
                }
            }
        }
    }
    
    private func moodToFrequency(_ mood: String) -> Float {
        switch mood.lowercased() {
        case "energetic": return 880.0  // A5 - high energy
        case "happy": return 659.25     // E5 - bright
        case "calm", "relaxed": return 261.63  // C4 - peaceful
        case "focused": return 440.0    // A4 - steady
        case "creative": return 523.25  // C5 - inspiring
        default: return 440.0           // A4 - default
        }
    }
    
    private func generateTone(frequency: Float, duration: TimeInterval) -> Data? {
        let sampleRate: Float = 44100
        let samples = Int(Float(duration) * sampleRate)
        var audioData = Data(capacity: samples * 2)
        
        for i in 0..<samples {
            let time = Float(i) / sampleRate
            let amplitude: Float = 0.3 // Moderate volume
            let sample = sin(2.0 * Float.pi * frequency * time) * amplitude
            let intSample = Int16(sample * Float(Int16.max))
            
            withUnsafeBytes(of: intSample.littleEndian) { bytes in
                audioData.append(contentsOf: bytes)
            }
        }
        
        return createWAVData(from: audioData, sampleRate: Int(sampleRate))
    }
    
    private func createWAVData(from pcmData: Data, sampleRate: Int) -> Data? {
        let headerSize = 44
        let totalSize = headerSize + pcmData.count
        
        var header = Data(capacity: headerSize)
        
        // RIFF header
        header.append("RIFF".data(using: .ascii)!)
        header.append(UInt32(totalSize - 8).littleEndian.data)
        header.append("WAVE".data(using: .ascii)!)
        
        // Format chunk
        header.append("fmt ".data(using: .ascii)!)
        header.append(UInt32(16).littleEndian.data) // Chunk size
        header.append(UInt16(1).littleEndian.data)  // Audio format (PCM)
        header.append(UInt16(1).littleEndian.data)  // Number of channels
        header.append(UInt32(sampleRate).littleEndian.data) // Sample rate
        header.append(UInt32(sampleRate * 2).littleEndian.data) // Byte rate
        header.append(UInt16(2).littleEndian.data)  // Block align
        header.append(UInt16(16).littleEndian.data) // Bits per sample
        
        // Data chunk
        header.append("data".data(using: .ascii)!)
        header.append(UInt32(pcmData.count).littleEndian.data)
        
        var wavData = header
        wavData.append(pcmData)
        
        return wavData
    }
    
    private func setupNowPlayingInfo(for track: Track) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = track.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func getTracksForLocation(_ location: CLLocationCoordinate2D, mood: String) -> [Track] {
        // Simulate location-based filtering
        var tracks = sampleTracks
        
        if !mood.isEmpty {
            tracks = tracks.filter { $0.mood.lowercased().contains(mood.lowercased()) }
        }
        
        return Array(tracks.shuffled().prefix(6))
    }
    
    private func getLocationBasedName(for location: CLLocationCoordinate2D) -> String {
        // Simplified location naming
        let names = ["Downtown", "Park", "Beach", "Cafe", "Gym", "Home", "Office", "City"]
        return names.randomElement() ?? "Local"
    }
}

// MARK: - Data Extension for Audio Generation
extension Data {
    init<T>(from value: T) {
        var value = value
        self = withUnsafePointer(to: &value) {
            Data(bytes: $0, count: MemoryLayout<T>.size)
        }
    }
}

extension FixedWidthInteger {
    var data: Data {
        return Data(from: self)
    }
}
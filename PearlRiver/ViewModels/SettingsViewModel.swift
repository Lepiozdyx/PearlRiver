import SwiftUI
import AVFoundation

@MainActor class SettingsViewModel: ObservableObject {
    
    @Published var soundIsOn: Bool {
        didSet {
            defaults.set(soundIsOn, forKey: soundKey)
            if !soundIsOn && musicIsOn {
                musicIsOn = false
            }
        }
    }
    
    @Published var musicIsOn: Bool {
        didSet {
            defaults.set(musicIsOn, forKey: musicKey)
            if musicIsOn {
                if soundIsOn {
                    playMusic()
                } else {
                    musicIsOn = false
                }
            } else {
                stopMusic()
            }
        }
    }
    
    static let shared = SettingsViewModel()
    private let defaults = UserDefaults.standard
    private var audioPlayer: AVAudioPlayer?
    private var soundPlayer: AVAudioPlayer?
    
    private let soundKey = "appSound"
    private let musicKey = "appMusic"
    
    private let soundResourceName = "soundResource"
    private let musicResourceName = "musicResource"
    
    private init() {
        self.soundIsOn = true
        self.musicIsOn = true
        
        if defaults.object(forKey: soundKey) != nil {
            self.soundIsOn = defaults.bool(forKey: soundKey)
        } else {
            defaults.set(true, forKey: soundKey)
        }
        
        if defaults.object(forKey: musicKey) != nil {
            self.musicIsOn = defaults.bool(forKey: musicKey)
        } else {
            defaults.set(true, forKey: musicKey)
        }
        
        setupAudio()
        fetchMusic()
        fetchSound()
    }
    
    func toggleSound() {
        soundIsOn.toggle()
    }
    
    func toggleMusic() {
        if !soundIsOn && !musicIsOn {
            return
        }
        musicIsOn.toggle()
    }
    
    func play() {
        guard soundIsOn, let player = soundPlayer else { return }
        player.currentTime = 0
        player.play()
    }
    
    func playMusic() {
        guard soundIsOn, musicIsOn, let player = audioPlayer, !player.isPlaying else { return }
        player.play()
    }
    
    func stopMusic() {
        audioPlayer?.pause()
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    private func fetchSound() {
        guard let url = Bundle.main.url(
            forResource: soundResourceName,
            withExtension: "mp3"
        ) else { return }
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fetchMusic() {
        guard let url = Bundle.main.url(
            forResource: musicResourceName,
            withExtension: "mp3"
        ) else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
}

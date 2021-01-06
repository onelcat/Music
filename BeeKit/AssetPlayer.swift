/*
See LICENSE folder for this sample’s licensing information.

Abstract:
`AssetPlayer` uses an AVQueuePlayer for playback of `ConfigAsset` items,
 with a `NowPlayable` delegate for handling platform-specific behavior.
*/

import AVFoundation
import MediaPlayer
import Kingfisher

// 本地资源播放
class AssetPlayer {
    
    // Possible values of the `playerState` property.
    
    enum PlayerState {
        case stopped
        case playing
        case paused
    }
    
    // The app-supplied object that provides `NowPlayable`-conformant behavior.
    
//    unowned let nowPlayableBehavior: NowPlayable
    
    // The player actually being used for playback. An app may use any system-provided
    // player, or may play content in any way that is wishes, provided that it uses
    // the NowPlayable behavior correctly.
    
    let player: AVQueuePlayer
    
    // A playlist of items to play.
    
    private let playerItems: [AVPlayerItem]
    
    // Metadata for each item.
    
    private let staticMetadatas: [NowPlayableStaticMetadata]
    
    // The internal state of this AssetPlayer separate from the state
    // of its AVQueuePlayer.
    
    private var playerState: PlayerState = .stopped {
        didSet {
            #if os(macOS)
            NSLog("%@", "**** Set player state \(playerState), playbackState \(MPNowPlayingInfoCenter.default().playbackState.rawValue)")
            #else
            NSLog("%@", "**** Set player state \(playerState)")
            #endif
        }
    }
    
    // `true` if the current session has been interrupted by another app.
    
    private var isInterrupted: Bool = false
    
    // Private observers of notifications and property changes.
    
    private var itemObserver: NSKeyValueObservation!
    private var rateObserver: NSKeyValueObservation!
    private var statusObserver: NSObjectProtocol!
    
    // A shorter name for a very long property name.
    
    private static let mediaSelectionKey = "availableMediaCharacteristicsWithMediaSelectionOptions"
    
    // Initialize a new `AssetPlayer` object.
    
    init(assets: [AssetItemModel]) throws {
        
        
        // Get the subset of assets that the configuration actually wants to play,
        // and use it to construct the playlist.
        
        let playableAssets = assets

        self.staticMetadatas = playableAssets.map { $0.metadata }
        self.playerItems = playableAssets.map {
            AVPlayerItem(asset: AVURLAsset(url: $0.assetURL!), automaticallyLoadedAssetKeys: ["availableMediaCharacteristicsWithMediaSelectionOptions"])
        }
        
        // Create a player, and configure it for external playback, if the
        // configuration requires.
        
        self.player = AVQueuePlayer(items: playerItems)
        player.allowsExternalPlayback = defaultAllowsExternalPlayback
        
        // Construct lists of commands to be registered or disabled.
        
        
        // Configure the app for Now Playing Info and Remote Command Center behaviors.
        
         try handleNowPlayableConfiguration(commands: defaultRegisteredCommands, disabledCommands: defaultDisabledCommands)
        

        // Start playing, if there is something to play.
        
        if !playerItems.isEmpty {
            
            // Start a playback session.
            
            try handleNowPlayableSessionStart()
            
            // Observe changes to the current item and playback rate.
            
            if player.currentItem != nil {
                
                itemObserver = player.observe(\.currentItem, options: .initial) {
                    [unowned self] _, _ in
                    self.handlePlayerItemChange()
                }
                
                rateObserver = player.observe(\.rate, options: .initial) {
                    [unowned self] _, _ in
                    self.handlePlaybackChange()
                }
                
                statusObserver = player.observe(\.currentItem?.status, options: .initial) {
                    [unowned self] _, _ in
                    self.handlePlaybackChange()
                }
            }
            
            // Start the player.
            
            play()
        }
    }
    
    // Stop the playback session.
    
    func optOut() {
        
        itemObserver = nil
        rateObserver = nil
        statusObserver = nil
        
        player.pause()
        player.removeAllItems()
        playerState = .stopped
        
        handleNowPlayableSessionEnd()
    }
    
    // MARK: Now Playing Info
    
    // Helper method: update Now Playing Info when the current item changes.
    
    private func handlePlayerItemChange() {
        
        guard playerState != .stopped else { return }
        
        // Find the current item.
        
        guard let currentItem = player.currentItem else { optOut(); return }
        guard let currentIndex = playerItems.firstIndex (where: { $0 == currentItem }) else { return }
        
        // Set the Now Playing Info from static item metadata.
        
        let metadata = staticMetadatas[currentIndex]
        
        handleNowPlayableItemChange(metadata: metadata)
    }
    
    // Helper method: update Now Playing Info when playback rate or position changes.
    
    private func handlePlaybackChange() {
        
        guard playerState != .stopped else { return }
        
        // Find the current item.
        
        guard let currentItem = player.currentItem else { optOut(); return }
        guard currentItem.status == .readyToPlay else { return }
        
        // Create language option groups for the asset's media selection,
        // and determine the current language option in each group, if any.
        
        // Note that this is a simple example of how to create language options.
        // More sophisticated behavior (including default values, and carrying
        // current values between player tracks) can be implemented by building
        // on the techniques shown here.
        
        let asset = currentItem.asset
        
        var languageOptionGroups: [MPNowPlayingInfoLanguageOptionGroup] = []
        var currentLanguageOptions: [MPNowPlayingInfoLanguageOption] = []

        if asset.statusOfValue(forKey: AssetPlayer.mediaSelectionKey, error: nil) == .loaded {
            
            // Examine each media selection group.
            
            for mediaCharacteristic in asset.availableMediaCharacteristicsWithMediaSelectionOptions {
                guard mediaCharacteristic == .audible || mediaCharacteristic == .legible,
                    let mediaSelectionGroup = asset.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic) else { continue }
                
                // Make a corresponding language option group.
                
                let languageOptionGroup = mediaSelectionGroup.makeNowPlayingInfoLanguageOptionGroup()
                languageOptionGroups.append(languageOptionGroup)
                
                // If the media selection group has a current selection,
                // create a corresponding language option.
                
                if let selectedMediaOption = currentItem.currentMediaSelection.selectedMediaOption(in: mediaSelectionGroup),
                    let currentLanguageOption = selectedMediaOption.makeNowPlayingInfoLanguageOption() {
                    currentLanguageOptions.append(currentLanguageOption)
                }
            }
        }
        
        // Construct the dynamic metadata, including language options for audio,
        // subtitle and closed caption tracks that can be enabled for the
        // current asset.
        
        let isPlaying = playerState == .playing
        let metadata = NowPlayableDynamicMetadata(rate: player.rate,
                                                  position: Float(currentItem.currentTime().seconds),
                                                  duration: Float(currentItem.duration.seconds),
                                                  currentLanguageOptions: currentLanguageOptions,
                                                  availableLanguageOptionGroups: languageOptionGroups)
        
        handleNowPlayablePlaybackChange(playing: isPlaying, metadata: metadata)
    }
    
    // MARK: Playback Control
    
    // The following methods handle various playback conditions triggered by remote commands.
    
    private func play() {
        
        switch playerState {
            
        case .stopped:
            playerState = .playing
            player.play()
            
            handlePlayerItemChange()

        case .playing:
            break
            
        case .paused where isInterrupted:
            playerState = .playing
            
        case .paused:
            playerState = .playing
            player.play()
        }
    }
    
    private func pause() {
        
        switch playerState {
            
        case .stopped:
            break
            
        case .playing where isInterrupted:
            playerState = .paused
            
        case .playing:
            playerState = .paused
            player.pause()
            
        case .paused:
            break
        }
    }
    
    private func togglePlayPause() {

        switch playerState {
            
        case .stopped:
            play()
            
        case .playing:
            pause()
            
        case .paused:
            play()
        }
    }
    
    private func nextTrack() {
        
        if case .stopped = playerState { return }
        let playerItem = playerItems[1]
        if player.canInsert(playerItem, after: nil) {
            player.insert(playerItem, after: nil)
            debugPrint("可以播放")
        } else {
            debugPrint("不可以播放")
        }
//        player.advanceToNextItem()
    }
    
    private func previousTrack() {
        
        if case .stopped = playerState { return }
        
        let currentTime = player.currentTime().seconds
        let currentItems = player.items()
        let previousIndex = playerItems.count - currentItems.count - 1
        
        guard currentTime < 3, previousIndex > 0, previousIndex < playerItems.count else { seek(to: .zero); return }
        
        player.removeAllItems()
        
        for playerItem in playerItems[(previousIndex - 1)...] {
            
            if player.canInsert(playerItem, after: nil) {
                player.insert(playerItem, after: nil)
            }
        }
        
        if case .playing = playerState {
            player.play()
        }
    }
    
    private func seek(to time: CMTime) {
        
        if case .stopped = playerState { return }
        
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) {
            isFinished in
            if isFinished {
                self.handlePlaybackChange()
            }
        }
    }
    
    private func seek(to position: TimeInterval) {
        seek(to: CMTime(seconds: position, preferredTimescale: 1))
    }
    
    private func skipForward(by interval: TimeInterval) {
        seek(to: player.currentTime() + CMTime(seconds: interval, preferredTimescale: 1))
    }
    
    private func skipBackward(by interval: TimeInterval) {
        seek(to: player.currentTime() - CMTime(seconds: interval, preferredTimescale: 1))
    }
    
    private func setPlaybackRate(_ rate: Float) {
        
        if case .stopped = playerState { return }
        
        player.rate = rate
    }
    
    private func didEnableLanguageOption(_ languageOption: MPNowPlayingInfoLanguageOption) -> Bool {
        
        guard let currentItem = player.currentItem else { return false }
        guard let (mediaSelectionOption, mediaSelectionGroup) = enabledMediaSelection(for: languageOption) else { return false }
        
        currentItem.select(mediaSelectionOption, in: mediaSelectionGroup)
        handlePlaybackChange()
        
        return true
    }
    
    private func didDisableLanguageOption(_ languageOption: MPNowPlayingInfoLanguageOption) -> Bool {
        
        guard let currentItem = player.currentItem else { return false }
        guard let mediaSelectionGroup = disabledMediaSelection(for: languageOption) else { return false }

        guard mediaSelectionGroup.allowsEmptySelection else { return false }
        currentItem.select(nil, in: mediaSelectionGroup)
        handlePlaybackChange()
        
        return true
    }
    
    // Helper method to get the media selection group and media selection for enabling a language option.
    
    private func enabledMediaSelection(for languageOption: MPNowPlayingInfoLanguageOption) -> (AVMediaSelectionOption, AVMediaSelectionGroup)? {
        
        // In your code, you would implement your logic for choosing a media selection option
        // from a suitable media selection group.
        
        // Note that, when the current track is being played remotely via AirPlay, the language option
        // may not exactly match an option in your local asset's media selection. You may need to consider
        // an approximate comparison algorithm to determine the nearest match.
        
        // If you cannot find an exact or approximate match, you should return `nil` to ignore the
        // enable command.
        
        return nil
    }
    
    // Helper method to get the media selection group for disabling a language option`.
    
    private func disabledMediaSelection(for languageOption: MPNowPlayingInfoLanguageOption) -> AVMediaSelectionGroup? {
        
        // In your code, you would implement your logic for finding the media selection group
        // being disabled.
        
        // Note that, when the current track is being played remotely via AirPlay, the language option
        // may not exactly determine a media selection group in your local asset. You may need to consider
        // an approximate comparison algorithm to determine the nearest match.
        
        // If you cannot find an exact or approximate match, you should return `nil` to ignore the
        // disable command.
        
        return nil
    }
    
    // MARK: Remote Commands
    
    // Handle a command registered with the Remote Command Center.
    
    private func handleCommand(command: NowPlayableCommand, event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        switch command {
            
        case .pause:
            pause()
            
        case .play:
            play()
            
        case .stop:
            optOut()
            
        case .togglePausePlay:
            togglePlayPause()
            
        case .nextTrack:
            nextTrack()
            
        case .previousTrack:
            previousTrack()
            
        case .changePlaybackRate:
            guard let event = event as? MPChangePlaybackRateCommandEvent else { return .commandFailed }
            setPlaybackRate(event.playbackRate)
            
        case .seekBackward:
            guard let event = event as? MPSeekCommandEvent else { return .commandFailed }
            setPlaybackRate(event.type == .beginSeeking ? -3.0 : 1.0)
            
        case .seekForward:
            guard let event = event as? MPSeekCommandEvent else { return .commandFailed }
            setPlaybackRate(event.type == .beginSeeking ? 3.0 : 1.0)
            
        case .skipBackward:
            guard let event = event as? MPSkipIntervalCommandEvent else { return .commandFailed }
            skipBackward(by: event.interval)
            
        case .skipForward:
            guard let event = event as? MPSkipIntervalCommandEvent else { return .commandFailed }
            skipForward(by: event.interval)
            
        case .changePlaybackPosition:
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            seek(to: event.positionTime)
            
        case .enableLanguageOption:
            guard let event = event as? MPChangeLanguageOptionCommandEvent else { return .commandFailed }
            guard didEnableLanguageOption(event.languageOption) else { return .noActionableNowPlayingItem }

        case .disableLanguageOption:
            guard let event = event as? MPChangeLanguageOptionCommandEvent else { return .commandFailed }
            guard didDisableLanguageOption(event.languageOption) else { return .noActionableNowPlayingItem }

        default:
            break
        }
        
        return .success
    }
    
    // MARK: Interruptions
    
    // Handle a session interruption.
    
    private func handleInterrupt(_ interruption: NowPlayableInterruption) {
        
        switch interruption {
            
        case .began:
            isInterrupted = true
            
        case .ended(let shouldPlay):
            isInterrupted = false
            
            switch playerState {
                
            case .stopped:
                break
                
            case .playing where shouldPlay:
                player.play()
                
            case .playing:
                playerState = .paused
                
            case .paused:
                break
            }
            
        case .failed(let error):
            print(error.localizedDescription)
            optOut()
        }
    }
 
    
    
    var defaultAllowsExternalPlayback: Bool { return true }
    
    var defaultRegisteredCommands: [NowPlayableCommand] {
        return [
//                .togglePausePlay,
                .play,
                .pause,
                .nextTrack,
                .previousTrack,
                .seekForward,
                .seekBackward
//                .skipBackward,
//                .skipForward,
//                .changePlaybackPosition,
//                .changePlaybackRate,
//                .enableLanguageOption,
//                .disableLanguageOption
        ]
    }
    
    var defaultDisabledCommands: [NowPlayableCommand] {
        
        // By default, no commands are disabled.
        
        return []
    }
    
    // The observer of audio session interruption notifications.
    
    private var interruptionObserver: NSObjectProtocol!
    
    // The handler to be invoked when an interruption begins or ends.
    
    
    func handleNowPlayableConfiguration(commands: [NowPlayableCommand],
                                        disabledCommands: [NowPlayableCommand]) throws {
        
        // Remember the interruption handler.
        
//        self.interruptionHandler = interruptionHandler
        
        // Use the default behavior for registering commands.
        
        try configureRemoteCommands(commands, disabledCommands: disabledCommands)
    }
    
    func handleNowPlayableSessionStart() throws {
        
        let audioSession = AVAudioSession.sharedInstance()
        
        // Observe interruptions to the audio session.
        
        interruptionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification,
                                                                      object: audioSession,
                                                                      queue: .main) {
            [unowned self] notification in
            self.handleAudioSessionInterruption(notification: notification)
        }
         
        try audioSession.setCategory(.playback, mode: .default)
        
         // Make the audio session active.
        
         try audioSession.setActive(true)
    }
    
    func handleNowPlayableSessionEnd() {
        
        // Stop observing interruptions to the audio session.
        
        interruptionObserver = nil
        
        // Make the audio session inactive.
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session, error: \(error)")
        }
    }
    
    func handleNowPlayableItemChange(metadata: NowPlayableStaticMetadata) {
        
        // Use the default behavior for setting player item metadata.
        
        setNowPlayingMetadata(metadata)
    }
    
    func handleNowPlayablePlaybackChange(playing: Bool, metadata: NowPlayableDynamicMetadata) {
        
        // Use the default behavior for setting playback information.
        
        setNowPlayingPlaybackInfo(metadata)
    }
    
    // Helper method to handle an audio session interruption notification.
    
    private func handleAudioSessionInterruption(notification: Notification) {
        
        // Retrieve the interruption type from the notification.
        
        guard let userInfo = notification.userInfo,
            let interruptionTypeUInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeUInt) else { return }
        
        // Begin or end an interruption.
        
        // Remember the interruption handler.
        
        switch interruptionType {
            
        case .began:
            
            // When an interruption begins, just invoke the handler.
            
//            interruptionHandler(.began)
            self.handleInterrupt(.began)
            
        case .ended:
            
            // When an interruption ends, determine whether playback should resume
            // automatically, and reactivate the audio session if necessary.
            
            do {
                
                try AVAudioSession.sharedInstance().setActive(true)
                
                var shouldResume = false
                
                if let optionsUInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
                    AVAudioSession.InterruptionOptions(rawValue: optionsUInt).contains(.shouldResume) {
                    shouldResume = true
                }
                
//                interruptionHandler(.ended(shouldResume))
                self.handleInterrupt(.ended(shouldResume))
            }
            
            // When the audio session cannot be resumed after an interruption,
            // invoke the handler with error information.
                
            catch {
//                interruptionHandler(.failed(error))
                self.handleInterrupt(.failed(error))
            }
            
        @unknown default:
            break
        }
    }
    
    
    // Install handlers for registered commands, and disable commands as necessary.
    
    func configureRemoteCommands(_ commands: [NowPlayableCommand],
                                 disabledCommands: [NowPlayableCommand]) throws {
        
        // Check that at least one command is being handled.
        
        guard commands.count > 1 else { throw NowPlayableError.noRegisteredCommands }
        
        // Configure each command.
        
        for command in NowPlayableCommand.allCases {
            
            // Remove any existing handler.
            
            command.removeHandler()
            
            // Add a handler if necessary.
            
            if commands.contains(command) {
                
                command.addHandler { (command, event) -> MPRemoteCommandHandlerStatus in
                    return self.handleCommand(command: command, event: event)
                }
            }
            
            // Disable the command if necessary.
            
            command.setDisabled(disabledCommands.contains(command))
        }
    }
    
    // Set per-track metadata. Implementations of `handleNowPlayableItemChange(metadata:)`
    // will typically invoke this method.
    
    func setNowPlayingMetadata(_ metadata: NowPlayableStaticMetadata) {
       
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        
        NSLog("%@", "**** Set track metadata: title \(metadata.title)")
        if #available(iOS 10.3, *) {
            nowPlayingInfo[MPNowPlayingInfoPropertyAssetURL] = metadata.assetURL
        } else {
            // Fallback on earlier versions
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = metadata.mediaType.rawValue
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = metadata.isLiveStream
        nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.artist
        
        if let url = metadata.artworkURL {
            KingfisherManager.shared.retrieveImage(with: url) { (result) in
                switch result {
                case let .success(image):
                    
                    let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 51, height: 51)) { (size) -> UIImage in
                        return image.image
                    }
                    
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
                    
                    break
                case let .failure(error):
                    assert(false, error.localizedDescription)
                }
            }
        }
        
        if let artwork = metadata.artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        nowPlayingInfo[MPMediaItemPropertyAlbumArtist] = metadata.albumArtist
        
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = metadata.albumTitle
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    // Set playback info. Implementations of `handleNowPlayablePlaybackChange(playing:rate:position:duration:)`
    // will typically invoke this method.
    
    func setNowPlayingPlaybackInfo(_ metadata: NowPlayableDynamicMetadata) {
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        NSLog("%@", "**** Set playback info: rate \(metadata.rate), position \(metadata.position), duration \(metadata.duration)")
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = metadata.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = metadata.position
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = metadata.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        nowPlayingInfo[MPNowPlayingInfoPropertyCurrentLanguageOptions] = metadata.currentLanguageOptions
        nowPlayingInfo[MPNowPlayingInfoPropertyAvailableLanguageOptions] = metadata.availableLanguageOptionGroups
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
}

// Reasons for invoking the audio session interruption handler (except macOS).

enum NowPlayableInterruption {
    case began, ended(Bool), failed(Error)
}

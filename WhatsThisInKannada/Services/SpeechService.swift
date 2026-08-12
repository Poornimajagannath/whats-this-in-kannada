import AVFoundation
import Foundation
import Speech

@MainActor
final class SpeechService: NSObject, ObservableObject {
    @Published var transcript = ""
    @Published var isListening = false
    @Published var authorizationStatus = SFSpeechRecognizer.authorizationStatus()
    @Published var errorMessage: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var hasInstalledTap = false

    var canListen: Bool {
        authorizationStatus == .authorized && recognizer?.isAvailable == true
    }

    func requestAuthorization() async -> Bool {
        #if os(macOS)
        errorMessage = "Voice input needs the iPhone app. Type a word here for this preview."
        return false
        #else
        let speechAllowed = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                Task { @MainActor in
                    self.authorizationStatus = status
                    continuation.resume(returning: status == .authorized)
                }
            }
        }

        guard speechAllowed else {
            errorMessage = "Speech recognition permission is off. Type a word instead."
            return false
        }

        let microphoneAllowed: Bool
        #if os(iOS)
        microphoneAllowed = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                continuation.resume(returning: allowed)
            }
        }
        #else
        microphoneAllowed = true
        #endif

        if !microphoneAllowed {
            errorMessage = "Microphone permission is off. Type a word instead."
        }

        return microphoneAllowed
        #endif
    }

    func startListening() async {
        errorMessage = nil
        transcript = ""

        guard await requestAuthorization() else { return }

        do {
            try startRecognition()
        } catch {
            errorMessage = error.localizedDescription
            cleanup(cancelTask: true)
        }
    }

    func stopListening() {
        cleanup(cancelTask: false)
    }

    func resetTranscript() {
        transcript = ""
        errorMessage = nil
    }

    private func startRecognition() throws {
        #if os(macOS)
        throw SpeechRecognitionError.unavailable
        #else
        cleanup(cancelTask: true)

        guard let recognizer, recognizer.isAvailable else {
            throw SpeechRecognitionError.unavailable
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if #available(iOS 13.0, *) {
            guard recognizer.supportsOnDeviceRecognition else {
                throw SpeechRecognitionError.onDeviceUnavailable
            }
            request.requiresOnDeviceRecognition = true
        }
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        guard recordingFormat.channelCount > 0 else {
            throw SpeechRecognitionError.microphoneUnavailable
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak request] buffer, _ in
            request?.append(buffer)
        }
        hasInstalledTap = true

        audioEngine.prepare()
        try audioEngine.start()
        isListening = true

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }

                if let result {
                    self.transcript = result.bestTranscription.formattedString
                    if result.isFinal {
                        self.cleanup(cancelTask: false)
                    }
                }

                if let error {
                    self.errorMessage = error.localizedDescription
                    self.cleanup(cancelTask: false)
                }
            }
        }
        #endif
    }

    private func cleanup(cancelTask: Bool) {
        if audioEngine.isRunning {
            audioEngine.stop()
        }

        if hasInstalledTap {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasInstalledTap = false
        }

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        if cancelTask {
            recognitionTask?.cancel()
        }
        recognitionTask = nil

        if isListening {
            isListening = false
        }
    }
}

enum SpeechRecognitionError: LocalizedError {
    case unavailable
    case microphoneUnavailable
    case onDeviceUnavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Speech recognition is not available right now. Type a word instead."
        case .microphoneUnavailable:
            return "The microphone is not available right now. Type a word instead."
        case .onDeviceUnavailable:
            return "On-device speech recognition is not available right now. Type a word instead."
        }
    }
}

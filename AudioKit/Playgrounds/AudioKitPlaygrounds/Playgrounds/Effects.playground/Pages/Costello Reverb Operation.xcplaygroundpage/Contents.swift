//: ## Costello Reverb Operation
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

let effect = AKOperationEffect(player) { player, _ in
    return player.reverberateWithCostello(
        feedback: AKOperation.sineWave(frequency: 0.1).scale(minimum: 0.5, maximum: 0.97),
        cutoffFrequency: 10_000)
}

AKManager.output = effect
try AKManager.start()
player.play()

//: User Interface
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Costello Reverb Operation")
        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

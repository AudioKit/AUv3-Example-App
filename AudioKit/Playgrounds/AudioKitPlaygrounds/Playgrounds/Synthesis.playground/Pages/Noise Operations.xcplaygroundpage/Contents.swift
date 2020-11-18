//: ## Noise Operations
//:
import AudioKitPlaygrounds
import AudioKit

let generator = AKOperationGenerator { _ in
    let white = AKOperation.whiteNoise()
    let pink = AKOperation.pinkNoise()

    let lfo = AKOperation.sineWave(frequency: 0.3)
    let balance = lfo.scale(minimum: 0, maximum: 1)
    let noise = mixer(white, pink, balance: balance)
    return noise.pan(lfo)
}

AKManager.output = generator
try AKManager.start()

generator.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

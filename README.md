# **AudioKit AUv3 Plugin & Stand-alone Example**

[![License](https://img.shields.io/cocoapods/l/AudioKit.svg?style=flat)](https://github.com/AudioKit/ROMPlayer/blob/master/LICENSE)
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitPro.svg?style=social)](http://twitter.com/AudioKitPro)

With this code, we hope to inspire the next generation of music app creators. 

![](https://i.imgur.com/4O1erRv.png)


This project was created with Grammy-winning professors *Kennard Garrett* & *Henny tha Bizness* at historic **Morehouse College's** music tech department. The **AudioKit** developement team was lead by [Jeff Cooper](http://github.com/eljeff) and [Matthew Fecher](https://twitter.com/analogMatthew).   

This repo is currently an Alpha WiP. Use at your own risk. 

![](https://i.imgur.com/LUXE0tP.png)

## Code Features

- Complete music app example, full source included
- Use as an iOS AUv3 plugin in hosts like GarageBand, AUM, BeatMaker 3, Cubasis 3, and more
- AU Parameter Automation
- Use as standalone app without a host
- Save/recall AU Params in host
- FX examples including Reverb, Tremolo, AutoPan, more...
- ADSR Envelope (Attack, Decay, Sustain, Release)
- Robust preset & bank system and UI
- MIDI input for notes, pitch bend, mod wheel
- On screen "Piano" keyboard that can be customized 
- MIDI Learn knobs
- Example code written entirely in Swift 5 & AudioKit 4

## Getting Started

![](https://i.imgur.com/k807YHC.png)

If you're new to [AudioKit](https://audiokit.io/), you can learn more and view getting started links: [here](https://audiokitpro.com/audiokit/).


**CocoaPods**  
This repo uses CocoaPods to easily add AudioKit to your project. 

Using the `Terminal` app in your mac, change directories to the folder that contains this project. The correct directory contains a file called `Podfile`

Run `pod install` from the command line. This will add AudioKit & AudioKit UI to project

Then open `AU Example.xcworkspace` in Xcode

## Requirements

![](https://i.imgur.com/Gc7kYYr.png)

- Mac or computer running Xcode 11 ([Free Download](https://itunes.apple.com/us/app/xcode/id497799835?mt=12))
- Knowledge of programming, specifically Swift & the iOS SDK

If you are new to iOS development, I highly recommend the [Ray Wenderlich](https://www.raywenderlich.com/) videos. There is also a great tutorial on basic synthesis with AudioKit  [here.](https://www.raywenderlich.com/145770/audiokit-tutorial-getting-started) 


## Included Sounds

![](https://i.imgur.com/EKwAq1Z.png)

This repo includes sounds [AnalogMatthew](https://twitter.com/analogMatthew) sampled from his TX81z hardware FM synthesizer for example purposes. Please use your own sounds in your app.

## Sound Manipulation

There are all kinds of filters, effects, and other audio manipulation classes included with AudioKit to get you started. You can browse the documentation [here](http://audiokit.io/docs/index.html). 

And, explore over [100+ playgrounds](http://audiokit.io/playgrounds/), created by the lovely & talented [Aure Prochazka](https://twitter.com/audiokitman). These byte size code playgrounds allow you to easily experiment with sound & code.

Additionally, these [docs and tips](https://developer.apple.com/library/content/technotes/tn2331/_index.html) will also prove valuable if you want to dive in at a deeper level than the AKSampler. 

## Making Graphics

![](https://i.imgur.com/uelpjUh.png)

IMPORTANT: You need to change the graphics to upload an app to the app store. Apple does not allow apps to use stock template graphics. Plus, you want your app to be part of the expression of your artistic vision. 

For example, if you were releasing a new music album, you would not want to use someone else's album artwork. You would want your own! 

Think of the GUI as an extension of your sample/music artform. It is a way to impress upon users your own style and give them a feel for your sonic personality. 

If graphic coding is not your cup of tea, the easiest way to make synth controls and knobs with code is to use [PaintCode](https://www.paintcodeapp.com/). I made almost all the graphic elements for this app with PaintCode. I've included the PaintCode source files for most of these UI elements [here](https://github.com/AudioKit/AudioKitGraphics). You can use them as a starting place to learn how to make controls. You can start with these files and change the color, sizes, etc. 

Luckily, I've already included the coding part of handling knobs in this repo. You only have to worry about the graphics. 

![knob in ib](https://i.imgflip.com/1svkul.gif)

Or, if you want to just completely use graphics instead of code - 

If you'd rather make knobs and controls with a graphic rendering software packgage that exports image frames (or a dedicated tool like KnobMan), here's some example code I wrote demonstrating using images to create knobs [here](https://github.com/analogcode/3D-Knobs).

![Knobs](http://audiokitpro.com/images/knob.gif) 

## Code Usage

You are free to:

(1) Use this app as a learning tool.  
(2) Re-skin this app (change the graphics), use your own sound samples, and upload to the app store.   
(3) Change the graphics, use your own sounds, and include this as part of a bigger app you are building.  
(4) Contribute code back to this project and improve this code for other people.

If you use any code, it would be great if you gave this project some credit or a mention. The more love this code receives, the better we can make it for everyone. And, give AudioKit a shout-out when you can! :) 

If you make an app with this code, please let us know! We think you're awesome, and would love to hear from you and/or feature your app.

IMPORTANT: You must change the graphics and sounds if you upload this to the app store.

## What Sounds Can You Use In Your App?

![](https://i.imgur.com/pOOAZeW.png)

Please get permission from the content creators before you use any free sounds on the internet. Even if sounds are available for free, it does not mean they are licensed to be used in an interactive app. 

The best thing to do is to create or sample your own custom instruments. Generally, you can sample an acoustic instrument or voice without worry. This includes things like Pianos, Flutes, Horns, Human Voice, Guitars, Hand Claps, Foot stomps, etc.

## Thanks and Credits

Huge thanks to all the beta testers and the folks on the AudioKit Slack Group, AudioBus Forum, & Facebook iOS Musician groups! Without your support and positive reviews, this would not be possible.

The **AudioKit** developement team was lead by [Jeff Cooper](http://github.com/eljeff) and [Matthew Fecher](https://twitter.com/analogMatthew).   

AudioKit Founder [Aure Prochazka](http://twitter.com/audiokitman)

AKSampler by
[Shane Dunne](http://github.com/getdunne)

This app would not be possible without all the AudioKit contributors:  
[AudioKit Contributions](https://github.com/AudioKit/AudioKit/graphs/contributors)

## Legal Notices

This is an open-source project intended to bring joy and music to people, and enlighten people on how to build custom instruments and iOS apps. All product names and images, trademarks and artists names are the property of their respective owners, which are in no way associated or affiliated with the creators of this app, including AudioKit, AudioKit Pro, LLC, and the other contributors. 

Product names and images are used solely for the purpose of identifying the specific products related to DAWs, iOS hosts, synthesizers, sampling, sound design, and music making. Use of these names and images does not imply any cooperation or endorsement. 

This Readme text does not constitute legal advice. We take no responsibility for any actions resulting from using this code. 

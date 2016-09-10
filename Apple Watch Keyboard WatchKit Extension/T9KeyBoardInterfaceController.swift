//
//  T9KeyBoardInterfaceController.swift
//  Phatch
//
//  Created by Tom de ruiter on 19/05/16.
//  Copyright © 2016 Tom de ruiter. All rights reserved.
//

import WatchKit
import Foundation

class T9KeyBoardInterfaceController: WKInterfaceController {
    
    var interval = 0.5
    var displayString: String = ""
    var T9Timer: NSTimer!
    var currentShiftState = 0
    var shiftTimer: NSTimer!
    
    var removedCharArray = [String]()
    
    @IBOutlet var resultLabel: WKInterfaceLabel!
    @IBOutlet var shiftButton: WKInterfaceButton!
    
    @IBOutlet var abcButton: WKInterfaceButton!
    @IBOutlet var defButton: WKInterfaceButton!
    @IBOutlet var ghiButton: WKInterfaceButton!
    @IBOutlet var jklButton: WKInterfaceButton!
    @IBOutlet var mnoButton: WKInterfaceButton!
    @IBOutlet var pqrsButton: WKInterfaceButton!
    @IBOutlet var tuvButton: WKInterfaceButton!
    @IBOutlet var wxyzButton: WKInterfaceButton!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func shiftButtonPressed() {
        switch currentShiftState {
        case 0:
            currentShiftState = 1
            shiftTimer = NSTimer.scheduledTimerWithTimeInterval(0.5,
                                                                target: self,
                                                                selector: #selector(T9KeyBoardInterfaceController.closeShiftTimer),
                                                                userInfo: nil,
                                                                repeats: false)
            break
        case 1:
            if shiftTimer != nil {
                currentShiftState = 2
            } else {
                currentShiftState = 0
            }
            break
        case 2:
            currentShiftState = 0
            break
        default:
            ()
        }
        setUIForShiftState()
    }
    
    func setUIForShiftState() {
        switch currentShiftState {
        case 0:
            shiftButton.setBackgroundImageNamed("unshift.png")
            abcButton.setTitle("abc")
            defButton.setTitle("def")
            ghiButton.setTitle("ghi")
            jklButton.setTitle("jkl")
            mnoButton.setTitle("mno")
            pqrsButton.setTitle("pqrs")
            tuvButton.setTitle("tuv")
            wxyzButton.setTitle("wxyz")
            break
        case 1, 2:
            if currentShiftState == 1 {
                shiftButton.setBackgroundImageNamed("shiftie.png")
            } else if currentShiftState == 2 {
                shiftButton.setBackgroundImageNamed("capslockButton.png")
            }
            abcButton.setTitle("ABC")
            defButton.setTitle("DEF")
            ghiButton.setTitle("GHI")
            jklButton.setTitle("JKL")
            mnoButton.setTitle("MNO")
            pqrsButton.setTitle("PQRS")
            tuvButton.setTitle("TUV")
            wxyzButton.setTitle("WXYZ")
            break
        default:
            ()
        }
    }
    
    @IBAction func punctationButtonPressed() {
        T9ButtonPressedWithOptions([".", ",", "?", "!", "-"])
    }
    
    @IBAction func abcButtonPressed() {
        T9ButtonPressedWithOptions(["a", "b", "c"])
    }
    
    @IBAction func defButtonPressed() {
        T9ButtonPressedWithOptions(["d", "e", "f"])
    }
    
    @IBAction func ghiButtonPressed() {
        T9ButtonPressedWithOptions(["g", "h", "i"])
    }
    
    @IBAction func jklButtonPressed() {
        T9ButtonPressedWithOptions(["j", "k", "l"])
    }
    
    @IBAction func mnoButtonPressed() {
        T9ButtonPressedWithOptions(["m", "n", "o"])
    }
    
    @IBAction func pqrsButtonPressed() {
        T9ButtonPressedWithOptions(["p", "q", "r", "s"])
    }
    
    @IBAction func tuvButtonPressed() {
        T9ButtonPressedWithOptions(["t", "u", "v"])
    }
    
    @IBAction func wxyzButtonPressed() {
        T9ButtonPressedWithOptions(["w", "x", "y", "z"])
    }
    
    @IBAction func spaceButton() {
        appendStringToMasterString(" ")
    }

    @IBAction func deleteButton() {
        if displayString.characters.count > 0 {
            let startIndex = displayString.endIndex.advancedBy(-1)
            
            displayString = displayString.substringToIndex(startIndex)
            print(removedCharArray)
            if removedCharArray.count > 0 {
                displayString = removedCharArray[removedCharArray.count - 1] + displayString
                removedCharArray.removeLast()
            }
            resultLabel.setText(displayString)
        }
    }
    
    func T9ButtonPressedWithOptions(options: [String]) {
        if T9Timer != nil {
            // timer is running, checking if last printed character is in the array
            closeT9Timer()
            if displayString.characters.count > 0 {
                let char = displayString[displayString.endIndex.predecessor()]
                if options.contains(String(char).capitalizedString) || options.contains(String(char).lowercaseString) {
                    var indexOfNextChar = options.indexOf(String(char))! + 1
                    if indexOfNextChar > options.count - 1 {
                        indexOfNextChar = 0
                    }
                    if currentShiftState == 1 {
                        currentShiftState = 0
                        changeLastCharForNewOne(options[indexOfNextChar].capitalizedString)
                    } else if currentShiftState == 2 {
                        changeLastCharForNewOne(options[indexOfNextChar].capitalizedString)
                    } else {
                        changeLastCharForNewOne(options[indexOfNextChar].lowercaseString)
                    }
                }
            }
            T9Timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(T9KeyBoardInterfaceController.closeT9Timer), userInfo: nil, repeats: false)
        } else {
            // timer isn't running so the first letter always have to be printed on the screen
            if currentShiftState == 1 {
                currentShiftState = 0
                appendStringToMasterString(options[0].capitalizedString)
            } else if currentShiftState == 2 {
                appendStringToMasterString(options[0].capitalizedString)
            } else {
                appendStringToMasterString(options[0].lowercaseString)
            }
            
            T9Timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(T9KeyBoardInterfaceController.closeT9Timer), userInfo: nil, repeats: false)
        }
        setUIForShiftState()
    }
    
    func closeT9Timer() {
        T9Timer.invalidate()
        T9Timer = nil
    }
    
    func closeShiftTimer() {
        shiftTimer.invalidate()
        shiftTimer = nil
    }
    
    func changeLastCharForNewOne(newChar: String) {
        displayString.replaceRange(displayString.startIndex.advancedBy(
            displayString.characters.count - 1)..<displayString.startIndex.advancedBy(displayString.characters.count), with: newChar)
        if displayString.characters.count > 20 {
            removedCharArray.append(String(displayString[0]))
            displayString.removeAtIndex(displayString.startIndex)
        }
        resultLabel.setText(displayString)
    }
    
    func appendStringToMasterString(character: String) {
        if displayString.characters.count <= 20 {
            
            // Add character to display
            
            WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Success)
            
            displayString = displayString + character
            resultLabel.setText(displayString)
            
        } else {
            
            // Remove first character & add this to the removedCharArray, add new one at the end.
            
            removedCharArray.append(String(displayString[0]))
            displayString = displayString + character
            displayString.removeAtIndex(displayString.startIndex)
            
            resultLabel.setText(displayString)
        }
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
}

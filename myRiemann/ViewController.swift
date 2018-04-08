//
//  ViewController.swift
//  myRiemann
//
//  Created by Hieu Nguyen on 4/2/18.
//  Copyright © 2018 HMdev. All rights reserved.
//

import UIKit
import MathParser

class ViewController: UIViewController, UITextFieldDelegate {
    
    // Standard Global variables
    var lowerBoundValue : Int = 0
    var upperBoundValue : Int = 0
    var sliderValue : Int = 0
    var finalizedInputString : String = ""

    
    // Logic Global variables
    var height : Double = 0.0
    var area : Double = 0.0
    var numberOfRectangles : Int = 0
    var deltaX : Double = 0.0
    
    // Error checking variables
    var maxDeltaInputCheck : String = ""
    var leftPressed : Bool = false
    var middlePressed : Bool = false
    var rightPressed : Bool = false
    var isLabelHidden : Bool = true
    var isVariableUsed : Bool = false
    var calculateState : Bool = false

    // Outlets
    @IBOutlet weak var upperBound: UITextField!
    @IBOutlet weak var lowerBound: UITextField!
    @IBOutlet weak var leftMethod: UIButton!
    @IBOutlet weak var middleMethod: UIButton!
    @IBOutlet weak var rightMethod: UIButton!
    @IBOutlet weak var minDeltaX: UITextField!
    @IBOutlet weak var maxDeltaX: UITextField!
    @IBOutlet weak var deltaXLabel: UILabel!
    @IBOutlet weak var sliderObject: UISlider!
    @IBOutlet weak var userfunctionInputLabel: UILabel!
    @IBOutlet weak var userFunctionInputTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var upperBoundLabel: UILabel!
    @IBOutlet weak var lowerBoundLabel: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    
    
    // First load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign delegate to this viewController
        upperBound.delegate = self
        lowerBound.delegate = self
        minDeltaX.delegate = self
        maxDeltaX.delegate = self
        userFunctionInputTextField.delegate = self
        
        // Set keyboard type to numberPad
        maxDeltaX.keyboardType = UIKeyboardType.numberPad
        minDeltaX.keyboardType = UIKeyboardType.numberPad
        
        // Set userFunctionInputLabel, upperBoundLabel, and lowerBoundLabel to hidden at load
        userfunctionInputLabel.isHidden = true
        
        // Assign unicode to deltaX label
        deltaXLabel.text = "\u{2206}x = 0"
        
        // Assigning default value of UISlider
        sliderObject.value = 1
        sliderObject.maximumValue = 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Return our deltaX("width) and set numberOfRectangles
    func calculateNumberOfRectanglesAndDeltaX() -> Double {
        let upperBoundValue = Double(upperBoundLabel.text!)
        let lowerBoundValue = Double(lowerBoundLabel.text!)
        var tempDeltaX : Double = 0.0
        
        if sliderValue != 0 {
            tempDeltaX = (upperBoundValue! - lowerBoundValue!) / Double(sliderValue)
            numberOfRectangles = sliderValue
        } else {
            makeError(whatTitle: "Division by zero", whatMessage: "Slider is set to 0.", whatAction: "Okay")
        }
        
        print("DeltaX Width: \(tempDeltaX)")
        print("Number of rectangles: \(numberOfRectangles)")

        return tempDeltaX
    }
    
    // User entered a f(x)
    @IBAction func enterButtonPressed(_ sender: UIButton) {
        resultsLabel.text = "0.0"
        
        // Change state of enterButton
        if isLabelHidden == true && userFunctionInputTextField.text != "", upperBound.text != "" && lowerBound.text != "" {
            // Hides UITextField and change enterButton status to Cancel
            userfunctionInputLabel.text = userFunctionInputTextField.text
            userFunctionInputTextField.isHidden = true
            userfunctionInputLabel.isHidden = false
            isLabelHidden = false
            enterButton.backgroundColor = UIColor.red
            enterButton.setTitle("Cancel", for: [])
            
            // Set our upperBound and lowerBound labels
            upperBoundLabel.text = upperBound.text
            lowerBoundLabel.text = lowerBound.text
            upperBound.isHidden = true
            lowerBound.isHidden = true
            upperBoundLabel.isHidden = false
            lowerBoundLabel.isHidden = false
            
            // set finalizedInputString to the return value of our function.  Consult convertUserInput
            // for documentation and usage.
            finalizedInputString = convertUserInput(UITextFieldInput: userfunctionInputLabel.text!)
            
            // Error checking
            calculateState = true
        }
        else if isLabelHidden == false && userFunctionInputTextField.text != "", upperBound.text != "" && lowerBound.text != "" {
            // Hides InputLabel and change enterButton status to Enter
            userFunctionInputTextField.isHidden = false
            userfunctionInputLabel.isHidden = true
            isLabelHidden = true
            enterButton.backgroundColor = UIColor.orange
            enterButton.setTitle("Enter", for: [])
            
            // Show upperBound and lowerBound UITextField again, and hide labels
            upperBound.isHidden = false
            lowerBound.isHidden = false
            upperBoundLabel.isHidden = true
            lowerBoundLabel.isHidden = true
            
            // Error checking
            finalizedInputString = ""
            isVariableUsed = false
            calculateState = true
        } else {
            makeError(whatTitle: "Incomplete", whatMessage: "Please have an input for upperbound, lowerbound, and f(x)dx", whatAction: "Okay")
            
            calculateState = false
        }
    }
    
    // Converts our user input to take in the format of Parser for variable usage and return new convertedString
    func convertUserInput(UITextFieldInput: String) -> String{
        // Place holder
        var convertedString : String = ""
        // Put string input to character array
        var array = Array(UITextFieldInput)
        // Temporary array
        var newArray = [Character]()
        
        // Loops through array looking for variable x
        for i in 0...(array.count - 1) {
            if array[i] == "x" {
                newArray.append("$")
                newArray.append(array[i])
                
                // Error check for variable used
                isVariableUsed = true
                
            } else {
                newArray.append(array[i])
            }
        }
        
        // Assign place holder to newly converted character array
        convertedString = String(newArray)

        return convertedString
    }
    
    // Alert user of error passed
    func makeError(whatTitle: String, whatMessage: String, whatAction: String){
        let alert = UIAlertController(title: whatTitle, message: whatMessage, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: whatAction, style: .default, handler: { (UIAlertAction) in
            
        })
        
        //Adds our action
        alert.addAction(restartAction)
        
        //present our alert object
        present(alert, animated: true, completion: nil)
    }
    
    // LeftRiemannSum calculation
    func calculateLeftRiemannSum(whatRange: Int) -> Double {
        var area : Double = 0.0
        var position : Double = 0.0
        
        for i in 0...whatRange - 1 {
            do {
                
                let value = try finalizedInputString.evaluate(["x": position])
                //print("position\(i): \(position)")
                //print("value\(i): \(value)")
                area += value * deltaX
                //print("Area: \(area)")
                
                position += deltaX
            } catch {
                print(error)
                makeError(whatTitle: "Invalid expression", whatMessage: "Please check input.", whatAction: "Okay")
            }
        }
        return area
    }
    
    // RightRiemannSum calculation
    func calculateRightRiemannSum(whatRange: Int) -> Double {
        var area : Double = 0.0
        var position : Double = Double(upperBoundLabel.text!)!
        
        for i in 0...whatRange - 1 {
            do {
                
                let value = try finalizedInputString.evaluate(["x": position])
                //print("position\(i): \(position)")
                //print("value\(i): \(value)")
                area += value * deltaX
                //print("Area: \(area)")
                
                position -= deltaX
            } catch {
                print(error)
                makeError(whatTitle: "Invalid expression", whatMessage: "Please check input.", whatAction: "Okay")
            }
        }
        return area
    }
    
    // MidRiemannSum calculation
    func calculateMidRiemannSum(whatRange: Int) -> Double {
//        let area1 = calculateLeftRiemannSum(whatRange: whatRange)
//        let area2 = calculateRightRiemannSum(whatRange: whatRange)
//
//        return ((area1 + area2)/2)
        
        var area : Double = 0.0
        var position : Double = deltaX / 2.0
        
        for i in 0...whatRange - 1 {
            do {
                
                let value = try finalizedInputString.evaluate(["x": position])
                print("\n--------\n")
                print("position\(i): \(position)")
                print("value\(i): \(value)")
                area += value * (deltaX)
                print("Area: \(area)")
                print("\n--------\n")
                
                position += deltaX
            } catch {
                print(error)
                makeError(whatTitle: "Invalid expression", whatMessage: "Please check input.", whatAction: "Okay")
            }
        }
        return area
    }
    
    // If a variable "x" is present in user input, then we use the special case, if not parse as standard evaluate()
    func calculateWithVariable(){
        if leftPressed {
            area = calculateLeftRiemannSum(whatRange: numberOfRectangles)
            resultsLabel.text = String(area)
        }
        else if rightPressed {
            area = calculateRightRiemannSum(whatRange: numberOfRectangles)
            resultsLabel.text = String(area)
        }
        else if middlePressed {
            area = calculateMidRiemannSum(whatRange: numberOfRectangles)
            resultsLabel.text = String(area)
        }
    }
    
    // Attempts to evaluate user input, if not throw an error + and alert to user to use proper notations.
    func calculateWithNoVariable(){
        do {
            let value = try userFunctionInputTextField.text?.evaluate()
        } catch {
            print(error)
            makeError(whatTitle: "Invalid expression", whatMessage: "Please check input.", whatAction: "Okay")
        }
    }
    
    // Calculate according to method pressed
    @IBAction func calculateApproximation(_ sender: UIButton) {
        if calculateState == true {
            if isVariableUsed == true {
                // Calculate rectangles
                deltaX = calculateNumberOfRectanglesAndDeltaX()
                
                // Do the math
                calculateWithVariable()
            } else {
                // Calculate rectangles
                deltaX = calculateNumberOfRectanglesAndDeltaX()
                
                // Do the math
                calculateWithNoVariable()
            }
        } else {
            makeError(whatTitle: "Incomplete", whatMessage: "Please have an input for upperbound, lowerbound, and f(x)dx", whatAction: "Okay")
        }
    }
    
    // If Graph is pressed, then perform segue to graph
    @IBAction func graphButtonPressed(_ sender: Any) {
        makeError(whatTitle: "Work in progress", whatMessage: "I was too tired...", whatAction: "Okay")
    }
    
    // Changing the button background color depending on selection
    func changeButtonColor(whichTag : Int){
        switch whichTag {
        case 0:
            leftMethod.backgroundColor = UIColor.blue
            middleMethod.backgroundColor = UIColor.darkGray
            rightMethod.backgroundColor = UIColor.darkGray
        case 1:
            leftMethod.backgroundColor = UIColor.darkGray
            middleMethod.backgroundColor = UIColor.blue
            rightMethod.backgroundColor = UIColor.darkGray
        case 2:
            leftMethod.backgroundColor = UIColor.darkGray
            middleMethod.backgroundColor = UIColor.darkGray
            rightMethod.backgroundColor = UIColor.blue
        default:
            print("...")
        }
    }
    
    // Changing button state
    func changeButtonState(whichTag : Int){
        switch whichTag {
        case 0:
            leftPressed = true
            middlePressed = false
            rightPressed = false
        case 1:
            leftPressed = false
            middlePressed = true
            rightPressed = false
        case 2:
            leftPressed = false
            middlePressed = false
            rightPressed = true
        default:
            print("...")
        }
    }
    
    // Which method depending on user selection
    @IBAction func methodSelected(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("left")
            changeButtonColor(whichTag: sender.tag)
            changeButtonState(whichTag: sender.tag)
        case 1:
            print("middle")
            changeButtonColor(whichTag: sender.tag)
            changeButtonState(whichTag: sender.tag)
        case 2:
            print("right")
            changeButtonColor(whichTag: sender.tag)
            changeButtonState(whichTag: sender.tag)
        default:
            print("...")
        }
    }
    
    // UISLIDER and label update
    @IBAction func sliderPressed(_ sender: UISlider) {
        // Weird error check
        if maxDeltaX.text != "" {
            maxDeltaInputCheck = maxDeltaX.text!
            sliderObject.maximumValue = Float(maxDeltaInputCheck)!
            
            sliderValue = Int(sender.value)
            
            deltaXLabel.text = "\u{2206}x = \(sliderValue)"
        }
    }
    
    
    // Dismisses if clicked outside of object
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    // Handling dismissal of keyboard depending on UITEXTFIELD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Becomes or resignFirstResponder according to textField
        switch textField {
        case upperBound:
            lowerBound.becomeFirstResponder()
        case lowerBound:
            textField.resignFirstResponder()
        case minDeltaX:
            textField.resignFirstResponder()
        case maxDeltaX:
            textField.resignFirstResponder()
        default:
            print("...")
        }
        
        return true
    }
    
    // Allows only numbers, x, +, -, /, *, (, ), and -
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"-0123456789x*+/e()$").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
}


//
//  Copyright 2018-2020 Picovoice Inc.
//  You may not use this file except in compliance with the license. A copy of the license is located in the "LICENSE"
//  file accompanying this source.
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var wakeWordPicker: UIPickerView!
    @IBOutlet weak var startButton: UIButton!

    let wakeWords = [
        "Alexa", "Americano", "Blueberry", "Bumblebee", "Computer", "Grapefruit", "Grasshopper", "Hey Google", "Hey Siri", "Jarvis", "Picovoice", "Porcupine", "Ok Google", "Terminator"
    ]
    var wakeWord = "Porcupine"

    var porcupineManager: PorcupineManager!
    var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()

        wakeWordPicker.delegate = self
        wakeWordPicker.dataSource = self
        
        let viewSize = view.frame.size
        let startButtonSize = CGSize(width: 120, height: 120)
        startButton.frame.size = startButtonSize
        startButton.frame.origin =
            CGPoint(x: (viewSize.width - startButtonSize.width) / 2, y: viewSize.height - (startButtonSize.height + 40))
        startButton.layer.cornerRadius = 0.5 * startButton.bounds.size.width
        startButton.clipsToBounds = true

        wakeWordPicker.frame.origin = CGPoint(x: 0, y: 40)
        wakeWordPicker.frame.size = CGSize(width: viewSize.width, height: viewSize.height - startButtonSize.height - 120)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return wakeWords.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return wakeWords[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        wakeWord = wakeWords[row]
    }

    @IBAction func toggleStartButton(_ sender: UIButton) {
        if !isRecording {
            let modelPath = Bundle.main.path(forResource: "porcupine_params", ofType: "pv")
            let keywordPath = Bundle.main.path(forResource: wakeWord.lowercased() + "_ios", ofType: "ppn")

            let originalColor = self.view.backgroundColor
            let keywordCallback: ((Int32) -> Void) = { keywordIndex in
                self.view.backgroundColor = UIColor.orange
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.view.backgroundColor = originalColor
                }
            }
            
            do {
                porcupineManager = try PorcupineManager(modelPath: modelPath!, keywordPath: keywordPath!, sensitivity: 0.7, onDetection: keywordCallback)
                try porcupineManager.start()
            } catch {
                let alert = UIAlertController(
                        title: "Alert",
                        message: "Something went wrong",
                        preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }

            wakeWordPicker.isUserInteractionEnabled = false
            isRecording = true
            startButton.setTitle("STOP", for: UIControl.State.normal)
        } else {
            porcupineManager.stop()

            wakeWordPicker.isUserInteractionEnabled = true
            isRecording = false
            startButton.setTitle("START", for: UIControl.State.normal)
        }
    }

}

//
//  ViewController.swift
//  WatsonTranslator
//
//  Created by Anthony Oliveri on 1/12/19.
//  Copyright © 2019 IBM. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var inputLanguagePicker: UIPickerView!
    @IBOutlet weak var outputLanguagePicker: UIPickerView!

    @IBAction func translateButtonHeld(_ sender: UIButton) {
        speechRecorder.startRecordingAudio() { [weak self] transcription, error in
            DispatchQueue.main.async {
                if let transcription = transcription {
                    self?.inputTextView.text = transcription
                }
                else if let error = error {
                    self?.inputTextView.text = "Error: \(error)"
                }
                self?.translate()
            }
        }
    }

    @IBAction func translateButtonLifted(_ sender: UIButton) {
        speechRecorder.stopRecordingAudio()
    }


    let speechRecorder = SpeechRecorder()
    let inputLanguagePickerController = LanguagePickerController()
    let outputLanguagePickerController = LanguagePickerController()


    override func viewDidLoad() {
        super.viewDidLoad()

        AVAudioSession.sharedInstance().requestRecordPermission { _ in }

        // It would be easiest for the recipient to view the translation on the device upside-down
        flipViewUpsideDown(outputTextView)
        configureLanguagePickers()
    }

    func flipViewUpsideDown(_ view: UIView) {
        UIView.animate(withDuration: 0.0) {
            view.transform = CGAffineTransform(rotationAngle: .pi)
        }
    }

    // Set the pickers' delegates and data sources, and set default selected values
    func configureLanguagePickers() {
        inputLanguagePicker.dataSource = inputLanguagePickerController
        inputLanguagePicker.delegate = inputLanguagePickerController
        outputLanguagePicker.dataSource = outputLanguagePickerController
        outputLanguagePicker.delegate = outputLanguagePickerController

        // Default the input to English for easier testing
        let rowForEnglish = Language.allCases.firstIndex(of: .english)!
        inputLanguagePicker.selectRow(rowForEnglish, inComponent: 0, animated: false)
        inputLanguagePickerController.pickerView(inputLanguagePicker, didSelectRow: rowForEnglish, inComponent: 0)
        // Default the output to Spanish for easier testing
        let rowForSpanish = Language.allCases.firstIndex(of: .spanish)!
        outputLanguagePicker.selectRow(rowForSpanish, inComponent: 0, animated: false)
        outputLanguagePickerController.pickerView(outputLanguagePicker, didSelectRow: rowForSpanish, inComponent: 0)
    }

    func translate() {
        guard
            let inputLanguage = self.inputLanguagePickerController.selectedLanguage,
            let outputLanguage = self.outputLanguagePickerController.selectedLanguage else {
                self.inputTextView.text = "Error: Invalid language selections"
                return
        }

        let translator = Translator(inputLanguage: inputLanguage, outputLanguage: outputLanguage)
        translator.translate(self.inputTextView.text) { [weak self] translation, error in
            DispatchQueue.main.async {
                if let translation = translation {
                    self?.outputTextView.text = translation
                }
                else if let error = error {
                    self?.inputTextView.text = "Error: \(error)"
                }
            }
        }
    }
}

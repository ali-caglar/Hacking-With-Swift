//
//  ViewController.swift
//  Insta Filter
//
//  Created by Ali ÇAĞLAR on 19.05.2023.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensitySlider: UISlider!
    var currentImage: UIImage!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Insta Filter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importImage))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }

    @IBAction func onChangeFilterButtonClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(createAlertActionForFilter("CIBumpDistortion"))
        alertController.addAction(createAlertActionForFilter("CIGaussianBlur"))
        alertController.addAction(createAlertActionForFilter("CIPixellate"))
        alertController.addAction(createAlertActionForFilter("CISepiaTone"))
        alertController.addAction(createAlertActionForFilter("CITwirlDistortion"))
        alertController.addAction(createAlertActionForFilter("CIUnsharpMask"))
        alertController.addAction(createAlertActionForFilter("CIVignette"))
        
        if let popOverController = alertController.popoverPresentationController {
            popOverController.sourceView = sender
            popOverController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true)
    }
    
    @IBAction func onSaveButtonClick(_ sender: Any) {
        guard let image = imageView.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func onIntensityValueChanged(_ sender: Any) {
        applyProcessing()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        currentImage = image
        initFiltering()
        dismiss(animated: true)
    }
    
    @objc private func importImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func createAlertActionForFilter(_ filterName: String) -> UIAlertAction {
        return UIAlertAction(title: filterName, style: .default, handler: setFilter)
    }
    
    private func setFilter(action: UIAlertAction) {
        if currentImage == nil { return }
        guard let filterName = action.title else { return }
        
        currentFilter = CIFilter(name: filterName)
        
        let initImage = CIImage(image: currentImage)
        currentFilter.setValue(initImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    private func initFiltering() {
        let initImage = CIImage(image: currentImage)
        currentFilter.setValue(initImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    private func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensitySlider.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensitySlider.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let processedImage = UIImage(cgImage: cgImage)
        imageView.image = processedImage
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        var alertTitle = ""
        var alertMessage = ""
        
        if let error = error {
            alertTitle = "Error"
            alertMessage = error.localizedDescription
        } else {
            alertTitle = "Saved"
            alertMessage = "Your photo has been saved to your photos."
        }
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}


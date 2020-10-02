//
//  DetailsViewController.swift
//  ArtList
//
//  Created by hks on 30.09.2020.
//

import UIKit
import PhotosUI
import CoreData

class DetailsViewController: UIViewController, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingUUID : UUID?
    var appDelegate : AppDelegate?
    var context : NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = appDelegate!.persistentContainer.viewContext
        
        if chosenPainting != "" {
            saveButton.isHidden = true
            getFilteredData()
        }
        
        //recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func selectImage(){
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print(results)
        dismiss(animated: true, completion: nil)
    }
    
    private func getFilteredData(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        let stringUUID = chosenPaintingUUID?.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", stringUUID!)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context!.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject]	{
                    
                    if let name = result.value(forKey: "name") as? String {
                        nameTextField.text = name
                    }
                    
                    if let artist = result.value(forKey: "artist") as? String {
                        artistTextField.text = artist
                    }
                    
                    if let year = result.value(forKey: "year") as? Int {
                        yearTextField.text = String(year)
                    }
                    
                    if let imageData = result.value(forKey: "image") as? Data {
                        imageView.image = UIImage(data: imageData)
                    }
                    
                }
            }
        } catch {
            print("error")
        }
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context!)
        newPainting.setValue(UUID(), forKey: "id")
        newPainting.setValue(artistTextField.text!, forKey: "artist")
        newPainting.setValue(nameTextField.text!, forKey: "name")
        
        if let year = Int(yearTextField.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        do {
            try context!.save()
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

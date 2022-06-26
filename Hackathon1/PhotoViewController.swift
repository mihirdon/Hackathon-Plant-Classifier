//
//  PhotoViewController.swift
//  Hackathon1
//
//  Created by Mihir Dontamsetti on 6/25/22.
//

import UIKit
import Foundation
import FirebaseDatabase

class PhotoViewController: UIViewController {
    var takenPhoto:UIImage?
    var imagePrediction:String?
    var entireText:String!
    var resultLabel: UILabel!
    var ref: DatabaseReference!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        //let availableImage = takenPhoto
        //imageView.image = availableImage
        
        super.viewDidLoad()
        readFromDatabase()
        self.imageView = UIImageView(image: takenPhoto)
        self.resultLabel = UILabel()
        resultLabel.backgroundColor = .black
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.systemFont(ofSize: 20)
        resultLabel.adjustsFontSizeToFitWidth = true
        resultLabel.minimumScaleFactor = 0.0001
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.text = imagePrediction
        placeLabel()
        self.view.addSubview(self.imageView)
        self.view.bringSubviewToFront(self.imageView)
        
    }
    
    func readFromDatabase() {
        
        ref = Database.database().reference()
        ref.child("Plants").child(imagePrediction!).getData(completion: {error, snapshot in
            guard error == nil else {
                print("Error" + error!.localizedDescription)
                return
            }

            
            let value = snapshot!.value as? NSDictionary
            let snippet = value?["snippet"] as? String ?? ""
            let title = value?["title"] as? String ?? ""
            let link = value?["link"] as? String ?? ""
            var invasiveSpecies : String!
            
            if snippet == "" {
                invasiveSpecies = "This species is not an invasive species"
            }
            else {
                invasiveSpecies = "This species is an invasive species"
            }
            var text : String!
            
            text = "The name of this species is \(self.imagePrediction!). "
            text += invasiveSpecies + ". "
            text += "'" + snippet + "' from Google'. \n"
            text += "'" + title + "' : \(link)"
            
            self.entireText = text
        })
        
    }
    
    func placeLabel() {
        self.view.addSubview(resultLabel)
        resultLabel.heightAnchor.constraint(equalToConstant: 170).isActive = true
        resultLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        resultLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        resultLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

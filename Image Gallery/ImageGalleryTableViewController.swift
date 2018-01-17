//
//  ImageGalleryTableViewController.swift
//  Image Gallery
//
//  Created by Kyle Cross on 1/16/18.
//  Copyright © 2018 Kyle Cross. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {
    
    // MARK: - Model
    
    var imageGalleries: [ImageGallery] = [ImageGallery(images: nil, name: "Untitled")]
    var emojiArtDocuments = ["untitled", "Untitled"]
    
    // MARK: - Target/Action

    @IBAction func addImageGallery(_ sender: UIBarButtonItem) {
        let galleryName = "Untitled"
        var uniqueNumber = 1
        
        while imageGalleries.contains(where: { $0.name == ("\(galleryName) \(uniqueNumber)") }) {
            uniqueNumber += 1
        }
        
        imageGalleries += [ImageGallery(images: nil, name: ("\(galleryName) \(uniqueNumber)"))]
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageGalleries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageGalleryCell", for: indexPath) as? ImageGalleryTableViewCell
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapResponse))
        tapGesture.numberOfTapsRequired = 2
        cell?.addGestureRecognizer(tapGesture)

        cell?.textField.text = imageGalleries[indexPath.row].name
        
        return cell!
    }
    
    @objc private func doubleTapResponse(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let textField = (sender.view as? ImageGalleryTableViewCell)?.textField {
                textField.isEnabled = true
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

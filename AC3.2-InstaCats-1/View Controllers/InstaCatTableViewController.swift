//
//  InstaCatTableViewController.swift
//  AC3.2-InstaCats-1
//
//  Created by Louis Tur on 10/10/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

struct InstaCat {
  // add necessary ivars and initilizations; check the tests to know what you should have
    let name: String
    let id: Int
    let instagramURL: URL
    var description: String {
        return "Nice to meet you, I'm \(name)"
    }
}

class InstaCatTableViewController: UITableViewController {
    
    internal let InstaCatTableViewCellIdentifier: String = "InstaCatCellIdentifier"
    internal let instaCatJSONFileName: String = "InstaCats.json"
    internal var instaCats: [InstaCat] = []

    override func viewDidLoad() {
        super.viewDidLoad()
      
        guard let instaCatsURL: URL = self.getResourceURL(from: instaCatJSONFileName),
            let instaCatData: Data = self.getData(from: instaCatsURL),
            let instaCatsAll: [InstaCat] = self.getInstaCats(from: instaCatData) else {
                return
        }
        
        self.instaCats = instaCatsAll
        
    }


        // MARK: - Data
    internal func getResourceURL(from fileName: String) -> URL? { //transforming the Instacats.json file name into an URL
        
        // 1. There are many ways of doing this parsing, we're going to practice String traversal, this is creating a character set
        guard let dotRange = fileName.rangeOfCharacter(from: CharacterSet.init(charactersIn: ".")) else {
            return nil
        }
        
        // 2. The upperbound of a range represents the position following the last position in the range, thus we can use it
        // to effectively "skip" the "." for the extension range
        let fileNameComponent: String = fileName.substring(to: dotRange.lowerBound) //lowerbound here is Instacats
        let fileExtenstionComponent: String = fileName.substring(from: dotRange.upperBound) //upperbound here is json
        
        // 3. Here is where Bundle.main comes into play, accessing bundle main directory and creating an url with InstaCats.json
        let fileURL: URL? = Bundle.main.url(forResource: fileNameComponent, withExtension: fileExtenstionComponent)
        
        return fileURL //returning the URL
    }
    
    internal func getData(from url: URL) -> Data? { //making file URL into a data type
        
        // 1. this is a simple handling of a function that can throw. In this case, the code makes for a very short function
        // but it can be much larger if we change how we want to handle errors.
        let fileData: Data? = try? Data(contentsOf: url)
        return fileData
    }
    
    internal func getInstaCats(from jsonData: Data) -> [InstaCat]? {
        
        var myCats = [InstaCat]()
        
        // 1. This time around we'll add a do-catch
        do {
            let instaCatJSONData: Any = try JSONSerialization.jsonObject(with: jsonData, options: []) //pass the json file and create an object of Any type
            
            if let catDict = instaCatJSONData as? [String: [[String:String]]] {
                if let cats = catDict["cats"] {
                    for cat in cats {
                        if let catID = cat["cat_id"], let catName = cat["name"], let catInstagram = cat["instagram"]{
                            
                            guard let id = Int(catID), let instagramURL = URL(string: catInstagram) else { return nil}
                            
                            let instaCat = InstaCat(name: catName, id: id, instagramURL: instagramURL)
                            myCats.append(instaCat)
                        }
                    }
                }
                return myCats
            }
            
            // 2. Cast from Any into a more suitable data structure and check for the "cats" key
            
            // 3. Check for keys "name", "cat_id", "instagram", making sure to cast values as needed along the way
            
            // 4. Return something
        }
        catch let error as NSError {
            // JSONSerialization doc specficially says an NSError is returned if JSONSerialization.jsonObject(with:options:) fails
            print("Error occurred while parsing data: \(error.localizedDescription)")
        }
        
        return  nil
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instaCats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstaCatCellIdentifier", for: indexPath)
        
        let cat = instaCats[indexPath.row]
        cell.textLabel?.text = cat.name
        cell.detailTextLabel?.text = cat.description
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         UIApplication.shared.open(instaCats[indexPath.row].instagramURL)
    }

}

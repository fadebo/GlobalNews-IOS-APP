//
//  ViewController.swift
//  GlobalNews
//
//  Created by Johnny Console on 2024-03-19.
//

import UIKit

class ViewController: UIViewController, URLSessionDelegate, XMLParserDelegate {
    
    var dataStore: Data?
    var titles = [String] ()
    var descriptions = [String] ()
    var elementText = ""
    var parsingItem = false
    var parsingTitle = false
    var parsingDescription = false
    
    @IBOutlet weak var textView: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "https://globalnews.ca/feed/"
        let url = NSURL(string: urlString)! as URL
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            self.dataStore = data
            self.parseXML()
            
            DispatchQueue.main.async {
                for i in 0...self.titles.count - 1 {
                    self.textView.text.append("Article \(i + 1)\nTitle: \(self.titles[i])\nDescription: \(self.descriptions[i])\n\n")
                }
            }
        })
        task.resume()
    }
    
    func parseXML() {
        let parser = XMLParser(data: self.dataStore!)
        parser.delegate = self
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "item" {
            parsingItem = true
        }
        else if parsingItem == true && elementName == "title" {
            parsingTitle = true
        }
        else if parsingItem == true && elementName == "description" {
            parsingDescription = true
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if parsingTitle || parsingDescription {
            elementText.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if parsingTitle {
            titles.append(elementText)
            parsingTitle = false
            elementText = ""
        }
        else if parsingDescription {
            descriptions.append(elementText)
            parsingDescription = false
            elementText = ""
        }
        else if elementName == "item" {
            parsingItem = false
            elementText = ""
        }
    }

}


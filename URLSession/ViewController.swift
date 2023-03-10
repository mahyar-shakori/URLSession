//
//  ViewController.swift
//  URLSession
//
//  Created by Mahyar on 1/16/23.
//

import UIKit

typealias Parameters = [String: String]

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getSimpleBtn(_ sender: Any) {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")
        let session = URLSession.shared
        session.dataTask(with: url!) { (data, response, error)  in
            if let response = response {
                print (response)
            }
            if let data = data {
                print (data)
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            print (json)
            
        }.resume()
        
    }
    
    @IBAction func postSimpleBtn(_ sender: Any) {
        
        let params = ["username": "taghi", "tweet": "Hello"]
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        let httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.httpBody = httpBody
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error)  in
            if let response = response {
                print (response)
            }
            if let data = data {
                print (data)
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            print (json)
            
        }.resume()
        
    }
    
    @IBAction func getMultiPartBtn(_ sender: Any) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        var request = URLRequest(url: url)
        
        let boundary = generateBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let dataBody = createDataBody(withParameters: nil, media: nil, boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    @IBAction func postMultiPartBtn(_ sender: Any) {
        
        let parameters = ["name": "MyTestFile123321",
                          "description": "My tutorial test file for MPFD uploads"]
        
        guard let mediaImage = Media(withImage: #imageLiteral(resourceName: "test"), forKey: "image") else { return }
        
        guard let url = URL(string: "https://api.imgur.com/3/image") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = generateBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Client-ID f65203f7020dddc", forHTTPHeaderField: "Authorization")
        
        let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            }.resume()
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {

        let lineBreak = "\r\n"
        var body = Data()

        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }

        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }

        body.append("--\(boundary)--\(lineBreak)")

        return body
    }

}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

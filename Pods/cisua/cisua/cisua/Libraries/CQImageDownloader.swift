
//
//  CQImageDownloader.swift
//
//
//  Created by COMQUAS
//

import UIKit

internal extension UIImageView {
    
    @discardableResult
    func setCQImage(_ url: String, placeholder: UIImage? = nil, progress: ((_ value: Float) -> Void)? = nil, completion: ((_ image: UIImage?, _ success: Bool) -> ())? = nil) -> CQImageDownloader {
        
        if placeholder != nil {
            self.image = placeholder
        }
        
        let downloader = CQImageDownloader()
        
        downloader.downloadImageDataWithProgress(url, progress: progress) { (data,success) in
            if let data = data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.image = image
                }
                completion?(image, success)
            } else {
                completion?(nil, false)
            }
        }
        
        return downloader
        
    }
    
}

internal class CQImageDownloader: NSObject {
    
    var downloadTask: URLSessionDownloadTask?
    var downloadImageURL: String = ""
    var backgroundSession: URLSession!
    
    var completionCallback: ((Data?, Bool) -> Void)?
    var progressCallback: ((Float) -> Void)?
    
    @discardableResult
    func downloadImageDataWithProgress(_ url: String, progress:((Float) -> ())? = nil, completion:((Data?,Bool) -> ())? = nil) -> URLSessionDownloadTask? {
        
        if url == "" {
            if let callback = completion {
                callback(nil, false)
            }
            return nil
        }
        
        if let cacheData = CQImageDownloader.getImageDataWithURL(url) {
            if let callback = completion {
                callback(cacheData, true)
            }
            return nil
        }
        
        self.progressCallback = progress
        self.completionCallback = completion
        
        if let imgURL = URL(string:url) {
            
            let identifier = "\(CQImageDownloader.urlHash(url))\(self.randomString(length: 4))"
            
            let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: identifier)
            
            self.backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
            
            self.downloadImageURL = url
            self.downloadTask = self.backgroundSession.downloadTask(with: imgURL)
            self.downloadTask?.resume()
        }
        
        return self.downloadTask
    }
    
    func deleteCacheImage(_ url: String) {
        if let path = CQImageDownloader.imagePathAtURL(url) {
            let fManager = FileManager.default
            if fManager.fileExists(atPath: path) {
                do {
                    try fManager.removeItem(atPath: path)
                } catch { }
            }
        }
    }
    
    internal class func saveImage(_ data: Data, name: String) {
        if let file = self.imagePathAtURL(name) {
            do {
                try data.write(to: URL(fileURLWithPath: file), options: .atomicWrite)
            } catch { }
        }
    }
    
    internal class func getImageDataWithURL(_ url: String) -> Data? {
        if let filepath = self.imagePathAtURL(url) {
            if let imageData = try? Data(contentsOf: URL(fileURLWithPath: filepath)) {
                return imageData
            }
        }
        return nil
    }
    
    internal class func urlHash(_ url: String) -> String {
        return "\(url.utf8.md5)"
    }
    
    internal class func imagePathAtURL(_ url: String) -> String? {
        let cacheFolder = Utils.cachesDirectory()
        var directory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: cacheFolder, isDirectory: &directory) {
            if !directory.boolValue {
                do {
                    try FileManager.default.createDirectory(atPath: cacheFolder, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    return nil
                }
            }
        }
        
        let imageURL = self.urlHash(url)
        var ext = "jpg"
        if (url as NSString).pathExtension.count > 0 {
            ext = (url as NSString).pathExtension
        }
        
        return (cacheFolder as NSString).appendingPathComponent("\(imageURL).\(ext)")
    }
    
    internal class func clearAllTheCachedImages() {
        do {
            try FileManager.default.removeItem(atPath: Utils.cachesDirectory())
        } catch { }
    }
    
    func cancelDownload() {
        self.downloadTask?.cancel()
    }
    
    func pauseDownload() {
        self.downloadTask?.suspend()
    }
    
    func resumeDownload() {
        self.downloadTask?.resume()
    }
    
    fileprivate func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
}

extension CQImageDownloader: URLSessionDelegate {
    
    internal func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> (Void)) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
}

extension CQImageDownloader: URLSessionDownloadDelegate {
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.completionCallback?(nil,false)
    }
    
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        if let file = CQImageDownloader.imagePathAtURL(self.downloadImageURL) {
            
            let destURL = URL(fileURLWithPath: file)
            
            if let callback = self.completionCallback {
                do {
                    let d = try Data(contentsOf: location)
                    if d.count <= 0 {
                        callback(nil,false)
                        return
                    }
                    
                    try d.write(to: destURL, options: .atomic)
                    
                    if let data = CQImageDownloader.getImageDataWithURL(self.downloadImageURL) {
                        callback(data, true)
                        return
                    }
                } catch { }
                callback(nil, false)
            }
        }
        
    }
    
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let callback = self.progressCallback {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            callback(progress)
        }
    }
}

//
//  ECFileManager.swift
//  ECleaner
//
//  Created by alexey sorochan on 20.11.2021.
//

import Foundation

enum FileFormat {
    case vcf
    case csv
	case mp4
    
    var fileExtension: String {
        switch self {
            case .vcf:
                return "vcf"
            case .csv:
                return "csv"
			case .mp4:
				return "mp4"
        }
    }
}

enum AppDirectories: String {
    case temp = "temp"
    case contactsArcive = "contactsArcive"
	case compressedVideo  = "compressedVideo"
	
    var name: String {
        return self.rawValue
    }
}

enum CreateTempDirectoryError: Error, LocalizedError {
	case fileExisted
	
	public var errorDescription: String? {
		switch self {
			case .fileExisted:
				return "File existed"
		}
	}
}

 
class ECFileManager {
    
    private let fileManager: FileManager
    
    init() {
        fileManager = FileManager.default
    }
    
    public func getDirectoryURL(_ directory: AppDirectories) -> URL? {
        
        let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let directory = path.appendingPathComponent(directory.rawValue)
        var isDirectory: ObjCBool = true
        
        if !fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory) {
            do {
                try fileManager.createDirectory(atPath: directory.path, withIntermediateDirectories: false, attributes: nil)
                return directory
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        return directory
    }
    
    public func isFileExiest(at path: URL) -> Bool {
        return fileManager.fileExists(atPath: path.path)
    }
    
    
    public func deletefile(at path: URL) {
        do {
            try fileManager.removeItem(at: path)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func isFileExist(at directory: AppDirectories, with name: String) -> Bool {
        
        if let path = self.getDirectoryURL(directory) {
            do {
                let folderContent = try fileManager.contentsOfDirectory(atPath: path.path)
                return folderContent.contains(name)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        return false
    }
    
    func createDirectory(_ directory: AppDirectories) {
        
        let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryPath = path.appendingPathComponent(directory.rawValue).path
        
        var isDirectory: ObjCBool = true
        
        if !fileManager.fileExists(atPath: directoryPath, isDirectory: &isDirectory) {
            do {
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func direcotryIsEmpty(_ directory: AppDirectories) -> Bool {
            
        guard let directoryURL = getDirectoryURL(directory) else { return false}
        
        do {
            let folderContent = try fileManager.contentsOfDirectory(atPath: directoryURL.path)
            return folderContent.isEmpty
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
    }
    
    func deleteAllFiles(at directory: AppDirectories, completion: @escaping () -> Void) {
        
        let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderPath = path.appendingPathComponent(directory.rawValue).path
        
        do {
            let folderContent = try fileManager.contentsOfDirectory(atPath: folderPath)
            folderContent.forEach { urlStringPath in
                if let url = URL(string: urlStringPath) {
                    try? self.fileManager.removeItem(at: url)
                }
            }
            completion()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func copyFileTemoDdirectory(from url: URL, with name: String, file extensionFormat: FileFormat,_ completion: @escaping (URL?) -> Void) {

        if let tempURL = getDirectoryURL(.temp)?.appendingPathComponent(name).appendingPathExtension(extensionFormat.fileExtension) {
            do {
                
                if fileManager.fileExists(atPath: tempURL.path) {
                    try fileManager.removeItem(at: tempURL)
                }
                try fileManager.copyItem(at: url, to: tempURL)
                completion(tempURL)
            } catch {
                completion(nil)
                debugPrint(error.localizedDescription)
            }
        }
    }
}

extension ECFileManager {
	
	public func getTempDirectory(with pathComponent: String = ProcessInfo.processInfo.globallyUniqueString) throws -> URL {
		
		var tempURL: URL
		
		let caacheURL = fileManager.temporaryDirectory
		
		if let url = try? fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: caacheURL, create: true) {
			tempURL = url
		} else {
			tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
		}
		tempURL.appendPathComponent(pathComponent)
		
		if !fileManager.fileExists(atPath: tempURL.absoluteString) {
			do {
				try fileManager.createDirectory(at: tempURL, withIntermediateDirectories: true, attributes: nil)
				return tempURL
			} catch {
				throw error
			}
		} else {
			return tempURL
		}
	}
	
	public func removeAllCompressedVideos(from paths: [URL]) {
		
		paths.forEach {
			try? fileManager.removeItem(at: $0)
		}
	}
}

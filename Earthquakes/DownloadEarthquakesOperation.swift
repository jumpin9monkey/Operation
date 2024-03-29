/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains the code to download the feed of recent earthquakes.
*/

import Foundation

class DownloadEarthquakesOperation: GroupOperation {
    // MARK: Properties

    let cacheFile: URL
    
    // MARK: Initialization
    
    /// - parameter cacheFile: The file `URL` to which the earthquake feed will be downloaded.
    init(cacheFile: URL) {
        self.cacheFile = cacheFile
        super.init(operations: [])
        name = "Download Earthquakes"
        
        /*
            Since this server is out of our control and does not offer a secure
            communication channel, we'll use the http version of the URL and have
            added "earthquake.usgs.gov" to the "NSExceptionDomains" value in the
            app's Info.plist file. When you communicate with your own servers,
            or when the services you use offer secure communication options, you
            should always prefer to use https.
        */
        let url = URL(string: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson")!
        let task = URLSession.shared.downloadTask(with: url) { url, response, error in
            self.downloadFinished(url, response: response as? HTTPURLResponse, error: OperationErrorCode.temp)
        }
        
        let taskOperation = URLSessionTaskOperation(task: task)
        
        let reachabilityCondition = ReachabilityCondition(host: url)
        taskOperation.addCondition(reachabilityCondition)

        let networkObserver = NetworkObserver()
        taskOperation.addObserver(networkObserver)
        
        addOperation(operation: taskOperation)
    }
    
    func downloadFinished(_ url: URL?, response: HTTPURLResponse?, error: OperationErrorCode?) {
        if let localURL = url {
            do {
                /*
                    If we already have a file at this location, just delete it.
                    Also, swallow the error, because we don't really care about it.
                */
                try FileManager.default.removeItem(at: cacheFile)
                
            }
            catch { }
            
            
            
            
            do {
                try FileManager.default.moveItem(at: localURL, to: cacheFile)
            }
            catch{
                //   let error as Error 
                aggregateError(OperationErrorCode.temp)
            }
            
        }
        else if let error = error {
            aggregateError(error)
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
    }
}

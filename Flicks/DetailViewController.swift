//
//  DetailViewController.swift
//  Flicks
//
//  Created by Diana Fisher on 9/12/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    
    var movie: NSDictionary!  // implicitly unwrapped
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // set the content size of our scroll view
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
                
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let releaseDate = movie["release_date"] as? String ?? "Not Provided"
        releaseDateLabel.text = "Released: \(releaseDate)"
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        
        // run sizeTofit on our label now that we have set the text
        overviewLabel.sizeToFit()
        
        // load the poster image
        loadPosterImage(for: posterImageView, movie: movie)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Utils
    
    // Loads low resolution poster image first and then switches to the high resolution version
    func loadPosterImage(for imageView: UIImageView, movie: NSDictionary) {
        
        let lowResBaseUrl = "http://image.tmdb.org/t/p/w154"
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            // posterPath is now guaranteed to not be nil.
            
            let lowResUrl = NSURL(string: lowResBaseUrl + posterPath)
            let highResUrl = NSURL(string: baseUrl + posterPath)
            
            let highResImageRequest = NSURLRequest(url: highResUrl! as URL)
            let lowResImageRequest = NSURLRequest(url: lowResUrl! as URL)
            
            imageView.setImageWith(
                lowResImageRequest as URLRequest,
                placeholderImage: nil,
                success: { (lowResImageRequest, lowResImageResponse, lowResImage) in
                    
                    imageView.alpha = 0
                    imageView.image = lowResImage
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        imageView.alpha = 1.0
                    }, completion: { (success) in
                        imageView.setImageWith(
                            highResImageRequest as URLRequest,
                            placeholderImage: lowResImage,
                            success: { (highResImageRequest, highResImageResponse, highResImage) in
                                imageView.image = highResImage
                                
                        }, failure: { (request, response, error) in
                            print(error)
                        })
                    })
                    
            }, failure: { (request, response, error) in
                // log error message
                print("Error: \(error)")
            })
            
            
        }
        
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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
    
    var movie: NSDictionary!  // implicitly unwrapped
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set the content size of our scroll view
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        print(movie)
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        // use if let to safely set the posterImageView image from the poster_path
        if let posterPath = movie["poster_path"] as? String {
            // posterPath is now guaranteed to not be nil.
            let imageUrl = NSURL(string: baseUrl + posterPath)
            posterImageView.setImageWith(imageUrl! as URL)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

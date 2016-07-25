//
//  ImageViewController.swift
//  Apartments Croatia
//
//  Created by Ivan Kodrnja on 25/07/16.
//  Copyright © 2016 Ivan Kodrnja. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    // image array that will store urls for all apartment images
    var imageArray = [String]()
    
    // show the required image, will be set from the previous VC
    var currentImageIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // cache downloaded images and use Auk image slideshow library from https://github.com/evgenyneu/Auk
        Moa.settings.cache.requestCachePolicy = .ReturnCacheDataElseLoad
        for imageUrl in imageArray {
            scrollView.auk.settings.placeholderImage = UIImage(named: "LoadingImage")
            scrollView.auk.settings.errorImage = UIImage(named: "NoImage")
            scrollView.auk.settings.contentMode = .ScaleAspectFit
            scrollView.auk.show(url: imageUrl)
        }
        
        scrollView.auk.scrollTo(currentImageIndex!, animated: true)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

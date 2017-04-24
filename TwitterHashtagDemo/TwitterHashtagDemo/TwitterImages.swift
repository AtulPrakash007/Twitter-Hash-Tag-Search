//
//  TwitterImages.swift
//  TwitterHashtagDemo
//
//  Created by Mac on 4/24/17.
//  Copyright © 2017 AtulPrakash. All rights reserved.
//

import Foundation

import Foundation

struct TwitterImages {
    var imageURL: Data?
    
    init (imageUrl: String) {
        let imgURL = URL(string: imageUrl)
        imageURL = try? Data(contentsOf: imgURL!)
    }
}

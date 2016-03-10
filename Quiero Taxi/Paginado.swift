//
//  Paginado.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 11/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import Foundation
import UIKit

class Paginado: UIViewController {
    
    var pageIndex : Int = 0
    var imageFile : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageName = imageFile
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 5, y: 0, width: view.frame.width , height: view.frame.height - 50)
        view.addSubview(imageView)
        
        //view.backgroundColor = UIColor(patternImage: UIImage(named: imageFile)!)
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
}

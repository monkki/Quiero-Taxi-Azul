//
//  WebLigasInteresViewController.swift
//  Quiero Taxi
//
//  Created by Doctor on 11/30/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit

class WebLigasInteresViewController: UIViewController {
    
    
    @IBOutlet var webView: UIWebView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Boton Atras
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        // Imagen encabezado
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "quieroTaxiEncabezado")
        imageView.image = image
        navigationItem.titleView = imageView
        navigationItem.titleView!.sizeThatFits(CGSize(width: 220, height: 65))
        
        let urlString = NSURL(string: "http://tarifario.taxistascancun.com/Interactive/")
        let urlRequest = NSURLRequest(URL: urlString!)
        
        webView.loadRequest(urlRequest)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

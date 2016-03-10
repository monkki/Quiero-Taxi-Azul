//
//  LigasDeInteresViewController.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 09/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit

class LigasDeInteresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var tabla: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        tabla.delegate = self
        
        // Imagen encabezado
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "quieroTaxiEncabezado")
        imageView.image = image
        navigationItem.titleView = imageView
        navigationItem.titleView!.sizeThatFits(CGSize(width: 220, height: 65))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tabla.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = "Tarifario"
        cell.detailTextLabel?.text = "Quiero Taxi"
        cell.imageView?.image = UIImage(named: "logo_start")
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tabla.deselectRowAtIndexPath(indexPath, animated: true)
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

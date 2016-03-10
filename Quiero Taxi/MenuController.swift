//
//  MenuController.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 09/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {
    
    // DATOS USUARIO
    var nombre = NSUserDefaults.standardUserDefaults().objectForKey("nombre") as! String
    var apellidos = NSUserDefaults.standardUserDefaults().objectForKey("apellidos") as! String
    var email = NSUserDefaults.standardUserDefaults().objectForKey("email") as! String
    
    @IBOutlet var fotoUsuario: UIImageView!
    @IBOutlet var nombreLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

       self.tableView.backgroundColor = UIColor(red:0.27, green:0.44, blue:0.58, alpha:1.0)
       self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //Imagen circular
        fotoUsuario.layer.borderWidth = 2.0
        fotoUsuario.layer.masksToBounds = false
        fotoUsuario.layer.borderColor = UIColor.whiteColor().CGColor
        fotoUsuario.layer.cornerRadius = fotoUsuario.frame.size.width/2
        fotoUsuario.clipsToBounds = true
    
        if let imagenUsuario = imagenFacebook {
            fotoUsuario.image = imagenUsuario
        }
        
        nombreLabel.text = nombre + " " + apellidos
        emailLabel.text = email
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

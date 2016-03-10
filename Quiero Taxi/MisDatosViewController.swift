//
//  MisDatosViewController.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 09/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit

class MisDatosViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var fotoUsuario: UIImageView!
    
    @IBOutlet var nombreTextfield: UITextField!
    @IBOutlet var celularTextfield: UITextField!
    @IBOutlet var correoElectronicoTextfield: UITextField!
    
    
    @IBAction func cerrarSesionBoton(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("nombre")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("apellidos")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("email")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("ubicacion")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("telefono")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("estatusPedido")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("statusDeServicio")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("idServicio")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("latitudGuardada")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("longitudGuardada")
        //NSUserDefaults.standardUserDefaults().removeObjectForKey("id_carro")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("categoria")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("idFacebookDefaults")
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        self.performSegueWithIdentifier("logoutSegue", sender: self)
    }
    
    @IBAction func regresarBoton(sender: AnyObject) {
        
        self.performSegueWithIdentifier("principalSegue", sender: self)
    }
    

    @IBOutlet var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        nombreTextfield.delegate = self
        celularTextfield.delegate = self
        correoElectronicoTextfield.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "gris")!)
        
        let nombre = NSUserDefaults.standardUserDefaults().objectForKey("nombre") as? String
        let apellidos = NSUserDefaults.standardUserDefaults().objectForKey("apellidos") as? String
        let celular = NSUserDefaults.standardUserDefaults().objectForKey("telefono") as? String
        let email = NSUserDefaults.standardUserDefaults().objectForKey("email") as? String
        
        nombreTextfield.text = nombre! + " "  + apellidos!
        celularTextfield.text = celular
        correoElectronicoTextfield.text = email
        
        // Imagen encabezado
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "quieroTaxiEncabezado")
        imageView.image = image
        navigationItem.titleView = imageView
        navigationItem.titleView!.sizeThatFits(CGSize(width: 220, height: 65))
        
        //Imagen circular
        fotoUsuario.layer.borderWidth = 2.0
        fotoUsuario.layer.masksToBounds = false
        fotoUsuario.layer.borderColor = UIColor.whiteColor().CGColor
        fotoUsuario.layer.cornerRadius = fotoUsuario.frame.size.width/2
        fotoUsuario.clipsToBounds = true
        
        
        //Imagen Usuario
        if let imagenUsuario = imagenFacebook {
            fotoUsuario.image = imagenUsuario
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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

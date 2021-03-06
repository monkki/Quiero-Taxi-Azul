//
//  RegistrarViewController.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 09/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit

class RegistrarViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var nombreTextfield: UITextField!
    @IBOutlet var apellidoTextfield: UITextField!
    @IBOutlet var celularTextfield: UITextField!
    @IBOutlet var correoTextfield: UITextField!
    @IBOutlet var contraseñaTextfield: UITextField!
    
    var nombre = ""
    var apellido = ""
    var celular = ""
    var correo = ""
    var contraseña = ""
    var codigoPais = ""
    
    
    @IBAction func aceptarBoton(sender: AnyObject) {
        
        nombre = nombreTextfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        apellido = apellidoTextfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        celular = celularTextfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        correo = correoTextfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        contraseña = contraseñaTextfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        
        
        if(nombre == "" || apellido == "" || celular == "" || correo == "" || contraseña == ""){
            
            mostraMSJ("Favor de completar los datos!")
            
        } else if(celular.characters.count != 10) {
            
            mostraMSJ("Favor de escribir un número de 10 dígitos!")
            
        } else if(!isValidEmail(correo)) {
            
            mostraMSJ("Favor de escribir un correo válido!")
            
        } else if(contraseña.characters.count < 7) {
            
            mostraMSJ("Favor de escribir una contraseña con más de 7 dígitos!")
            
        } else {
            
            registrarUsuario();
            
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nombreTextfield.delegate = self
        apellidoTextfield.delegate = self
        celularTextfield.delegate = self
        correoTextfield.delegate = self
        contraseñaTextfield.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "gris")!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func registrarUsuario(){
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        
        nombre = nombre.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        apellido = apellido.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        celular = celular.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        correo = correo.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        contraseña = contraseña.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlObj = Urls();
        let urlString = urlObj.getUrlRegistro(nombre, apellidos: apellido, celular: celular, constraseña: contraseña, correo: correo)
        
        let url = NSURL(string: urlString)!
        let urlSession = NSURLSession.sharedSession()
        
        let jsonQuery = urlSession.dataTaskWithURL(url, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            
            do {
                
                if let data = data {
                
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSMutableArray
                
                    print(jsonResult[0])
                
                    let aux_exito: String! = jsonResult[0]["success"] as! NSString as String
                
                    if(aux_exito == "1"){
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                            if #available(iOS 8.0, *) {
                                let alertView_usuario_incorrecto = UIAlertController(title: "Registro!", message: "Se ha registrado con éxito!", preferredStyle: .Alert)
                                    alertView_usuario_incorrecto.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                                        self.performSegueWithIdentifier("loginSegue", sender: self)
                            
                                        self.nombreTextfield.text = ""
                                        self.apellidoTextfield.text = ""
                                        self.celularTextfield.text = ""
                                        self.correoTextfield.text = ""
                                        self.contraseñaTextfield.text = ""
                            
                                    }))
                        
                                self.presentViewController(alertView_usuario_incorrecto, animated: true, completion: nil)
                        
                            } else {
                            
                                let alertView_usuario_incorrecto = UIAlertView(title: "Registro", message: "Se ha registrado con éxito!", delegate: self, cancelButtonTitle: "OK")
                            
                                alertView_usuario_incorrecto.show()
                            
                                self.performSegueWithIdentifier("loginSegue", sender: self)
                            
                                self.nombreTextfield.text = ""
                                self.apellidoTextfield.text = ""
                                self.celularTextfield.text = ""
                                self.correoTextfield.text = ""
                                self.contraseñaTextfield.text = ""
                            
                            }

                        })
                    
                    } else if(aux_exito == "2") {
                    
                        self.mostraMSJ("Ya existe un Usuario con ese número de teléfono!")
                    
                    } else {
                    
                        dispatch_async(dispatch_get_main_queue(), {
                        
                            self.mostraMSJ("Error al dar de alta el Usuario, vuélvalo a intentar nuevamente.")
                        
                        })
                    
                    }
                }
                
            } catch {
                
                print(error)
                
            }
            
        })
        
        jsonQuery.resume()
        
    }
    
    
    func mostraMSJ(msj: String){
        
        if #available(iOS 8.0, *) {
            
        let alertView_usuario_incorrecto = UIAlertController(title: "Quiero Taxi", message: msj, preferredStyle: .Alert)
        
            alertView_usuario_incorrecto.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                self.presentViewController(alertView_usuario_incorrecto, animated: false, completion: nil)
            }))
            
        } else {
            
           let alertView_usuario_incorrecto = UIAlertView(title: "Quiero Taxi", message: msj, delegate: self, cancelButtonTitle: "OK")
            alertView_usuario_incorrecto.show()
            
        }
        
        
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
}

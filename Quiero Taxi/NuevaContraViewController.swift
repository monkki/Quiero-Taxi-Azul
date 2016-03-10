//
//  NuevaContraViewController.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 11/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit

class NuevaContraViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var ingresaContra: UITextField!
    @IBOutlet var confirmaContra: UITextField!
    
    var codigo = ""
    var telefono = ""
    var contraseña = ""
    var urlObj = Urls()
    
    
    @IBAction func actualizarBoton(sender: AnyObject) {
    
        if(validarDatos()==true){
            
            cambiarContraseña(telefono,codigo: codigo,contraseña: contraseña)
            
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        ingresaContra.delegate = self
        confirmaContra.delegate = self
        
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
    
    func cambiarContraseña(var telefono: String, var codigo: String, var contraseña: String){
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        
        telefono = telefono.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        codigo = codigo.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        contraseña = contraseña.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlString = urlObj.getUrlPassCambiar(telefono, codigo: codigo, contraseña: contraseña)
        
        let url = NSURL(string: urlString)!
        let urlSession = NSURLSession.sharedSession()
        
        let jsonQuery = urlSession.dataTaskWithURL(url, completionHandler: { data, response, error -> Void in
            
            if (error != nil) {
                
                print(error!.localizedDescription)
                
            }
            
            do {
                
                if let data = data {
                
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSMutableArray
                
                    if (error != nil) {
                    
                        print("JSON Error \(error!.localizedDescription)")
                    
                    }
                
                    print(jsonResult[0])
                
                    let success: String! = jsonResult[0]["success"] as! NSString as String
                
                    if(success == "1"){
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        
                            if #available(iOS 8.0, *) {
                            
                                let alertView_usuario_incorrecto = UIAlertController(title: "Actualización!", message: "La contraseña se ha cambiado con exito.", preferredStyle: .Alert)
                                alertView_usuario_incorrecto.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                                    self.performSegueWithIdentifier("homeSegue", sender: self)
                                
                                }))
                                self.presentViewController(alertView_usuario_incorrecto, animated: true, completion: nil)
                            
                            } else {
                            
                                let alertView_usuario_incorrecto = UIAlertView(title: "Actualización!", message: "La contraseña se ha cambiado con exito.", delegate: self, cancelButtonTitle: "OK")
                            
                                alertView_usuario_incorrecto.show()
                            
                                self.performSegueWithIdentifier("homeSegue", sender: self)
                            }
                        
                        
                        })
                    
                    } else if(success == "2") {
                    
                        self.mostrarMensaje("Ha ocurrido un error!", titulo: "Alerta!")
                    
                    }
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.mostraMSJ("Por favor compruebe su conexion a Internet");
                    })
                    
                }
                
            } catch {
                
                print(error)
                
            }
            
        })

        jsonQuery.resume()
        
    }
    
    func mostrarMensaje(mensaje: String, titulo: String){
        
        if #available(iOS 8.0, *) {
            let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
            alerta.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alerta, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            let alerta = UIAlertView(title: titulo, message: mensaje, delegate: self, cancelButtonTitle: "Aceptar")
            alerta.show()
        }
        
        
    }
    
    func validarDatos()-> Bool{
        
        let contra1 = ingresaContra.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let contra2 = confirmaContra.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if(contra1 == "" || contra2 == ""){
            
            self.mostrarMensaje("Favor de completar los datos",titulo: "Alerta!")
            return false
            
        } else if(contra1.characters.count < 7 || contra2.characters.count < 7){
            
            self.mostrarMensaje("La contraseña debe ser mayor a 7 dígitos",titulo: "Alerta!")
            return false
            
        } else if(contra1 != contra2){
            
            self.mostrarMensaje("La contraseñas no coinciden",titulo: "Alerta!")
            return false
            
        } else {
            
            contraseña = contra1;
            return true
        }
    }

    func mostraMSJ(msj: String){
        if #available(iOS 8.0, *) {
            let alertView_usuario_incorrecto = UIAlertController(title: "Quiero Taxi", message: msj, preferredStyle: .Alert)
            alertView_usuario_incorrecto.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction) -> Void in
            }))
            self.presentViewController(alertView_usuario_incorrecto, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            let alertView_usuario_incorrecto = UIAlertView(title: "Quiero Taxi", message: msj, delegate: self, cancelButtonTitle: "OK")
            alertView_usuario_incorrecto.show()
        }
        
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

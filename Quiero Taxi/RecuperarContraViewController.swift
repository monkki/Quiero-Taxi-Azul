//
//  RecuperarContraViewController.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 10/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit

class RecuperarContraViewController: UIViewController {

    @IBOutlet var vistaRecuperarContra: UIView!
    @IBOutlet var codigoTextfielf: UITextField!
    
    @IBOutlet var tituloLabel: UILabel!
    
    var codigo=""
    var telefono = ""
    var origern = ""
    let urlObj = Urls()
    
    @IBAction func volverASolicitarBoton(sender: AnyObject) {
        
        getCodigo(telefono,tipo: "sms",mensaje: "Pronto recibirás una mensaje con la clave de verificación.")
        
    }
    
    @IBAction func escucharCodigoBoton(sender: AnyObject) {
        
        getCodigo(telefono,tipo: "call",mensaje: "Pronto recibirás una llamada con la clave de verificación.")
        
    }
    
    @IBAction func aceptarBoton(sender: AnyObject) {
        
        if(validarDatos() == true){
            if(origern == "forgetPass"){
                validarCodigo(telefono, codigo: codigo)
            }else if(origern == "validateUser"){
                validarUsuario(telefono, codigo: codigo)
            }
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vistaRecuperarContra.layer.cornerRadius = 5.0
        
        let scale = CGAffineTransformMakeScale(0.0, 0.0)
        let translate = CGAffineTransformMakeTranslation(0, 500)
        vistaRecuperarContra.transform = CGAffineTransformConcat(scale, translate)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        print(telefono)
        
        if(origern == "validateUser") {
            
            tituloLabel.text = "Validación de Usuario"
            
        } else if(origern == "forgotPass") {
            
            tituloLabel.text = "Recuperar Contraseña"
            
        }

        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        UIView.animateWithDuration(0.8, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.vistaRecuperarContra.transform = CGAffineTransformConcat(scale, translate)
            
            }, completion: nil)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func getCodigo(var telefono: String, tipo: String, mensaje: String){
        
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        telefono = telefono.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlString = urlObj.getUrlPassCodigo(telefono, tipo: tipo)
        
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
                            self.mostrarMensaje(mensaje,titulo: "Clave de verificación");
                        
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
            
            let alerta = UIAlertView(title: titulo, message: mensaje, delegate: self, cancelButtonTitle: "Aceptar")
            alerta.show()
            
        }
        
        
    }
    
    func validarCodigo(var telefono: String, codigo: String){
        
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        telefono = telefono.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlString = urlObj.getUrlPassValidarCod(telefono, codigo: codigo)
        
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
                            
                                let alertView_usuario_incorrecto = UIAlertController(title: "Exito!", message: "Clave de verificación Correcta", preferredStyle: .Alert)
                                alertView_usuario_incorrecto.addAction(UIAlertAction(title: "ok", style: .Default, handler: { (alertAction) -> Void in
                                    self.performSegueWithIdentifier("nuevaContraSegue", sender: self)
                                
                                }))
                            
                                self.presentViewController(alertView_usuario_incorrecto, animated: true, completion: nil)
                            
                            } else {
                            
                                let alertView_usuario_incorrecto = UIAlertView(title: "Exito!", message: "Clave de verificación Correcta", delegate: self, cancelButtonTitle: "OK")
                            
                                alertView_usuario_incorrecto.show()
                            
                                self.performSegueWithIdentifier("nuevaContraSegue", sender: self)
                            }
                        
                        })
                    
                    } else if(success == "2") {
                    
                        self.mostrarMensaje("Clave de verificación Incrorrecta", titulo: "Alerta!")
                    
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
    
    func validarUsuario(var telefono: String, codigo: String){
        
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        telefono = telefono.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlString = urlObj.getUrlValidarUser(telefono, codigo: codigo)
        
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
                
                    if(success == "1") {
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                            if #available(iOS 8.0, *) {
                            
                                let alertView_usuario_incorrecto = UIAlertController(title: "Exito!", message: "Su Usuario ha sido validado", preferredStyle: .Alert)
                                alertView_usuario_incorrecto.addAction(UIAlertAction(title: "ok", style: .Default, handler: { (alertAction) -> Void in
                                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                                    let nombre: String! = jsonResult[0]["nombre"] as! NSString as String
                                    let apellidos: String! = jsonResult[0]["apellidos"] as! NSString as String
                                    let email: String! = jsonResult[0]["email"] as! NSString as String
                                    let ubicacion: String! = jsonResult[0]["ubicacion"] as! NSString as String
                                
                                    prefs.setObject(true, forKey: "login")
                                    prefs.setObject(nombre, forKey: "nombre")
                                    prefs.setObject(telefono, forKey: "telefono")
                                    prefs.setObject(apellidos, forKey: "apellidos")
                                    prefs.setObject(email, forKey: "email")
                                    prefs.setObject(ubicacion, forKey: "ubicacion")
                                    prefs.synchronize();
                                
                                
                                    self.performSegueWithIdentifier("home1Segue", sender: self)
                                
                                }))
                            
                                self.presentViewController(alertView_usuario_incorrecto, animated: true, completion: nil)
                            
                            } else {
                            
                                let alertView_usuario_incorrecto = UIAlertView(title: "Exito!", message: "Su Usuario ha sido validado", delegate: self, cancelButtonTitle: "OK")
                            
                                alertView_usuario_incorrecto.show()
                            
                                let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                                let nombre: String! = jsonResult[0]["nombre"] as! NSString as String
                                let apellidos: String! = jsonResult[0]["apellidos"] as! NSString as String
                                let email: String! = jsonResult[0]["email"] as! NSString as String
                                let ubicacion: String! = jsonResult[0]["ubicacion"] as! NSString as String
                            
                                prefs.setObject(true, forKey: "login")
                                prefs.setObject(nombre, forKey: "nombre")
                                prefs.setObject(telefono, forKey: "telefono")
                                prefs.setObject(apellidos, forKey: "apellidos")
                                prefs.setObject(email, forKey: "email")
                                prefs.setObject(ubicacion, forKey: "ubicacion")
                                prefs.synchronize();
                            
                            
                                self.performSegueWithIdentifier("home1Segue", sender: self)
                            }
                        
                        
                        })
                    
                    } else if(success == "2") {
                    
                        self.mostrarMensaje("Clave de verificación Incrorrecta", titulo: "Alerta!")
                    
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
    
    func validarDatos()->Bool{
        
        codigo = codigoTextfielf.text!
        
        if(codigo == ""){
            
            self.mostrarMensaje("Favor de escribir el código!", titulo: "Alerta!")
            return false
            
        } else if(codigo.characters.count != 4) {
            
            self.mostrarMensaje("Favor de escribir un código de 4 dígitos", titulo: "Alerta!")
            return false
            
        } else {
            
            return true
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "nuevaContraSegue"){
            
            let destinoVC = segue.destinationViewController as? NuevaContraViewController
            destinoVC?.codigo = codigo
            destinoVC?.telefono = telefono
            
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

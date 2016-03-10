//
//  ViewController.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 09/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit

var imagenFacebook: UIImage!

class ViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet var botonLoginFacebook: FBSDKLoginButton!
    @IBOutlet var splashImagen: UIImageView!
    @IBOutlet var celularTextfield: UITextField!
    @IBOutlet var contraseñaTextfield: UITextField!
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet var vistaRecuperarContraseña: UIView!
    @IBOutlet var ingresaTuNumero: UITextField!
    var numero = ""
    var origen = ""
    
    // DATOS RECIBIDOS DE FACEBOOK
    var nombreCompletoFacebook: String!
    var nombreFacebook: String!
    var apellidoFacebook: String!
    var emailFacebook: String!
    var idFacebook: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        celularTextfield.delegate = self
        contraseñaTextfield.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        let scale = CGAffineTransformMakeScale(0.0, 0.0)
        let translate = CGAffineTransformMakeTranslation(0, 500)
        vistaRecuperarContraseña.transform = CGAffineTransformConcat(scale, translate)
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "OcultarSplash", userInfo: nil, repeats: false)
        

    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        // CHECA SI EL USUARIO YA ESTA REGISTRADO
        if let nombre = NSUserDefaults.standardUserDefaults().objectForKey("nombre") as? String {
            
            self.performSegueWithIdentifier("loginSegue", sender: self)
            print(nombre)
            
        } else {
            
            
            let idFace = NSUserDefaults.standardUserDefaults().objectForKey("idFacebookDefaults") as? String
            
            
            if (idFace != nil) {
                // User is already logged in, do work such as go to next view controller.
                // Or Show Logout Button
                // botonLoginFacebook.frame = CGRectMake(self.view.frame.size.width/2 - 140, 470, 280, 35)
                botonLoginFacebook.readPermissions = ["public_profile", "email", "user_friends"]
                botonLoginFacebook.delegate = self
                self.returnUserData()
                
                
            } else {
                
                botonLoginFacebook.readPermissions = ["public_profile", "email", "user_friends"]
                botonLoginFacebook.delegate = self
                
            }
            
        }
        
    }

    
    func OcultarSplash() {
        
        let scale = CGAffineTransformMakeScale(0.0, 0.0)
        let translate = CGAffineTransformMakeTranslation(0, 500)
        splashImagen.transform = CGAffineTransformConcat(scale, translate)
        
    }
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue) {
    
        NSUserDefaults.standardUserDefaults().removeObjectForKey("idFacebookDefaults")
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
    }
    
    
    
    ////// Botones de Vista - Recuperar contraseña
    
    @IBAction func cancelarRecuperarContraseña(sender: AnyObject) {
        
        let scale = CGAffineTransformMakeScale(0.0, 0.0)
        let translate = CGAffineTransformMakeTranslation(0, 500)
        vistaRecuperarContraseña.transform = CGAffineTransformConcat(scale, translate)
        
    }
    
    
    @IBAction func aceptarRecuperarContraseña(sender: AnyObject) {
        
        numero = ingresaTuNumero.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if(numero == "") {
            
            mostrarMensaje("Ingresa tu número telefónico",titulo: "Alerta!")
            
        } else if(numero.characters.count != 10) {
            
            mostrarMensaje("Ingresa un número telefónico de 10 dígitos",titulo: "Alerta!")
            
        } else {
            
            validarTelefono(numero)
            
        }
        
    }
    
    
    // MUESTRA MENSAJE AL USUARIO
    
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
    
    
    // FUNCION LOGIN
    
    func loginWS(var auxTelefono: String, var auxContraseña: String){
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var device_token:String
        if (prefs.objectForKey("DEVICETOKEN") != nil){
            
            device_token = prefs.objectForKey("DEVICETOKEN") as! String
            
        } else {
            
            device_token = ""
            
        }
        
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        
        auxTelefono = auxTelefono.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        auxContraseña = auxContraseña.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlObj = Urls();
        let urlString = urlObj.getUrlLogin(auxTelefono, contraseña: auxContraseña, token: device_token)
        
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
                
                    let aux_exito: String! = jsonResult[0]["success"] as! NSString as String
                
                    if(aux_exito == "1"){
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                            let nombre: String! = jsonResult[0]["nombre"] as! NSString as String
                            let apellidos: String! = jsonResult[0]["apellidos"] as! NSString as String
                            let email: String! = jsonResult[0]["email"] as! NSString as String
                            let ubicacion: String! = jsonResult[0]["ubicacion"] as! NSString as String
                        
                            prefs.setObject(nombre, forKey: "nombre")
                            prefs.setObject(apellidos, forKey: "apellidos")
                            prefs.setObject(email, forKey: "email")
                            prefs.setObject(ubicacion, forKey: "ubicacion")
                            prefs.setObject(auxTelefono, forKey: "telefono")
                            prefs.setObject("-1", forKey: "statusDeServicio")
                            prefs.setObject(false, forKey: "estatusPedido")
                            prefs.setObject("0", forKey: "idServicio")
                            prefs.setObject("0", forKey: "latitudGuardada")
                            prefs.setObject("0", forKey: "longitudGuardada")
                            prefs.setObject("0", forKey: "id_carro")
                            prefs.setObject("0", forKey: "categoria")
                            
                            prefs.synchronize();
                        
                            self.performSegueWithIdentifier("loginSegue", sender: self)
                        })
                    
                    } else if(aux_exito == "2") {
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.origen = "validateUser";
                            self.numero = auxTelefono;
                            self.performSegueWithIdentifier("recuperarContraseñaSegue", sender: self)
                        })
                    
                    } else {
                    
                        dispatch_async(dispatch_get_main_queue(), {
                        
                            if #available(iOS 8.0, *) {
                            
                                let alertView_usuario_incorrecto = UIAlertController(title: "Error al iniciar sesion", message: "Lo sentimos su usuario no esta activo.", preferredStyle: .Alert)
                                alertView_usuario_incorrecto.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction) -> Void in
                                    print("")
                                }))
                                self.presentViewController(alertView_usuario_incorrecto, animated: true, completion: nil)
                            
                            } else {
                            
                                let alertView_usuario_incorrecto = UIAlertView(title: "Error al iniciar sesion", message: "Lo sentimos su usuario no esta activo.", delegate: self, cancelButtonTitle: "OK")
                            
                                alertView_usuario_incorrecto.show()
                            }
                        
                        })
                    }
                }
                
            } catch {
                
                print(error)
                
            }
            
        })
        // 5
        jsonQuery.resume()
        
    }
    
    
    // VALIDAR TELEFONO
    
    func validarTelefono(var telefono: String){
        
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        telefono = telefono.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlObj = Urls();
        let urlString = urlObj.getUrlPassCodigo(telefono,tipo: "sms")
        
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
                            self.ingresaTuNumero.text = ""
                            let scale = CGAffineTransformMakeScale(0.0, 0.0)
                            let translate = CGAffineTransformMakeTranslation(0, 500)
                            self.vistaRecuperarContraseña.transform = CGAffineTransformConcat(scale, translate)
                        
                            if #available(iOS 8.0, *) {
                            
                                let alertView_usuario_incorrecto = UIAlertController(title: "Recuperar Contraseña", message: "Pronto recibirás una clave para reestablecer tu contraseña.", preferredStyle: .Alert)
                                alertView_usuario_incorrecto.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction) -> Void in
                                    self.origen = "forgetPass";
                                    self.performSegueWithIdentifier("recuperarContraseñaSegue", sender: self)
                                
                                }))
                                self.presentViewController(alertView_usuario_incorrecto, animated: true, completion: nil)

                            } else {
                            
                                let alertView_usuario_incorrecto = UIAlertView(title: "Recuperar Contraseña", message: "Pronto recibirás una clave para reestablecer tu contraseña.", delegate: self, cancelButtonTitle: "OK")
                            
                                alertView_usuario_incorrecto.show()
                            
                                self.origen = "forgetPass";
                                self.performSegueWithIdentifier("recuperarContraseñaSegue", sender: self)
                            }
                        
                        })
                    
                    } else if(success == "2"){
                    
                        self.mostrarMensaje("No existe Usuario con ese Teléfono", titulo: "Alerta!")
                    
                    } else {
                    
                        dispatch_async(dispatch_get_main_queue(), {
                        
                            if #available(iOS 8.0, *) {
                            
                                let alertView_usuario_incorrecto = UIAlertController(title: "Error al iniciar sesion", message: "Celular y/o Contraseña.", preferredStyle: .Alert)
                                alertView_usuario_incorrecto.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction) -> Void in
                                    print("")
                                }))
                                self.presentViewController(alertView_usuario_incorrecto, animated: true, completion: nil)

                            
                            } else {
                            
                                let alertView_usuario_incorrecto = UIAlertView(title: "Error al iniciar sesion", message: "Celular y/o Contraseña.", delegate: self, cancelButtonTitle: "OK")
                            
                                alertView_usuario_incorrecto.show()
                            }
                        
                        })
                    }
                }
                
            } catch {
                
                print(error)
                
            }
            
        })
        // 5
        jsonQuery.resume()
        
    }
    
    
    // FUNCION LOGIN FACEBOOK
    
    func loginFacebook(var id: String){
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        id = id.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlObj = Urls();
        let urlString = urlObj.loginFace(id)
        
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
                            
                            let nombre: String! = jsonResult[0]["nombre"] as! NSString as String
                            let apellidos: String! = jsonResult[0]["apellidos"] as! NSString as String
                            let email: String! = jsonResult[0]["email"] as! NSString as String
                            let ubicacion: String! = jsonResult[0]["ubicacion"] as! NSString as String
                            let telefono: String! = jsonResult[0]["telefono"] as! NSString as String
                            
                            prefs.setObject(nombre, forKey: "nombre")
                            prefs.setObject(apellidos, forKey: "apellidos")
                            prefs.setObject(email, forKey: "email")
                            prefs.setObject(ubicacion, forKey: "ubicacion")
                            prefs.setObject(telefono, forKey: "telefono")
                            prefs.setObject("-1", forKey: "statusDeServicio")
                            prefs.setObject(false, forKey: "estatusPedido")
                            prefs.setObject("0", forKey: "idServicio")
                            prefs.setObject("0", forKey: "latitudGuardada")
                            prefs.setObject("0", forKey: "longitudGuardada")
                            prefs.setObject("0", forKey: "id_carro")
                            prefs.setObject("0", forKey: "categoria")
    
                            prefs.synchronize();
                            
                            self.performSegueWithIdentifier("loginSegue", sender: self)
                            
                        })
                        
                    } else if(success == "2"){
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.performSegueWithIdentifier("registrarFacebookSegue", sender: self)
                            
                        })
                        
                    } else if (success == "0") {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            if #available(iOS 8.0, *) {
                                
                                let alertView_usuario_incorrecto = UIAlertController(title: "Error al registrar", message: "Intente de nuevo mas tarde", preferredStyle: .Alert)
                                alertView_usuario_incorrecto.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction) -> Void in
                                    print("")
                                }))
                                self.presentViewController(alertView_usuario_incorrecto, animated: true, completion: nil)
                                
                                
                            } else {
                                
                                let alertView_usuario_incorrecto = UIAlertView(title: "Error al registrar", message: "Intente de nuevo mas tarde", delegate: self, cancelButtonTitle: "OK")
                                
                                alertView_usuario_incorrecto.show()
                            }
                            
                        })
                    }
                }
                
            } catch {
                
                print(error)
                
            }
            
        })
        // 5
        jsonQuery.resume()
        
    }

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "recuperarContraseñaSegue"){
            let destinoVC = segue.destinationViewController as? RecuperarContraViewController
            destinoVC?.telefono = numero;
            destinoVC?.origern = origen;
            
        } else if (segue.identifier == "registrarFacebookSegue") {
            let destinoVC = segue.destinationViewController as? RegistrarFacebookViewController
            destinoVC?.nombreCompletoFacebook = nombreCompletoFacebook
            destinoVC?.nombreFacebook = nombreFacebook
            destinoVC?.apellidoFacebook = apellidoFacebook
            destinoVC?.emailFacebook = emailFacebook
            destinoVC?.idFacebook = idFacebook
            destinoVC?.imagenFacebook = imagenFacebook
        }
    }
 
    // METODOS DE FACEBOOK
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil) {
            // Process error
        
        } else if result.isCancelled {
            // Handle cancellations
            
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") {
                // Do work
            
            }
            
            self.returnUserData()
            
        }
        
    }
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Usuario ha salido")
    }
    
    
    func returnUserData() {
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name, picture.type(large), first_name, last_name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
                
            } else {
                
                //Obtener nombre de facebook
                print("Usuario es: \(result)")
                if let userName : NSString = result.valueForKey("name") as? NSString {
                    self.nombreCompletoFacebook = userName as String
                    print("Nombre de usuario es : \(userName)")
                }
                
                //Obtener id de facebook
                if let id : NSString = result.valueForKey("id") as? NSString {
                    self.idFacebook = id as String
                    NSUserDefaults.standardUserDefaults().setObject(self.idFacebook, forKey: "idFacebookDefaults")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    print("id de usuario es: \(id)")
                    
                }
                
                //Obtener email de facebook
                if let userEmail : NSString = result.valueForKey("email") as? NSString {
                    self.emailFacebook = userEmail as String
                    print("Email de usuario es: \(userEmail)")
                    
                }
                
                //Obtener email de facebook
                if let nombre : NSString = result.valueForKey("first_name") as? NSString {
                    self.nombreFacebook = nombre as String
                    print("nombre es: \(nombre)")
                    
                }
                
                //Obtener email de facebook
                if let apellido : NSString = result.valueForKey("last_name") as? NSString {
                    self.apellidoFacebook = apellido as String
                    print("Apellido es: \(apellido)")
                    
                }
                
                //Obtener imagen de facebook
                if let picture : NSDictionary = result.valueForKey("picture") as? NSDictionary {
                    if let data = picture["data"] as? NSDictionary {
                        if let imagen = data["url"] as? String {
                            if let url  = NSURL(string: imagen),
                                data = NSData(contentsOfURL: url){
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        imagenFacebook = UIImage(data: data)
                                    })
                            }
                        }
                    }
                    
                }
                
            }
            self.returnUserProfileImage(self.idFacebook)
            self.loginFacebook(self.idFacebook)
        })
    }
    
    
    // accessToken is your Facebook id
    func returnUserProfileImage(accessToken: String) {
        let userID = accessToken as String
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(userID)/picture?type=large")
        
        if let data = NSData(contentsOfURL: facebookProfileUrl!) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let imagenGrandeFace = UIImage(data: data)
                print("La imagen grande de facebbok es \(imagenGrandeFace)")
                
            })
        }
        
    }
    
    
    // FUNCIONALIDAD DE BOTONES
    
    @IBAction func IniciarSesionBoton(sender: AnyObject) {
        
        let celular = celularTextfield.text;
        let contraseña = contraseñaTextfield.text;
        
        if (celular != "" && contraseña != ""){
            // HACER EL LOGIN DE USUARIO
            loginWS(celular!, auxContraseña: contraseña!);
            
        } else {
            
            if #available(iOS 8.0, *) {
                let alerta = UIAlertController(title: "Aviso", message: "Ingresa tus datos correctamente", preferredStyle: UIAlertControllerStyle.Alert)
                alerta.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alerta, animated: true, completion: nil)
            } else {
                let alerta = UIAlertView(title: "Aviso", message: "Ingresa tus datos correctamente", delegate: self, cancelButtonTitle: "Aceptar")
                alerta.show()
            }
            
        }
        
    }
    
    @IBAction func registrarBoton(sender: AnyObject) {
        
        
    }
    
    @IBAction func recuperarContraseña(sender: AnyObject) {
        
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.vistaRecuperarContraseña.transform = CGAffineTransformConcat(scale, translate)
            
            }, completion: nil)
        
    }

    
}
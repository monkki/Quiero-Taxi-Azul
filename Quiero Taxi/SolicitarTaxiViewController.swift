//
//  SolicitarTaxiViewController.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 11/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit
import MapKit

class SolicitarTaxiViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    // Tipos de taxis
    var taxis = ["Sedan (1-4)"]
    
    // Outlets
    @IBOutlet var direccionTextfield: UITextField!
    @IBOutlet var numeroExteriorTexfield: UITextField!
    @IBOutlet var coloniaTextfield: UITextField!
    @IBOutlet var referenciasTextfield: UITextField!
    @IBOutlet var taxiPicker: UIPickerView!
   
    // Variables para pedir taxi
    var selectedValue: String!
    var valorNumerico = "1"
    var direccion = ""
    var colonia = ""
    var numeroExterior = ""
    var referencias = ""
    var telefono: String!
    
    // Loader
    var progressHUD: UIView!
    
    // Variables de ubicacion
    var latitudeRecibida: String!
    var longitudeRacibida: String!
    
    
    @IBAction func cancelarBoton(sender: AnyObject) {
        
        
    }
    
    
    @IBAction func aceptarBoton(sender: AnyObject) {
        
        
        numeroExterior = numeroExteriorTexfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        referencias = referenciasTextfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        direccion = direccionTextfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        colonia = coloniaTextfield.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        valorNumerico = valorNumerico.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        latitudeRecibida = latitudeRecibida.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        longitudeRacibida = longitudeRacibida.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        telefono = telefono.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
       // numeroExterior == "" ||
        
        if(referencias == "" || direccion == "" || colonia == "" || valorNumerico == ""){
            mostraMSJ("Favor de completar los datos!")
            
        }else {
            
      
            if #available(iOS 8.0, *) {
                // Loader
                progressHUD = ProgressHUD(text: "Obteniendo ubicacion")
                self.view.addSubview(progressHUD)
                
            }
            
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            solicitarTaxi();
            
        }


        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Tipo de taxi
        taxiPicker.delegate = self
        selectedValue = taxis[0]
        print(selectedValue)
        print(valorNumerico)
        
        // Delegados de textfields
        direccionTextfield.delegate = self
        numeroExteriorTexfield.delegate = self
        referenciasTextfield.delegate = self
        coloniaTextfield.delegate = self
        
        // Gesture para ocultar teclado
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
       
        // Se asigna valores recibidos del mapa
        direccionTextfield.text = direccion
        coloniaTextfield.text = colonia
        
        // Se asigna la imagen de fondo
        view.backgroundColor = UIColor(patternImage: UIImage(named: "gris")!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return taxis.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return taxis[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = taxis[pickerView.selectedRowInComponent(0)]
        print(selectedValue)
        obtenerValorNumerico(selectedValue)
        print(valorNumerico)
    }
    
    func obtenerValorNumerico(valor: String){
        
        switch valor {
        case "Sedan (1-4)":
            valorNumerico = "1"
        case "Minivan (5-7)":
            valorNumerico = "2"
        case "Van (8-12)":
            valorNumerico = "3"
        case "Torito Taxi":
            valorNumerico = "4"
        default :
            valorNumerico = "0"
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    // FUNCION PARA SOLICITAR TAXIS
    
    func solicitarTaxi(){
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        
        selectedValue = selectedValue.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        valorNumerico = valorNumerico.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        direccion = direccion.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        //colonia = colonia.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        //numeroExterior = numeroExterior.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        referencias = referencias.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        latitudeRecibida = latitudeRecibida.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        longitudeRacibida = longitudeRacibida.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        telefono = telefono?.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        var numeroYColonia = numeroExterior + " Col: " + colonia
        numeroYColonia = numeroYColonia.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        
        let urlObj = Urls();
        let urlString = urlObj.getUrlPedirTaxi(direccion, numero: numeroYColonia, referencia: referencias, longitud: longitudeRacibida, latitud: latitudeRecibida, categoria: valorNumerico, telefono: telefono!)
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
                            
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            
                            let idServicio: String! = jsonResult[0]["id_servicio"] as! NSString as String
                           // let categoria: String! = jsonResult[0]["categoria"] as! NSString as String
                            //let idCarro: String! = jsonResult[0]["id_carro"] as! NSString as String
                            
                            NSUserDefaults.standardUserDefaults().setObject(idServicio, forKey: "idServicio")
                          //  NSUserDefaults.standardUserDefaults().setObject(categoria, forKey: "categoria")
                            //NSUserDefaults.standardUserDefaults().setObject(idCarro, forKey: "id_carro")
                            NSUserDefaults.standardUserDefaults().setObject("0", forKey: "statusDeServicio")
                            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "estatusPedido")
                            
                            if #available(iOS 8.0, *) {
                                
                                let progrees = self.progressHUD as! ProgressHUD
                                progrees.hide()
                                
                            }
                            
                            self.performSegueWithIdentifier("taxiSolicitado", sender: self)
                        
                        })
                    
                    } else if(aux_exito == "2"){
                    
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        self.mostraMSJ("Lo sentimos su usuario esta inactivo")
                        
                        if #available(iOS 8.0, *) {
                            
                            let progrees = self.progressHUD as! ProgressHUD
                            progrees.hide()
                            
                        }
                    
                    } else {
                    
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            self.mostraMSJ("Error al pedir su Taxi, intente nuevamente mas tarde.");
                            
                            if #available(iOS 8.0, *) {
                                
                                let progrees = self.progressHUD as! ProgressHUD
                                progrees.hide()
                                
                            }
                        })
                        
                    }
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        self.mostraMSJ("Por favor compruebe su conexion a Internet");
                        
                        if #available(iOS 8.0, *) {
                            
                            let progrees = self.progressHUD as! ProgressHUD
                            progrees.hide()
                            
                        }
                    })
                    
                }
                
                
            } catch {
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                print(error)
                
            }
            
        })
        
        jsonQuery.resume()
    }
    
    
    func mostraMSJ(msj: String){
        
        if #available(iOS 8.0, *) {
            
            let alertView_usuario_incorrecto = UIAlertController(title: "Alerta!", message: msj, preferredStyle: .Alert)
            alertView_usuario_incorrecto.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction) -> Void in
            }))
            self.presentViewController(alertView_usuario_incorrecto, animated: true, completion: nil)
            
        } else {
            
            let alertView_usuario_incorrecto = UIAlertView(title: "Alerta!", message: msj, delegate: self, cancelButtonTitle: "OK")
            
            alertView_usuario_incorrecto.show()
            
        }
        
    }


//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "taxiSolicitado" {
//            let destinoVC = segue.destinationViewController as! MapViewController
//            destinoVC.latitude = CLLocationDegrees(latitudeRecibida)
//            destinoVC.longitude = CLLocationDegrees(longitudeRacibida)
//        }
//    }


}

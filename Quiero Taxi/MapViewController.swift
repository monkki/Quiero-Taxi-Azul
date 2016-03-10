//
//  MapViewController.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 09/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation


class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate {

    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var mapView: GMSMapView!
    
    // VISTAS VERDE INICIAL
    @IBOutlet var direccionLabel: UILabel!
    @IBOutlet var ciudadLabel: UILabel!
    @IBOutlet var imagenLocalizacion: UIImageView!
    @IBOutlet var encabezadoVerde: UIView!
    @IBOutlet var vistaVerdeAbajo: UIView!
    @IBOutlet var botonPedirTaxi: UIButton!
    @IBOutlet var botonHistorial: UIButton!
    @IBOutlet var botonUbicacion: UIButton!
    
    
    // VISTAS ENCABEZADO
    @IBOutlet var fotoTaxista: UIImageView!
    @IBOutlet var nombreTaxista: UILabel!
    @IBOutlet var datosTaxista: UILabel!
    @IBOutlet var llamarBoton: UIButton!
    
    // VISTAS FOOTER
    @IBOutlet var cancelarBoton: UIButton!
    @IBOutlet var tiempoLabel: UILabel!
    @IBOutlet var abordarBoton: UIButton!
    
    //VISTA CALIFICAR
    @IBOutlet var vistaCalificar: UIView!
    @IBOutlet var taxistaNombre: UILabel!
    @IBOutlet var taxistaDetalles: UILabel!
    @IBOutlet var comentariosTextfield: UITextField!
    @IBOutlet var estrellasCalificacion: CosmosView!
    
    // MAPAS
    var camera: GMSCameraPosition!
    var locationManager : CLLocationManager!
    var progressHUD: UIView!
    var direccion = ""
    var colonia = ""
    
    //VISTA ANIMACION
    @IBOutlet var vistaAnimacion: UIView!
    
    // UBICACION
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    let telefono = NSUserDefaults.standardUserDefaults().objectForKey("telefono")
    
    // STATUS PEDIDO
    var estatusPedido = NSUserDefaults.standardUserDefaults().objectForKey("estatusPedido") as! Bool
    var statusDelServicio: String!
    var timerCancelar: NSTimer!
    var timerChecarEstatus: NSTimer!
    var idServicios = NSUserDefaults.standardUserDefaults().objectForKey("idServicio") as! String
    var categoria = NSUserDefaults.standardUserDefaults().objectForKey("categoria") as! String
   // var idCarro = NSUserDefaults.standardUserDefaults().objectForKey("id_carro") as! String
    var valorStatus = ""
    var notificacionEnCaminoRecibida = false
    var notificacionTaxiLLegoRecibida = false
    var taxistasPosicion = false
    var alertaMostrada = false
    var getTaxistaUbicacion = false
    
    // VARIABLE PARA CORRER EN BACKGROUND
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    // LATITUDE Y LONGITUD GUARDADA
    var latitudeDefaults: String = NSUserDefaults.standardUserDefaults().objectForKey("latitudGuardada") as! String
    var longitudeDefaults: String = NSUserDefaults.standardUserDefaults().objectForKey("longitudGuardada") as! String
    
    // TELEFONO TAXISTA
    var telefonoTaxista: String = ""
    
    // GESTO DESLIZAR AL MENU
    var deslizarAlMenuGesture : UIPanGestureRecognizer!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // VARIABLE PARA CORRER EN BACKGROUND
        backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskIdentifier!)
        })
        
        // Funcionalidad del Menu
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            deslizarAlMenuGesture = self.revealViewController().panGestureRecognizer()
            view.addGestureRecognizer(deslizarAlMenuGesture)
            
        }
        
        deslizarAlMenuGesture.enabled = true
        
        
        // Funcionalidad Localizacion
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
        } else {
            // Fallback on earlier versions
        }
        locationManager.startUpdatingLocation()
        
        comentariosTextfield.delegate = self
    
        if #available(iOS 8.0, *) {
            // Loader
            progressHUD = ProgressHUD(text: "Obteniendo ubicación")
            self.view.addSubview(progressHUD)
            
        }

        
        // Variable para guardar Status
        statusDelServicio = NSUserDefaults.standardUserDefaults().objectForKey("statusDeServicio") as! String
        
        ocultarVentanaCalificacion()
        
        // Imprime latitud y longitud guardada
        print("Su longitud guardada es: " + latitudeDefaults)
        print("Su longitud guardada es: " + longitudeDefaults)
        
        
        // Funcion dismiss teclado
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // Metodo para cambiar de vista segun status de servicio
        self.checarStatusDeServicio(self.statusDelServicio)
        self.status(self.estatusPedido)
        
        // Imagen encabezado
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "quieroTaxiEncabezado")
        imageView.image = image
        navigationItem.titleView = imageView
        navigationItem.titleView!.sizeThatFits(CGSize(width: 220, height: 65))
        
        // BOTON PEDIR TAXI SE ENCUENTRA DESHABILITADO HASTA OBTENER LA DIRECCION VIA GEOCODER
        self.botonPedirTaxi.enabled = false

    }
    
    override func viewDidAppear(animated: Bool) {
        setUbicacion()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        // ANIMACION MAPA
        vistaAnimacion.layer.cornerRadius = 225
        vistaAnimacion.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:0.8)
        self.view.addSubview(vistaAnimacion)
        let opacidad:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        let scaleAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 2.0
        opacidad.duration = 2.0
        scaleAnimation.repeatCount = 80.0
        opacidad.repeatCount = 80.0
        scaleAnimation.autoreverses = false
        opacidad.autoreverses = false
        //scaleAnimation.fromValue = 1.2;
        scaleAnimation.fromValue = 0.1;
        opacidad.fromValue = 1.0
        opacidad.toValue = 0.0
        vistaAnimacion.layer.addAnimation(scaleAnimation, forKey: "scale")
        vistaAnimacion.layer.addAnimation(opacidad, forKey: "opacity")
        vistaAnimacion.hidden = true
        
    }

    
    // FUNCION CHECA EL ESTATUS DE SERVICIO
    
    func status(estatusPedido: Bool) {
        
        if estatusPedido == true {
            
            deslizarAlMenuGesture.enabled = false
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                // Timers
                
                print("Timers activos")
           
                self.timerChecarEstatus = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "checarEstatusTaxi", userInfo: nil, repeats: true) as NSTimer

                self.timerCancelar = NSTimer.scheduledTimerWithTimeInterval(70, target: self, selector: "cancelarPorSistema", userInfo: nil, repeats: false) as NSTimer
            }
            
        }
        
    }
    
    // CANCELAR POR SISTEMA
    
    func cancelarPorSistema () {
        
        valorStatus = "7"
        cancelarPedido(idServicios, valor: valorStatus)
        
    }
    
    
    // ACTUALIZAR SERVICIO
    
    func cancelarPedido(idServicio: String, valor: String) {
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        
        idServicios = idServicios.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        valorStatus = valorStatus.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
       // categoria = categoria.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
     //   idCarro = idCarro.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlObj = Urls();
        let urlString = urlObj.getUrlActualizarServicio(idServicios, valor: valorStatus)
        let url = NSURL(string: urlString)!
        let urlSession = NSURLSession.sharedSession()
        
        
        let jsonQuery = urlSession.dataTaskWithURL(url, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            
            do {
                
                if let data = data {
                    
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSMutableArray
                    
                   // print(jsonResult[0])
                    
                    let aux_exito: String! = jsonResult[0]["success"] as! NSString as String
                    
                    if(aux_exito == "1" && self.valorStatus == "2" || self.valorStatus == "7" || self.valorStatus == "6"){
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            print("Pedido cancelado por sistema")
                            
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            self.abordarBoton.enabled = true
                            
                            self.mostrarMensaje("Su servicio ha sido cancelado", titulo: "Quiero Taxi")
                            self.scheduleLocal(self, mensaje: "Su servicio ha sido cancelado")
                            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "estatusPedido")
                            NSUserDefaults.standardUserDefaults().setObject("-1", forKey: "statusDeServicio")
                            NSUserDefaults.standardUserDefaults().setObject("0", forKey: "idServicio")
                            NSUserDefaults.standardUserDefaults().setObject("0", forKey: "categoria")
                            //NSUserDefaults.standardUserDefaults().setObject("0", forKey: "id_carro")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            self.statusDelServicio = NSUserDefaults.standardUserDefaults().objectForKey("statusDeServicio") as! String
                            self.estatusPedido = NSUserDefaults.standardUserDefaults().objectForKey("estatusPedido") as! Bool
                            self.idServicios = NSUserDefaults.standardUserDefaults().objectForKey("idServicio") as! String
                            self.categoria = NSUserDefaults.standardUserDefaults().objectForKey("categoria") as! String
                            //self.idCarro = NSUserDefaults.standardUserDefaults().objectForKey("id_carro") as! String
                           
                                self.timerCancelar.invalidate()
                                self.timerChecarEstatus.invalidate()
                                self.checarStatusDeServicio(self.statusDelServicio)
                                self.status(self.estatusPedido)
                                self.vistaAnimacion.hidden = true
                                self.mapView.clear()
                                self.viewDidLoad()
                            
                            
                        })
                        
                    } else if(aux_exito == "1" && self.valorStatus == "1"){
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            print("Abordado")
                            
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            
                            self.timerChecarEstatus.invalidate()
                            self.timerChecarEstatus.fire()
                            self.timerCancelar.invalidate()
                            NSUserDefaults.standardUserDefaults().setObject("4", forKey: "statusDeServicio")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            self.statusDelServicio = NSUserDefaults.standardUserDefaults().objectForKey("statusDeServicio") as! String
                            // Metodo para cambiar de vista segun status de servicio
                            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                                self.checarStatusDeServicio(self.statusDelServicio)
                                self.status(self.estatusPedido)
                            }

                            
                        })
                        
                    } else if(aux_exito == "0"){
                        
                        let mensaje: String! = jsonResult[0]["mensaje"] as! NSString as String
                        self.mostraMSJ(mensaje)
                        
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
    
    // ESTATUS TAXI
    
    func checarEstatusTaxi() {
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        
        idServicios = idServicios.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        //categoria = categoria.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        //idCarro = idCarro.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlObj = Urls();
        let urlString = urlObj.getUrlStatusTaxi(idServicios)
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
                    let estatus: String! = jsonResult[0]["estatus"] as! NSString as String
                    
                    
                    if(aux_exito == "1" && estatus == "2" || estatus == "5" || estatus == "7"){
                       
                        
                        print("Estatus ha cambiado")
                                
                        self.cancelarPedido(self.idServicios, valor: estatus)
                        
                        
                    } else if (aux_exito == "1" && estatus == "6") {
                        
                        print("Estatus Cancelado por Taxista")
                        
                        self.scheduleLocal(self, mensaje: "Taxista ha cancelado su solicitud")
                        self.valorStatus = "6"
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "estatusPedido")
                            NSUserDefaults.standardUserDefaults().setObject("-1", forKey: "statusDeServicio")
                            NSUserDefaults.standardUserDefaults().setObject("0", forKey: "idServicio")
                            NSUserDefaults.standardUserDefaults().setObject("0", forKey: "categoria")
                            //NSUserDefaults.standardUserDefaults().setObject("0", forKey: "id_carro")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            self.statusDelServicio = NSUserDefaults.standardUserDefaults().objectForKey("statusDeServicio") as! String
                            self.estatusPedido = NSUserDefaults.standardUserDefaults().objectForKey("estatusPedido") as! Bool
                            self.idServicios = NSUserDefaults.standardUserDefaults().objectForKey("idServicio") as! String
                            self.categoria = NSUserDefaults.standardUserDefaults().objectForKey("categoria") as! String
                            //self.idCarro = NSUserDefaults.standardUserDefaults().objectForKey("id_carro") as! String
                            
                            self.timerCancelar.invalidate()
                            self.timerChecarEstatus.invalidate()
                            self.checarStatusDeServicio(self.statusDelServicio)
                            self.status(self.estatusPedido)
                            self.vistaAnimacion.hidden = true
                            self.mapView.clear()
                            self.viewDidLoad()
                            
                        })
                        
                        
                       // self.cancelarPedido(self.idServicios, valor: self.valorStatus)
                        

                        
                    } else if (aux_exito == "1" && estatus == "0") {
                        
                        print("Checando Estatus")
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.vistaAnimacion.hidden = false
                            
                            if self.getTaxistaUbicacion == false {
                                self.getTaxistasCercanos()
                                self.getTaxistaUbicacion = true
                            }
                            
                        }
                        
                        
                    } else if (aux_exito == "1" && estatus == "3") {
                        
                        self.timerChecarEstatus.invalidate()
                        self.timerChecarEstatus.fire()
                        self.timerCancelar.invalidate()
                        NSUserDefaults.standardUserDefaults().setObject("3", forKey: "statusDeServicio")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.statusDelServicio = NSUserDefaults.standardUserDefaults().objectForKey("statusDeServicio") as! String
                        // Metodo para cambiar de vista segun status de servicio
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.checarStatusDeServicio(self.statusDelServicio)
                            self.status(self.estatusPedido)
                            
                            self.mapView.clear()
                            
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2DMake(CLLocationDegrees(self.latitudeDefaults)!, CLLocationDegrees(self.longitudeDefaults)!)
                            marker.title = "Ubicacion"
                            marker.icon = UIImage(named: "ic_pasajero")
                            //marker.draggable = true
                            marker.snippet = ""
                            marker.map = self.mapView
                            
                            self.getPosicionTaxista()
                            
                            if self.alertaMostrada == false {
                                self.mostraMSJ("Su taxista va en camino")
                                
                                self.alertaMostrada = true
                                self.vistaAnimacion.hidden = true
                            
                            }
                            
                        }
                        
                    } else if (aux_exito == "1" && estatus == "4") {
                    
                        
                        self.timerChecarEstatus.invalidate()
                        self.timerChecarEstatus.fire()
                        self.timerCancelar.invalidate()
                        NSUserDefaults.standardUserDefaults().setObject("4", forKey: "statusDeServicio")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.statusDelServicio = NSUserDefaults.standardUserDefaults().objectForKey("statusDeServicio") as! String
                        // Metodo para cambiar de vista segun status de servicio
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.checarStatusDeServicio(self.statusDelServicio)
                            self.status(self.estatusPedido)
                            
                            if self.alertaMostrada == true {
                                self.mostraMSJ("Su taxista ha llegado")
                                self.alertaMostrada = false
                            }
                        }
                        
                        
                    } else if (aux_exito == "1" && estatus == "1") {
                        
                        NSUserDefaults.standardUserDefaults().setObject("1", forKey: "statusDeServicio")
                        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "estatusPedido")
                 //       NSUserDefaults.standardUserDefaults().setObject("0", forKey: "idServicio")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.statusDelServicio = NSUserDefaults.standardUserDefaults().objectForKey("statusDeServicio") as! String
                        self.estatusPedido = NSUserDefaults.standardUserDefaults().objectForKey("estatusPedido") as! Bool
                        self.idServicios = NSUserDefaults.standardUserDefaults().objectForKey("idServicio") as! String
                        // Metodo para cambiar de vista segun status de servicio
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.checarStatusDeServicio(self.statusDelServicio)
                            self.status(self.estatusPedido)
                        }
                        self.timerCancelar.invalidate()
                        self.timerChecarEstatus.invalidate()
                        
                    } else if(aux_exito == "0"){
                        
                        let mensaje: String! = jsonResult[0]["mensaje"] as! NSString as String
                        self.mostraMSJ(mensaje)
                        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue) {
        
    }
    
    
    // FUNCIONES DE LOCALIZACION
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error to get location : \(error)")
        
        
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        latitude = userLocation.coordinate.latitude
        longitude = userLocation.coordinate.longitude
        
        mapView.clear()
        
        camera = GMSCameraPosition.cameraWithLatitude(latitude,
            longitude: longitude, zoom: 15)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = "Ubicacion"
        marker.icon = UIImage(named: "ic_pasajero")
        //marker.draggable = true
        marker.snippet = ""
        marker.map = mapView
        mapView.camera = camera
        
        
        
        // locationManager.stopUpdatingLocation()
        
        if let ubicacion = manager.location {
            
            CLGeocoder().reverseGeocodeLocation(ubicacion, completionHandler: {(placemarks, error)-> Void in
                if (error != nil) {
                    
                    print("Geocoder fallo, error: " + error!.localizedDescription)
                    return
                    
                }
                
                if placemarks!.count > 0 {
                    
                    let pm = placemarks![0] as CLPlacemark
                    self.displayLocationInfo(pm)
                    self.botonPedirTaxi.enabled = true
                    
                } else {
                    
                    print("Hay un problema con los datos recibidos")
                    
                }
                
            })
            
        }
        
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
        locationManager.stopUpdatingLocation()
        
        if #available(iOS 8.0, *) {
            
            let progrees = progressHUD as! ProgressHUD
            progrees.hide()
            
        }
        
        let ciudadInfo = placemark.locality! as String
        let estadoInfo = placemark.administrativeArea! as String
        let colonia = placemark.addressDictionary!["SubLocality"] as? String
        let direccion = placemark.addressDictionary!["Street"] as? String
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            if let colonia = colonia {
                
                if let direccion = direccion {
                    
                    self.direccion = direccion
                    self.colonia = colonia
                    self.direccionLabel.text = direccion + ", " + colonia
                    self.ciudadLabel.text = "\(ciudadInfo)" + " | " + "\(estadoInfo)"
                    
                }
            }
            
            
        }
        
    }
    
    // MUESTRA ALERTA AL USUARIO
    
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

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "solicitarTaxiSegue" {
            
            if let destinoVc:SolicitarTaxiViewController = segue.destinationViewController as? SolicitarTaxiViewController {
                destinoVc.direccion = direccion
                destinoVc.colonia = colonia
                destinoVc.latitudeRecibida = String(latitude)
                destinoVc.longitudeRacibida = String(longitude)
                destinoVc.telefono = telefono as! String
            }
            
        }
    }
    
    func muestraVentanaCalificacion() {
        
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.vistaCalificar.transform = CGAffineTransformConcat(scale, translate)
            
            }, completion: nil)
    }
    
    func ocultarVentanaCalificacion() {
        
        let scale = CGAffineTransformMakeScale(0.0, 0.0)
        let translate = CGAffineTransformMakeTranslation(0, 600)
        vistaCalificar.transform = CGAffineTransformConcat(scale, translate)
        
    }

    
    func checarStatusDeServicio(numeroDeStatus: String) {
        
        
        switch numeroDeStatus {
        case "-1":
            // Status Inicial
            direccionLabel.hidden = false
            ciudadLabel.hidden = false
            imagenLocalizacion.hidden = false
            encabezadoVerde.hidden = false
            encabezadoVerde.backgroundColor = UIColor(red:0.27, green:0.44, blue:0.58, alpha:0.7)
            vistaVerdeAbajo.hidden = false
            vistaVerdeAbajo.backgroundColor = UIColor(red:0.27, green:0.44, blue:0.58, alpha:0.7)
            botonPedirTaxi.hidden = false
            botonHistorial.hidden = false
            botonUbicacion.hidden = false
            
            
            fotoTaxista.hidden = true
            nombreTaxista.hidden = true
            datosTaxista.hidden = true
            llamarBoton.hidden = true
            
            
            cancelarBoton.hidden = true
            tiempoLabel.hidden = true
            abordarBoton.hidden = true
            menuButton.enabled = true
            
            notificacionEnCaminoRecibida = false
            notificacionTaxiLLegoRecibida = false
            
        case "0":
            // Status pedido
            direccionLabel.hidden = true
            ciudadLabel.hidden = true
            imagenLocalizacion.hidden = true
            encabezadoVerde.hidden = true
            vistaVerdeAbajo.hidden = false
            vistaVerdeAbajo.backgroundColor = UIColor.blackColor()
            botonPedirTaxi.hidden = true
            botonHistorial.hidden = true
            botonUbicacion.hidden = true
            
            fotoTaxista.hidden = true
            nombreTaxista.hidden = true
            datosTaxista.hidden = true
            llamarBoton.hidden = true
            
            
            cancelarBoton.hidden = false
            tiempoLabel.hidden = false
            abordarBoton.hidden = true
            menuButton.enabled = false
            
            
        case "3":
            // Status en camino
            direccionLabel.hidden = true
            ciudadLabel.hidden = true
            imagenLocalizacion.hidden = true
            encabezadoVerde.hidden = false
            encabezadoVerde.backgroundColor = UIColor.blackColor()
            vistaVerdeAbajo.hidden = false
            vistaVerdeAbajo.backgroundColor = UIColor.blackColor()
            botonPedirTaxi.hidden = true
            botonHistorial.hidden = true
            botonUbicacion.hidden = true
            
            fotoTaxista.hidden = false
            nombreTaxista.hidden = false
            datosTaxista.hidden = false
            llamarBoton.hidden = false
            
            
            cancelarBoton.hidden = false
            tiempoLabel.hidden = false
            abordarBoton.hidden = true
            if notificacionEnCaminoRecibida == false {
                scheduleLocal(self, mensaje: "Su taxi va en camino")
                notificacionEnCaminoRecibida = true
            }
            

        case "4":
            // Status ha llegado
            
            direccionLabel.hidden = true
            ciudadLabel.hidden = true
            imagenLocalizacion.hidden = true
            encabezadoVerde.hidden = false
            encabezadoVerde.backgroundColor = UIColor.blackColor()
            vistaVerdeAbajo.hidden = false
            vistaVerdeAbajo.backgroundColor = UIColor.blackColor()
            botonPedirTaxi.hidden = true
            botonHistorial.hidden = true
            botonUbicacion.hidden = true
            
            fotoTaxista.hidden = false
            nombreTaxista.hidden = false
            datosTaxista.hidden = false
            llamarBoton.hidden = false
            
            
            cancelarBoton.hidden = false
            tiempoLabel.hidden = false
            abordarBoton.hidden = false
            if notificacionTaxiLLegoRecibida == false {
                scheduleLocal(self, mensaje: "Su taxi ha llegado")
                notificacionTaxiLLegoRecibida = true
            }
            
        case "1":
            //Status concluido
            
            direccionLabel.hidden = true
            ciudadLabel.hidden = true
            imagenLocalizacion.hidden = true
            encabezadoVerde.hidden = false
            encabezadoVerde.backgroundColor = UIColor.blackColor()
            vistaVerdeAbajo.hidden = false
            vistaVerdeAbajo.backgroundColor = UIColor.blackColor()
            botonPedirTaxi.hidden = true
            botonHistorial.hidden = true
            botonUbicacion.hidden = true
            
            fotoTaxista.hidden = false
            nombreTaxista.hidden = false
            datosTaxista.hidden = false
            llamarBoton.hidden = false
            
            
            cancelarBoton.hidden = false
            tiempoLabel.hidden = false
            abordarBoton.hidden = false

            muestraVentanaCalificacion()

        default:
            break
        }
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
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
    
    
    // METODO PARA GUARDAR UBICACION EN PRIMERA INSTANCIA
    
    func setUbicacion(){
        
        //$update = "update usuario set longitud = '$longitud', latitud = '$latitud' where telefono='$telefono' ";
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let ubicacion = prefs.objectForKey("ubicacion") as! String
        
        
        if(ubicacion == "0"){
            
            let telefono = prefs.objectForKey("telefono") as! String
            
            let latitud = String (self.latitude)
            let longitud = String (self.longitude)
            
            
            let urlObj = Urls();
            
            let urlString = urlObj.getUrlUbicacion(telefono, latitud: latitud, longitud: longitud)
            
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
                    
                        // print( jsonResult[0])
                    
                        print("Fui Ubicacion ;) ")
                    
                        let aux_exito: String! = jsonResult[0]["success"] as! NSString as String
                    
                        if(aux_exito == "1"){
                        
                            prefs.setObject("1", forKey: "ubicacion")
                        
                            prefs.synchronize();
                        
                        } else if(aux_exito == "0") {
                        
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                                //Ha surguido un errror
                            
                            })
                        
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
        
    }
    
    // FUNCION PARA ENVIAR NOTIFICACIONES LOCALES
    
    func scheduleLocal(sender: AnyObject, mensaje: String) {
        
        if #available(iOS 8.0, *) {
            
            let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
            
            if settings!.types == .None {
                let ac = UIAlertController(title: "Alerta", message: "No se pudo recibir la notificación", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(ac, animated: true, completion: nil)
                return
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        notification.alertBody = mensaje
        notification.alertAction = "desbloquear!"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
    // METODO PARA OBTENER TAXISTAS CERCANOS
    
    func getTaxistasCercanos(){
        
        //let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        
        let latitud: String = self.latitudeDefaults
        let longitud: String = self.longitudeDefaults
        let tipo: String = "1"
        
       // idServicios = idServicios.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        //categoria = categoria.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        //idCarro = idCarro.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlObj = Urls();
        let urlString = urlObj.getUrlTaxistasCercanos(latitud, longitud: longitud, tipo: tipo)
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
                
                    //print( jsonResult[0])
                
                    let aux_exito: String! = jsonResult[0]["success"] as! NSString as String
                
                
                    if(aux_exito == "1"){
                        
                        var latitudesTaxista = [String]()
                        var longitudesTaxista = [String]()
                    
                        if let servicios = jsonResult[0]["servicios"] as? NSMutableArray {
                            
                            //print(servicios)
                            
                            for servicio in servicios {
                                
                                let latitudTaxista = servicio["latitud"] as! String
                                let longitudeTaxista = servicio["longitud"] as! String
                                
                                latitudesTaxista.append(latitudTaxista)
                                longitudesTaxista.append(longitudeTaxista)
                                
                            }
                            
                            print(latitudesTaxista)
                            print(longitudesTaxista)
                            
                                                    
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                                self.camera = GMSCameraPosition.cameraWithLatitude(self.latitude,
                                longitude: self.longitude, zoom: 14)
                                self.mapView.camera = self.camera
                              
                                for var i = 0; i < latitudesTaxista.count ; i++ {
                                    
                                    let markerTaxista = GMSMarker()
                                    markerTaxista.position = CLLocationCoordinate2DMake(CLLocationDegrees(latitudesTaxista[i])!, CLLocationDegrees(longitudesTaxista[i])!)
                                    markerTaxista.title = "Ubicacion Taxista"
                                    markerTaxista.icon = UIImage(named: "ic_taxi")
                                    //marker.draggable = true
                                    markerTaxista.snippet = ""
                                    markerTaxista.map = self.mapView
                                    
                                    
                                }
                            
                            })

                        }
                    
                    
                    } else if(aux_exito == "0") {
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        })
                    
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
    
    
    // METODO PARA OBTENER DATOS y UBICACION DEL TAXISTA
    
    func getPosicionTaxista(){
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        
        idServicios = idServicios.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
       // categoria = categoria.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
      //  idCarro = idCarro.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlObj = Urls();
        let urlString = urlObj.getPosicionTaxista(idServicios)
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
                
                    // print( jsonResult[0])
                
                    let aux_exito: String! = jsonResult[0]["success"] as! NSString as String
                
                    if(aux_exito == "1"){
                    
                        let placas: String! = jsonResult[0]["placas"] as! NSString as String
                        let carro: String! = jsonResult[0]["carro"] as! NSString as String
                    
                        //let organizacion: String! = jsonResult[0]["organizacion"] as! NSString as String
                        let lat: String! = jsonResult[0]["lat"] as! NSString as String
                        let lon: String! = jsonResult[0]["lon"] as! NSString as String
                        //let estatus: String! = jsonResult[0]["estatus"] as! NSString as String
                        let telefono: String! = jsonResult[0]["telefono"] as! NSString as String
                    
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                            if let nombre: String! = jsonResult[0]["nombre"] as! NSString as String {
                            
                                self.nombreTaxista.text = nombre + "\nAuto: " + carro
                            
                                // NOMBRE EN ESTATUS CALIFICAR
                                self.taxistaNombre.text = nombre + "\nAuto: " + carro
                            
                            }
                        
                            self.datosTaxista.text = "Placas: " + placas + " \n Tel: " + telefono
                            
                            
                            let ubicacionCliente = CLLocationCoordinate2DMake(self.latitude, self.longitude)
                            let ubicacionTaxista = CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(lon)!)
                            let bounds = GMSCoordinateBounds(coordinate: ubicacionCliente , coordinate: ubicacionTaxista)
                            let camera = self.mapView.cameraForBounds(bounds, insets:UIEdgeInsetsMake(100, 100, 100, 100))
                        
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(lon)!)
                            marker.title = "Taxista"
                            marker.icon = UIImage(named: "ic_taxi")
                            //marker.draggable = true
                            marker.snippet = ""
                            marker.map = self.mapView
                            self.mapView.camera = camera
                        
                            if let imagen: String = jsonResult[0]["imagen"] as? String {
                            
                                // CONVERTIR IMAGEN
                                let decodedData = NSData(base64EncodedString: imagen, options: NSDataBase64DecodingOptions(rawValue: 0))
                                let decodedimage = UIImage(data: decodedData!)
                            
                                if let decodedImagen = decodedimage {
                                    self.fotoTaxista.image = decodedImagen
                                }
                            }
                        
                            self.alertaMostrada = true
                            self.vistaAnimacion.hidden = true
                            self.telefonoTaxista = telefono as String
                        
                        
                            self.taxistaDetalles.text = "Placas: " + placas + " \n Tel: " + telefono
                        
                        })
                    
                    } else if(aux_exito == "0") {
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                        })
                    
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

    
    // METODO PARA CALIFICAR A TAXISTA
    
    func calificar(){
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        
        var calificacion: String = String(Int(estrellasCalificacion.rating))
        var comentarios: String = comentariosTextfield.text!
        
        calificacion = calificacion.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        comentarios = comentarios.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        idServicios = idServicios.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
       // idCarro = idCarro.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlObj = Urls();
        let urlString = urlObj.calificacionUrl(idServicios, calificacion: calificacion, comentario: comentarios)
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
                
                    print( jsonResult[0])
                
                    let aux_exito: String! = jsonResult[0]["success"] as! NSString as String
                
                    if(aux_exito == "1"){
                    
                        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "estatusPedido")
                        NSUserDefaults.standardUserDefaults().setObject("-1", forKey: "statusDeServicio")
                        NSUserDefaults.standardUserDefaults().setObject("0", forKey: "idServicio")
                        NSUserDefaults.standardUserDefaults().setObject("0", forKey: "categoria")
                        //NSUserDefaults.standardUserDefaults().setObject("0", forKey: "id_carro")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.statusDelServicio = NSUserDefaults.standardUserDefaults().objectForKey("statusDeServicio") as! String
                        self.estatusPedido = NSUserDefaults.standardUserDefaults().objectForKey("estatusPedido") as! Bool
                        self.idServicios = NSUserDefaults.standardUserDefaults().objectForKey("idServicio") as! String
                        self.categoria = NSUserDefaults.standardUserDefaults().objectForKey("categoria") as! String
                      //  self.idCarro = NSUserDefaults.standardUserDefaults().objectForKey("id_carro") as! String
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.checarStatusDeServicio(self.statusDelServicio)
                            self.status(self.estatusPedido)
                            self.viewDidLoad()
                        
                        }
                    
                    
                    } else if(aux_exito == "0") {
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                            self.mostraMSJ("Hubo un error al subir su comentario")
                        
                        })
                    
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
    
    
    /// FUNCIONES DE BOTONES
    
    @IBAction func enviarCalificacion(sender: AnyObject) {
        
        if comentariosTextfield.text == "" {
            mostrarMensaje("Por favor haga su comentario!", titulo: "Quiero Taxi")
        } else {
            calificar()
            self.ocultarVentanaCalificacion()
        }
        
    }
    
    @IBAction func pedirTaxiBoton(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setObject(String(latitude), forKey: "latitudGuardada")
        NSUserDefaults.standardUserDefaults().setObject(String(longitude), forKey: "longitudGuardada")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.performSegueWithIdentifier("solicitarTaxiSegue", sender: self)
        
    }
    
    @IBAction func historialBoton(sender: AnyObject) {
        
    }
    
    @IBAction func ubicacionLabel(sender: AnyObject) {
        
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        
        mapView.clear()
        
        camera = GMSCameraPosition.cameraWithLatitude(latitude!,
            longitude: longitude!, zoom: 16)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude!, longitude!)
        marker.title = "Ubicacion"
        marker.icon = UIImage(named: "ic_pasajero")
        //marker.draggable = true
        marker.snippet = ""
        marker.map = mapView
        mapView.camera = camera
        
    }
    
    @IBAction func llamar(sender: AnyObject) {
        
        let url:NSURL = NSURL(string: "telprompt://\(telefonoTaxista)")!
        UIApplication.sharedApplication().openURL(url)
        
    }
    
    @IBAction func cancelar(sender: AnyObject) {
        
        self.valorStatus = "2"
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.cancelarPedido(idServicios, valor: valorStatus)
        
    }
    
    @IBAction func abordar(sender: AnyObject) {
        
        self.valorStatus = "1"
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.abordarBoton.enabled = false
        self.cancelarPedido(idServicios, valor: valorStatus)
        
    }

}

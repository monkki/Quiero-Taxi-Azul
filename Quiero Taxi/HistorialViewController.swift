//
//  HistorialViewController.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 09/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit

class HistorialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // OUTLETS
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var tabla: UITableView!
    
    var progressHUD: UIView!
    
    // ARRAYS
    var calleArray: [String] = []
    var fechaArray: [String] = []
    var numeroArray: [String] = []
    var referenciasArray: [String] = []
    var placasArray: [String] = []
    
    var telefonoUsuario = NSUserDefaults.standardUserDefaults().objectForKey("telefono") as! String
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        if #available(iOS 8.0, *) {
          // Loader
          progressHUD = ProgressHUD(text: "Cargando")
          self.view.addSubview(progressHUD)
        }
        
        tabla.delegate = self
        
        // Imagen encabezado
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "quieroTaxiEncabezado")
        imageView.image = image
        navigationItem.titleView = imageView
        navigationItem.titleView!.sizeThatFits(CGSize(width: 220, height: 65))

        getHistorial()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calleArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tabla.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! HistorialTableViewCell
        
        cell.descripcionHistorial.text = calleArray[indexPath.row] + " Num: " + numeroArray[indexPath.row]
        cell.fechaHistorial.text = fechaArray[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tabla.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    func getHistorial(){
        
        let customAllowedSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        
        telefonoUsuario = telefonoUsuario.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        
        let urlObj = Urls();
        let urlString = urlObj.getHistorial(telefonoUsuario)
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
                
                    let aux_exito: String! = jsonResult[0]["simon"] as! NSString as String
                
                    if(aux_exito == "1"){
                    
                        if let historial = jsonResult[0]["historial"] as? NSArray {
                    
                            print(historial)
                    
                            for datos in historial {
                        
                                let calle = datos["calle"] as! String
                                let fecha = datos["fecha"] as! String
                                let numero = datos["numero"] as! String
                                let referencia = datos["referencia"] as! String
                                let placas = datos["placas"] as! String
                        
                                self.calleArray.append(calle)
                                self.fechaArray.append(fecha)
                                self.numeroArray.append(numero)
                                self.referenciasArray.append(referencia)
                                self.placasArray.append(placas)
                        
                            }
                    
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                      
                                self.tabla.reloadData()
                        
                                if #available(iOS 8.0, *) {
                            
                                    let progrees = self.progressHUD as! ProgressHUD
                                    progrees.hide()
                            
                                }
                            })
                        }
                    
                    } else if(aux_exito == "0") {
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                            self.mostraMSJ("No hay Historial")
                            
                            if #available(iOS 8.0, *) {
                                
                                let progrees = self.progressHUD as! ProgressHUD
                                progrees.hide()
                                
                            }
                            
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

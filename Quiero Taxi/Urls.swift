//
//  Urls.swift
//  Quiero Taxi
//
//  Created by DC Desarrollo Movil on 11/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import Foundation

class Urls{
    
    // Produccion 11 de Diciembre
   // let RAIZ_WS = "http://quierotaxiservicios.dctimx.com/produccion/nacional/user/ios/"
    
    // Pruebas
    //let RAIZ_WS = "http://quierotaxiservicios.dctimx.com/pruebas/nacional/user/ios/"
    
    let RAIZ_WS = "http://intercubo.com/monki/Taxi/pruebas/nacional/user/ios/"
    
    let LOGIN = "inicio_sesion.php?"
    let REGISTRO = "guardar_registro.php?"
    let RECUPERAR_PASS = "recuperar_pass.php?"
    let VALIDAR_USUARIO = "validar_codigo.php?"
    let PEDIR_TAXI = "pedir_taxi.php?"
    let ACTUALIZAR_SERVICIO = "actualizar_servicio.php?"
    let STATUS_TAXI = "estatus_taxi.php?"
    let UBICACION = "ubicacion_usuario.php?"
    let TAXIS_CERCANOS = "taxis_cerca.php?"
    let POSICION_TAXISTA = "posicion_taxi.php?"
    let HISTORIAL = "historial.php?"
    let FAVORITOS = "favoritos.php?"
    let CALIFICACION = "califica.php?"
    let CARROSBLACK = "getcarroblack.php?"
    let LOGIN_FACEBOOK = "login_facebook.php?"
    
    
    func getUrlLogin(telefono: String, contraseña: String, token: String)-> String{
        let url = RAIZ_WS + LOGIN + "celular=" + telefono + "&contrasena=" + contraseña + "&device_token=" + token;
        return url;
    }
    
    func getUrlRegistro(nombre: String, apellidos: String, celular: String, constraseña: String, correo: String) -> String {
        let url = RAIZ_WS + REGISTRO + "nombre=" + nombre + "&apellidos=" + apellidos + "&celular=" + celular + "&contrasena=" + constraseña + "&correo=" + correo;
        return url;
    }
    
    func getUrlPassCodigo(telefono: String, tipo: String)-> String{
        let url = RAIZ_WS + RECUPERAR_PASS + "celular=" + telefono + "&tipo=" + tipo;
        return url;
    }
    
    func getUrlPassValidarCod(telefono: String, codigo: String)-> String{
        let url = RAIZ_WS + RECUPERAR_PASS + "celular=" + telefono + "&codigo=" + codigo;
        return url;
    }
    
    func getUrlPassCambiar(telefono: String, codigo: String, contraseña: String)-> String{
        let url = RAIZ_WS + RECUPERAR_PASS + "celular=" + telefono + "&codigo=" + codigo + "&contrasena=" + contraseña;
        return url;
    }
    
    func getUrlValidarUser(telefono: String, codigo: String)-> String{
        let url = RAIZ_WS + VALIDAR_USUARIO + "celular=" + telefono + "&codigo=" + codigo;
        return url;
    }
    
    func getUrlPedirTaxi(calle: String, numero: String, referencia: String, longitud: String, latitud: String, categoria: String, telefono: String) -> String {
        let url = RAIZ_WS + PEDIR_TAXI + "calle=" + calle + "&numero=" + numero + "&referencia=" + referencia + "&longitud=" + longitud + "&latitud=" + latitud + "&categoria=" + categoria + "&telefono=" + telefono
        return url
        
    }
    
    func getUrlStatusTaxi(id_servicio: String) -> String {
        let url = RAIZ_WS + STATUS_TAXI + "id_servicio=" + id_servicio
        return url
    }
    
    func getUrlActualizarServicio(id_servicio: String, valor: String)-> String{
        
        let url = RAIZ_WS + ACTUALIZAR_SERVICIO + "id_servicio=" + id_servicio + "&valor=" + valor;
        
        return url;
        
    }
    
    func getUrlUbicacion(telefono: String, latitud: String, longitud: String)-> String{
        
        let url = RAIZ_WS + UBICACION + "telefono=" + telefono + "&latitud=" + latitud + "&longitud=" + longitud;
        
        return url;
        
    }
    
    func getUrlTaxistasCercanos(latitud: String, longitud: String, tipo: String)-> String{
        
        let url = RAIZ_WS + TAXIS_CERCANOS + "&latitud=" + latitud + "&longitud=" + longitud + "&tipo=" + tipo;
        
        return url;
        
    }

    func getPosicionTaxista(idServicio: String)-> String{
        
        let url = RAIZ_WS + POSICION_TAXISTA + "&id_servicio=" + idServicio
        
        return url;
        
    }
    
    func getHistorial(telefono: String)-> String{
        
        let url = RAIZ_WS + HISTORIAL + "telefono=" + telefono
        
        return url;
        
    }

    func getFavoritos(telefono: String)-> String{
        
        let url = RAIZ_WS + FAVORITOS + "telefono=" + telefono
        
        return url;
        
    }

    func calificacionUrl(idServicio: String, calificacion: String, comentario: String )-> String{
        
        let url = RAIZ_WS + CALIFICACION + "idservicio=" + idServicio + "&calificacion=" + calificacion + "&comentario=" + comentario
        
        return url;
        
    }
    
    func getCarrosBlack(latitud: String, longitud: String)-> String{
        
        let url = RAIZ_WS + CARROSBLACK + "latitud=" + latitud + "&longitud=" + longitud;
        
        return url;
        
    }

    func loginFace(id_facebook: String)-> String{
        
        let url = RAIZ_WS + LOGIN_FACEBOOK + "idface=" + id_facebook;
        
        return url;
        
    }
    
    func getUrlRegistroFacebook(id_facebook: String, nombre: String, apellidos: String, celular: String, correo: String) -> String {
        
        let url = RAIZ_WS + LOGIN_FACEBOOK + "idface=" + id_facebook + "&nombre=" + nombre + "&apellidos=" + apellidos + "&celular=" + celular + "&correo=" + correo;
        
        return url;
    }



}
  
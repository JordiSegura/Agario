//
//  GameScene.swift
//  Agario
//
//  Created by Jordi Segura on 18/4/18.
//  Copyright © 2018 Jordi Segura. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    //Creando los nodos para el protagonista,fondo y enemigos
    var protagonista = SKSpriteNode()

    var protagonista1 = SKSpriteNode()
    var protagonista2 = SKSpriteNode()
    var protagonista3 = SKSpriteNode()
    var protagonista4 = SKSpriteNode()
    var fondo = SKSpriteNode()
    var enemigos1 = SKSpriteNode()
    var enemigos2 = SKSpriteNode()
    var enemigos3 = SKSpriteNode()
    var enemigos4 = SKSpriteNode()

    var muerte = SKSpriteNode()
    var booster1 = SKSpriteNode()
    var booster2 = SKSpriteNode()

    
    // Nodo label para la puntuacion
    var labelPuntuacion = SKLabelNode()
    var puntuacion = 0
    
    //Asignando texturas
    var texturaProtagonista1 = SKTexture()
    var texturaProtagonista2 = SKTexture()
    var texturaProtagonista3 = SKTexture()
    var texturaProtagonista4 = SKTexture()
    var texturaEnemigo1 = SKTexture()
    var texturaEnemigo2 = SKTexture()
    var texturaEnemigo3 = SKTexture()
    var texturaEnemigo4 = SKTexture()
    var texturaBoosters1 = SKTexture()
    var texturaBoosters2 = SKTexture()
    
    // timer para crear enemigos y muerte
    var timer = Timer()
    // boolean para saber si el juego está activo o finalizado
    var gameOver = false
    // Variables para mostrar tubos de forma aleatoria
    var cantidadAleatoria = CGFloat()
    var compensacionTubos = CGFloat()
    // altura de los huecos
    var alturaHueco = CGFloat()
    
    // Enumeración de los nodos que pueden colisionar
    // se les debe representar con números potencia de 2
    enum tipoNodo: UInt32 {
        case mosquita = 1       // El protagonista colisiona
        case tuboSuelo = 2      // Si choca con el muerte o enemigo perderá
        case huecoTubos = 4     // si se come a un enemigo subirá la puntuación
    }

    
    override func didMove(to view: SKView) {
        // Nos encargamos de las colisiones de nuestros nodos
        self.physicsWorld.contactDelegate = self
        reiniciar()
    }
    func reiniciar() {
        // Creamos los enemigos de manera constante e indefinidamente
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.ponerTubosYHuecos), userInfo: nil, repeats: true)
        
        // Ponemos la etiqueta con la puntuacion
        ponerPuntuacion()
        
        
        // El orden al poner los elementos es importante, el último tapa al anterior
        // Se puede gestionar también con la posición z de los sprite
        
        crearMosquitaConAnimacion()
        // Definimos la altura de los huecos
        alturaHueco = protagonista1.size.height * 1.2
        crearFondoConAnimacion()
        crearSuelo()
        ponerTubosYHuecos()
    }
    func ponerPuntuacion() {
        labelPuntuacion.fontName = "Arial"
        labelPuntuacion.fontSize = 80
        labelPuntuacion.text = "0"
        labelPuntuacion.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 500)
        labelPuntuacion.zPosition = 2
        self.addChild(labelPuntuacion)
    }
    
    
    @objc func ponerTubosYHuecos() {
        
        // Acción para mover los tubos
        let moverTubos = SKAction.move(by: CGVector(dx: -3 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 80))
        
        // Acción para borrar los tubos cuando desaparecen de la pantalla para no tener infinitos nodos en la aplicación
        let borrarTubos = SKAction.removeFromParent()
        
        
        // Acción que enlaza las dos acciones (la que pone tubos y la que los borra)
        let moverBorrarTubos = SKAction.sequence([moverTubos, borrarTubos])
        
        // Numero entre 0 y la mitad de alto de la pantalla (para que los tubos aparezcan a alturas diferentes)
        cantidadAleatoria = CGFloat(arc4random() % UInt32(self.frame.height/2))
        
        // Compensación para evitar que a veces salga un único tubo porque el otro está fuera de la pantalla
        compensacionTubos = cantidadAleatoria - self.frame.height / 4
        
        texturaBoosters1 = SKTexture(imageNamed: "boost1.png")
        booster1 = SKSpriteNode(texture: texturaBoosters1)
        booster1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + texturaBoosters1.size().height / 2 + alturaHueco + compensacionTubos)
        booster1.zPosition = 0
        
        // Le damos cuerpo físico al tubo
        booster1.physicsBody = SKPhysicsBody(rectangleOf: texturaBoosters1.size())
        // Para que no caiga
        booster1.physicsBody!.isDynamic = false
        
        // Categoría de collision
        booster1.physicsBody!.categoryBitMask = tipoNodo.tuboSuelo.rawValue
        
        // con quien colisiona
        booster1.physicsBody!.collisionBitMask = tipoNodo.mosquita.rawValue
        
        // Hace contacto con
        booster1.physicsBody!.contactTestBitMask = tipoNodo.mosquita.rawValue
        
        booster1.run(moverBorrarTubos)
        
        self.addChild(booster1)
        
        texturaBoosters2 = SKTexture(imageNamed: "boost2.png")
        booster2 = SKSpriteNode(texture: texturaBoosters2)
        booster2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - texturaBoosters2.size().height / 2 - alturaHueco + compensacionTubos)
        booster2.zPosition = 0
        booster2.run(moverBorrarTubos)
        booster2.physicsBody = SKPhysicsBody(rectangleOf: texturaBoosters2.size())
        booster2.physicsBody!.isDynamic = false
        booster2.physicsBody!.categoryBitMask = tipoNodo.tuboSuelo.rawValue
        booster2.physicsBody!.collisionBitMask = tipoNodo.mosquita.rawValue
        booster2.physicsBody!.contactTestBitMask = tipoNodo.mosquita.rawValue
        self.addChild(booster2)
        
        // Hueco entre los tubos
        let nodoHueco = SKSpriteNode()
        
        nodoHueco.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + compensacionTubos)
        nodoHueco.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: texturaBoosters1.size().width, height: alturaHueco))
        nodoHueco.physicsBody?.isDynamic = false
        
        // Asignamos su categoría
        nodoHueco.physicsBody?.categoryBitMask = tipoNodo.huecoTubos.rawValue
        // no queremos que colisione para que la mosca pueda pasar
        nodoHueco.physicsBody?.collisionBitMask = 0
        // Hace contacto con la mosquita
        nodoHueco.physicsBody?.contactTestBitMask = tipoNodo.mosquita.rawValue
        
        nodoHueco.zPosition = 1
        nodoHueco.run(moverBorrarTubos)
        
        self.addChild(nodoHueco)
        
    }
    
    func crearSuelo() {
        let suelo = SKNode()
        suelo.position = CGPoint(x: -self.frame.midX, y: -self.frame.height / 2)
        suelo.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        // el suelo se tiene que estar quieto
        suelo.physicsBody!.isDynamic = false
        
        // Categoría para collision
        suelo.physicsBody!.categoryBitMask = tipoNodo.tuboSuelo.rawValue
        // Colisiona con la mosquita
        suelo.physicsBody!.collisionBitMask = tipoNodo.mosquita.rawValue
        // contacto con el suelo
        suelo.physicsBody!.contactTestBitMask = tipoNodo.mosquita.rawValue
        
        self.addChild(suelo)
    }
    
    func crearFondoConAnimacion() {
        // Textura para el fondo
        let texturaFondo = SKTexture(imageNamed: "fondo.png")
        
        // Acciones del fondo (para hacer ilusión de movimiento)
        // Desplazamos en el eje de las x cada 0.3s
        let movimientoFondo = SKAction.move(by: CGVector(dx: -texturaFondo.size().width, dy: 0), duration: 4)
        
        let movimientoFondoOrigen = SKAction.move(by: CGVector(dx: texturaFondo.size().width, dy: 0), duration: 0)
        
        // repetimos hasta el infinito
        let movimientoInfinitoFondo = SKAction.repeatForever(SKAction.sequence([movimientoFondo, movimientoFondoOrigen]))
        
        // Necesitamos más de un fondo para que no se vea la pantalla en negro
        
        // contador de fondos
        var i: CGFloat = 0
        
        while i < 2 {
            // Le ponemos la textura al fondo
            fondo = SKSpriteNode(texture: texturaFondo)
            
            // Indicamos la posición inicial del fondo
            fondo.position = CGPoint(x: texturaFondo.size().width * i, y: self.frame.midY)
            
            // Estiramos la altura de la imagen para que se adapte al alto de la pantalla
            fondo.size.height = self.frame.height
            
            // Indicamos zPosition para que quede detrás de todo
            fondo.zPosition = -1
            
            // Aplicamos la acción
            fondo.run(movimientoInfinitoFondo)
            // Ponemos el fondo en la escena
            self.addChild(fondo)
            
            // Incrementamos contador
            i += 1
        }
        
    }
    
    func crearMosquitaConAnimacion() {
        
        // Asignamos las texturas de la mosquita
        texturaProtagonista1 = SKTexture(imageNamed: "mato_1.png")
        texturaProtagonista2 = SKTexture(imageNamed: "mato_2.png")
        texturaProtagonista3 = SKTexture(imageNamed: "mato_3.png")
        texturaProtagonista4 = SKTexture(imageNamed: "mato_4.png")
        
        // Creamos la animación que va intercambiando las texturas
        // para que parezca que la mosca va volando
        
        // Acción que indica las texturas y el tiempo de cada uno
        let animacion = SKAction.animate(with: [texturaProtagonista1, texturaProtagonista2, texturaProtagonista3, texturaProtagonista4], timePerFrame: 0.2)
        
        // Creamos la acción que hace que se vaya cambiando de textura
        // infinitamente
        let animacionInfinita = SKAction.repeatForever(animacion)
        
        // Le ponemos la textura inicial al nodo
        protagonista = SKSpriteNode(texture: texturaProtagonista1)
        // Posición inicial en la que ponemos a la mosquita
        // (0.0, 0.0) es el medio de la pantalla
        // Se puede poner 0.0, 0.0 o bien con referencia a la pantalla
        protagonista.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        // Le damos propiedades físicias a nuestra mosquita
        // Le damos un cuerpo circular
        protagonista.physicsBody = SKPhysicsBody(circleOfRadius: texturaProtagonista1.size().height / 2)
        
        // Al inicial la mosquita está quieta
        protagonista.physicsBody?.isDynamic = false
        
        // Añadimos su categoría
        protagonista.physicsBody!.categoryBitMask = tipoNodo.mosquita.rawValue
        
        // Indicamos la categoría de colisión con el suelo/tubos
        protagonista.physicsBody!.collisionBitMask = tipoNodo.tuboSuelo.rawValue
        
        // Hace contacto con (para que nos avise)
        protagonista.physicsBody!.contactTestBitMask = tipoNodo.tuboSuelo.rawValue | tipoNodo.huecoTubos.rawValue
        
        // Aplicamos la animación a la mosquita
        protagonista.run(animacionInfinita)
        
        protagonista.zPosition = 0
        
        // Ponemos la mosquita en la escena
        self.addChild(protagonista)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        if gameOver == false {
            // En cuanto el usuario toque la pantalla le damos dinámica a la mosquita (caerá)
            protagonista.physicsBody!.isDynamic = true
            
            // Le damos una velocidad a la mosquita para que la velocidad al caer sea constante
            protagonista.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            
            // Le aplicamos un impulso a la mosquita para que suba cada vez que pulsemos la pantalla
            // Y así poder evitar que se caiga para abajo
            protagonista.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 500))
        } else {
            // si toca la pantalla cuando el juego ha acabado, lo reiniciamos para volver a jugar
            gameOver = false
            puntuacion = 0
            self.speed = 1
            self.removeAllChildren()
            reiniciar()
        }
        
    }
    
    // Función para tratar las colisiones o contactos de nuestros nodos
    func didBegin(_ contact: SKPhysicsContact) {
        // en contact tenemos bodyA y bodyB que son los cuerpos que hicieron contacto
        let cuerpoA = contact.bodyA
        let cuerpoB = contact.bodyB
        // Miramos si la mosca ha pasado por el hueco
        if (cuerpoA.categoryBitMask == tipoNodo.mosquita.rawValue && cuerpoB.categoryBitMask == tipoNodo.huecoTubos.rawValue) || (cuerpoA.categoryBitMask == tipoNodo.huecoTubos.rawValue && cuerpoB.categoryBitMask == tipoNodo.mosquita.rawValue) {
            puntuacion += 1
            labelPuntuacion.text = String(puntuacion)
        } else {
            // si no pasa por el hueco es porque ha tocado el suelo o una tubería
            // deberemos acabar el juego
            gameOver = true
            // Frenamos todo
            self.speed = 0
            // Paramos el timer
            timer.invalidate()
            labelPuntuacion.text = "Game Over"
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

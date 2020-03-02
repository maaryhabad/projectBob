//
//  GameScene.swift
//  ProjectBob
//
//  Created by Mariana Beilune Abad on 19/02/20.
//  Copyright © 2020 Mariana Beilune Abad. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var stickActive: Bool = false
    
    var base: SKSpriteNode!
    var ball: SKSpriteNode!
    var player: SKSpriteNode!
    
    var velocityX: CGFloat = 0.0
    var velocityY: CGFloat = 0.0
    
    var backLabel: SKNode!
    var label: SKNode!

    
    let cam = SKCameraNode()
    
    var joystickContainer: SKNode!
    var backgroundNode: SKSpriteNode!
    
    var currentBackgroundNode: SKSpriteNode!
    var nextBackgroundNode: SKSpriteNode!
 
    var lastUpdate: TimeInterval!
    
    
    
    override func didMove(to view: SKView) {
        
        joystickContainer = childNode(withName: "joystick")
        backLabel = childNode(withName: "backLabel")
        label = childNode(withName: "label")
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        label = InteractiveLabelNode(with: "Olá, policial. Por favor, clique para inserir seu nome.")
        label.position = CGPoint(x: -825, y: 500)

        self.addChild(label)
//        backLabel.setValue(15, forKey: "cornerRadius")
        
        player = childNode(withName: "player") as! SKSpriteNode
        base = joystickContainer.childNode(withName: "arrow") as! SKSpriteNode
        ball = joystickContainer.childNode(withName: "knob") as! SKSpriteNode
        
        self.backgroundNode = SKSpriteNode()
        player.yScale =  8
        player.position =  .zero
        self.addChild(backgroundNode)
        createBackground()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
//        velocityX = velocityX/2
        
        if lastUpdate == nil {
            lastUpdate = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdate
        
        if velocityX < 0 {
            player.xScale = 8
        }  else {
            player.xScale = -8
        }
        
        lastUpdate = currentTime
        
        let distanceMoved = CGFloat(deltaTime) * self.velocityX * 10
        
        if (currentBackgroundNode.position.x - distanceMoved) <= 0 {
            currentBackgroundNode.position.x -= distanceMoved
            nextBackgroundNode.position.x -= distanceMoved
            
            if currentBackgroundNode.position.x <= -self.scene!.size.width {
                self.updateBackground()
            }
        }
    }
    
    func updateBackground() {
        let pivot = self.currentBackgroundNode!
        self.currentBackgroundNode = self.nextBackgroundNode
        
        
        self.nextBackgroundNode = pivot
        
        self.nextBackgroundNode.texture = self.getRandomTexture()
        
        self.nextBackgroundNode.position.x = self.scene!.size.width
        self.currentBackgroundNode.position.x = .zero
    }
    
    func createBackground() {
        var backgroundTextures: [SKTexture] = []
        
        for i in 1 ... 4 {
            let texture = SKTexture(imageNamed: "background\(i)")
            backgroundTextures.append(texture)
        }
        
        print(backgroundTextures)
        
        var selectedBackgroundTexture = backgroundTextures.randomElement()
        var nextBackgroundTexture = backgroundTextures.filter { $0  != selectedBackgroundTexture } .randomElement()
        
        let selectedBackgroundNode =  SKSpriteNode(texture: selectedBackgroundTexture)
        let nextBackgroundNode =  SKSpriteNode(texture: nextBackgroundTexture)
     
        selectedBackgroundNode.zPosition = -10
        selectedBackgroundNode.scale(to: self.scene!.size)
        selectedBackgroundNode.position = .zero
        
        nextBackgroundNode.zPosition = -10
        nextBackgroundNode.scale(to: self.scene!.size)
        nextBackgroundNode.position = CGPoint(x: self.scene!.size.width, y: 0)
        
        self.backgroundNode.addChild(selectedBackgroundNode)
        self.backgroundNode.addChild(nextBackgroundNode)
        
        self.currentBackgroundNode  = selectedBackgroundNode
        self.nextBackgroundNode =  nextBackgroundNode
    }
    
    func getRandomTexture() -> SKTexture {
        
        var backgroundTextures: [SKTexture] = []
        
        for i in 1 ... 4 {
            let texture = SKTexture(imageNamed: "background\(i)")
            backgroundTextures.append(texture)
        }
        return backgroundTextures.randomElement()!
    }
    

        func touchDown(atPoint pos : CGPoint) {
            
        }
        
        func touchMoved(toPoint pos : CGPoint) {
            
        }
        
        func touchUp(atPoint pos : CGPoint) {
           
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches {
                let location = t.location(in: self)
                let locationPositionInBall = ball.parent!.convert(location, from: self)
                print("location",locationPositionInBall)
                print("frame", ball.frame)
                if ball.frame.contains(locationPositionInBall) {
                    stickActive = true
                } else {
                    stickActive = false
                }
                
                var alert = UIAlertController(title: "Nome do profissional", message: "", preferredStyle: .alert)
                
                alert.addTextField(configurationHandler: { (textField) -> Void in
                    textField.text = "Escreva seu nome aqui"
                })
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    let textField  = alert.textFields![0] as UITextField
                    print("Nome do policial: \(textField.text)")
                    self.label = InteractiveLabelNode(with: "")
                    self.label = InteractiveLabelNode(with: "Oi! Eu sou o Bob, e junto com o \(textField.text) vamos conversar e jogar um pouco.")
                }))
                
                self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)

            }

        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches {
                let location = t.location(in: self)
                var angle: CGFloat = 0.0
                self.touchMoved(toPoint: location)
    //            print(stickActive)
                if stickActive == true {
                    if let joystickContainer = base.parent {
                        
                        let basePositionInScene = self.convert(base.position, from: joystickContainer)
                        let v = CGVector(dx: location.x - basePositionInScene.x, dy: location.y - basePositionInScene.y)
                        angle = atan2(v.dy, v.dx)
                        
                        var deg = angle * CGFloat(180/CGFloat(Double.pi))
                        
                        if deg < 0 {
                            // Deg é negativo então somamos em +180 pra ter um offset ajustado da posição do  joystick
                            deg = 180 + (180 + deg)
                        }
    //                    print(deg)
                        
                        let distanceFromCenter: CGFloat = base.frame.size.height / 2
                        
                        
    //                    var offsetedAngle = angle
    //                    if offsetedAngle < 0 {
    //                        offsetedAngle = CGFloat.pi + (CGFloat.pi + angle )
    //                    }
                        let xDist: CGFloat = sin(angle - 1.57079633) * distanceFromCenter
                        let yDist: CGFloat = cos(angle - 1.57079633) * distanceFromCenter
                        let locationPositionInBall = ball.parent!.convert(location, from: self)
                        if (base.frame.contains(locationPositionInBall)) {
                            ball.position = locationPositionInBall
                        } else {
                            ball.position = CGPoint(x: base.position.x - xDist, y: base.position.y + yDist)
                        }
                        
                    } else {
                        print("Joystick container not found")
                    }
                    
                    velocityX = ball.position.x - base.position.x
                    velocityY = ball.position.y - base.position.y
                    
    //                player.zRotation = angle
                }
            }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            if (stickActive == true) {
                let move: SKAction = SKAction.move(to: base.position, duration: 0.2)
                move.timingMode = .easeOut
                ball.run(move)
                velocityX = 0.0
                velocityY = 0.0
            }
        }
}

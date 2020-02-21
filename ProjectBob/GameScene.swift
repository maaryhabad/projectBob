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
    
    var label: SKNode!
    
    let cam = SKCameraNode()
    
    var joystickContainer: SKNode!
 
    override func didMove(to view: SKView) {
        
        joystickContainer = childNode(withName: "joystick")
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        
        label = InteractiveLabelNode(with: "esse é um teste")
        label.position = CGPoint(x: -750, y: 530)
        self.camera = cam

        self.addChild(label)
        player = childNode(withName: "player") as! SKSpriteNode
        base = joystickContainer.childNode(withName: "arrow") as! SKSpriteNode
        ball = joystickContainer.childNode(withName: "knob") as! SKSpriteNode
        createBackground()
        
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
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
//        velocityX = velocityX/2
        self.player.position.x += velocityX * 0.05
        self.player.position.y += velocityY * 0.1
        
        if velocityX < 0 {
            player.xScale = 8
            player.yScale = 8
        }  else {
            player.xScale = -8
            player.yScale = 8
        }
        cam.position.x = player.position.x
        joystickContainer.position = CGPoint(x: cam.position.x - 300, y: cam.position.y - 100)
    }
    
    func createBackground() {
        var backgroundTextures: [SKTexture] = []
        
        for i in 0 ... 4 {
            let texture = SKTexture(imageNamed: "background\(i)")
            backgroundTextures.append(texture)
        }
        print(backgroundTextures)
        var selectedBackground = backgroundTextures.randomElement()
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: selectedBackground)
            background.zPosition = -10
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: (selectedBackground?.size().width)! * CGFloat(i) - CGFloat(i), y: 100)
            addChild(background)
        }
    }
}

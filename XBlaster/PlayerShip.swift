//
//  PlayerShip.swift
//  XBlaster
//
//  Created by Scott Gardner on 6/18/15.
//  Copyright (c) 2015 Scott Gardner. All rights reserved.
//

import SpriteKit

class PlayerShip: Entity {
  
  let ventingPlasma = SKEmitterNode(fileNamed: "ventingPlasma.sks")
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(entityPosition: CGPoint) {
    let entityTexture = PlayerShip.generateTexture()!
    super.init(position: entityPosition, texture: entityTexture)
    name = "playerShip"
    ventingPlasma.hidden = true
    addChild(ventingPlasma)
    configureCollisionBody()
  }
  
  override class func generateTexture() -> SKTexture? {
    struct SharedTexture {
      static var texture = SKTexture()
      static var onceToken: dispatch_once_t = 0
    }
    
    dispatch_once(&SharedTexture.onceToken) {
      let mainShip = SKLabelNode(fontNamed: arialFontName)
      mainShip.name = "mainShip"
      mainShip.fontSize = 40.0
      mainShip.fontColor = SKColor.whiteColor()
      mainShip.text = "▲"
      
      let wings = SKLabelNode(fontNamed: "PF TempestaSeven")
      wings.name = "wings"
      wings.fontSize = 40.0
      wings.text = "< >"
      wings.fontColor = SKColor.whiteColor()
      wings.position = CGPoint(x: 1, y: 7)
      wings.zRotation = CGFloat(180).degreesToRadians()
      mainShip.addChild(wings)
      
      let textureView = SKView()
      SharedTexture.texture = textureView.textureFromNode(mainShip)
      SharedTexture.texture.filteringMode = .Nearest
    }
    
    return SharedTexture.texture
  }
  
  func createEngine() {
    let engineEmitter = SKEmitterNode(fileNamed: "engine.sks")
    engineEmitter.name = "engineEmitter"
    engineEmitter.position = CGPoint(x: 1, y: -4)
    addChild(engineEmitter)
    
    let mainScene = scene as! GameScene
    engineEmitter.targetNode = mainScene.particleLayerNode
  }
  
  func configureCollisionBody() {
    physicsBody = SKPhysicsBody(circleOfRadius: 15.0)
    physicsBody?.affectedByGravity = false
    physicsBody?.categoryBitMask = ColliderType.Player
    physicsBody?.collisionBitMask = 0
    physicsBody?.contactTestBitMask = ColliderType.Enemy
  }
  
  override func collidedWith(body: SKPhysicsBody, contact: SKPhysicsContact) {
    let mainScene = scene as! GameScene
    mainScene.playExplodeSound()
    health -= 5.0
    
    ventingPlasma.hidden = health > 30.0
    
    if health < 0.0 {
      health = 0.0
    }
  }
  
}

//
//  Bullet.swift
//  XBlaster
//
//  Created by Scott Gardner on 6/18/15.
//  Copyright (c) 2015 Scott Gardner. All rights reserved.
//

import SpriteKit

class Bullet: Entity {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(entityPosition: CGPoint) {
    let entityTexture = Bullet.generateTexture()!
    super.init(position: entityPosition, texture: entityTexture)
    name = "bullet"
    configureCollisionBody()
  }
  
  override class func generateTexture() -> SKTexture? {
    struct SharedTexture {
      static var texture = SKTexture()
      static var onceToken: dispatch_once_t = 0
    }
    
    dispatch_once(&SharedTexture.onceToken) {
      let bullet = SKLabelNode(fontNamed: arialFontName)
      bullet.name = "bullet"
      bullet.fontSize = 40.0
      bullet.fontColor = SKColor.whiteColor()
      bullet.text = "•"
      
      let textureView = SKView()
      SharedTexture.texture = textureView.textureFromNode(bullet)
      SharedTexture.texture.filteringMode = .Nearest
    }
    
    return SharedTexture.texture
  }
  
  func configureCollisionBody() {
    physicsBody = SKPhysicsBody(circleOfRadius: 5.0)
    physicsBody?.affectedByGravity = false
    physicsBody?.categoryBitMask = ColliderType.Bullet
    physicsBody?.collisionBitMask = 0
    physicsBody?.contactTestBitMask = ColliderType.Enemy
  }
  
  override func collidedWith(body: SKPhysicsBody, contact: SKPhysicsContact) {
    removeFromParent()
  }
  
}

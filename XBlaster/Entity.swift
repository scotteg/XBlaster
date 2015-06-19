//
//  Entity.swift
//  XBlaster
//
//  Created by Scott Gardner on 6/18/15.
//  Copyright (c) 2015 Scott Gardner. All rights reserved.
//

import SpriteKit

class Entity: SKSpriteNode {
  
  struct ColliderType {
    static var Player: UInt32 = 1
    static var Enemy: UInt32 = 2
    static var Bullet: UInt32 = 4
  }
  
  var direction = CGPointZero
  var health = 100.0
  var maxHealth = 100.0
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(position: CGPoint, texture: SKTexture) {
    super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
    self.position = position
  }
  
  // To be overridden by subclasses
  class func generateTexture() -> SKTexture? { return nil }
  func update(delta: NSTimeInterval) { }
  func collidedWith(body: SKPhysicsBody, contact: SKPhysicsContact) { }
  
}

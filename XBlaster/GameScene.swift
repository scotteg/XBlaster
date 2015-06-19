//
//  GameScene.swift
//  XBlaster
//
//  Created by Scott Gardner on 6/17/15.
//  Copyright (c) 2015 Scott Gardner. All rights reserved.
//

import SpriteKit

let arialFontName = "Arial"
let editUndoLineFontName = "Edit Undo Line BRK"

class GameScene: SKScene {
  
  enum GameState {
    case GameRunning, GameOver
  }
  
  enum EnemyType {
    case A, B
  }
  
  let playerLayerNode = SKNode()
  let hudLayerNode = SKNode()
  let bulletLayerNode = SKNode()
  let enemyLayerNode = SKNode()
  let playableRect: CGRect
  let hudHeight: CGFloat = 90.0
  let scoreLabel = SKLabelNode(fontNamed: editUndoLineFontName)
  lazy var scoreFlashAction: SKAction = {
    return SKAction.sequence([
      SKAction.scaleTo(1.5, duration: 0.1),
      SKAction.scaleTo(1.0, duration: 0.1)])
  }()
  let healthBarString: NSString = "===================="
  let playerHealthLabel = SKLabelNode(fontNamed: arialFontName)
  var playerShip: PlayerShip!
  var deltaPoint = CGPointZero
  var bulletInterval: NSTimeInterval = 0.0
  var lastUpdateTime: NSTimeInterval = 0.0
  var deltaTime: NSTimeInterval = 0.0
  var score = 0
  var gameState: GameState = .GameOver
  let gameOverLabel = SKLabelNode(fontNamed: editUndoLineFontName)
  let tapScreenPulseAction = SKAction.repeatActionForever(SKAction.sequence([
    SKAction.fadeOutWithDuration(1.0),
    SKAction.fadeInWithDuration(1.0)
  ]))
  let tapScreenLabel = SKLabelNode(fontNamed: editUndoLineFontName)
  let particleLayerNode = SKNode()
  let laserSound = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false)
  let explodeSound = SKAction.playSoundFileNamed("explode.wav", waitForCompletion: false)
  
  override init(size: CGSize) {
    let maxAspectRatio: CGFloat = 16.0/9.0 // iPhone 5
    let maxAspectRatioWidth = size.height / maxAspectRatio
    let playableMargin = (size.width - maxAspectRatioWidth) / 2.0
    playableRect = CGRect(x: playableMargin, y: 0.0, width: maxAspectRatioWidth, height: size.height - hudHeight)
    super.init(size: size)
    
    gameState = .GameRunning
    
    configureSceneLayers()
    configureUI()
    configureEntities()
    SKTAudio.sharedInstance().playBackgroundMusic("bgMusic.mp3")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToView(view: SKView) {
    physicsWorld.gravity = CGVectorMake(0.0, 0.0)
    physicsWorld.contactDelegate = self
  }
  
  override func update(currentTime: NSTimeInterval) {
    var newPoint = playerShip.position + deltaPoint
    newPoint.x.clamp(CGRectGetMinX(playableRect), CGRectGetMaxX(playableRect))
    newPoint.y.clamp(CGRectGetMinY(playableRect), CGRectGetMaxY(playableRect))
    playerShip.position = newPoint
    deltaPoint = CGPointZero
    
    switch gameState {
    case .GameRunning:
      shootBullet(currentTime)
      
      for node in enemyLayerNode.children {
        let enemy = node as! Enemy
        enemy.update(deltaTime)
      }
      
      playerHealthLabel.fontColor = SKColor(red: CGFloat(2.0 * (1.0 - playerShip.health / 100.0)), green: CGFloat(2.0 * playerShip.health / 100.0), blue: 0.0, alpha: 1.0)
      let healthBarLength = Double(healthBarString.length) * playerShip.health / 100.0
      playerHealthLabel.text = healthBarString.substringToIndex(Int(healthBarLength))
      
      if playerShip.health <= 0 {
        gameState = .GameOver
      }
    case .GameOver:
      if gameOverLabel.parent == nil {
        bulletLayerNode.removeAllChildren()
        enemyLayerNode.removeAllChildren()
        playerShip.removeFromParent()
        hudLayerNode.addChild(gameOverLabel)
        hudLayerNode.addChild(tapScreenLabel)
        tapScreenLabel.runAction(tapScreenPulseAction)
      }
      
      gameOverLabel.fontColor = SKColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    }
  }
  
  func shootBullet(currentTime: NSTimeInterval) {
    if lastUpdateTime > 0 {
      deltaTime = currentTime - lastUpdateTime
    } else {
      deltaTime = 0.0
    }
    
    lastUpdateTime = currentTime
    bulletInterval += deltaTime
    
    if bulletInterval > 0.15 {
      bulletInterval = 0.0
      
      let bullet = Bullet(entityPosition: playerShip.position)
      playLaserSound()
      bulletLayerNode.addChild(bullet)
      
      bullet.runAction(SKAction.sequence([
        SKAction.moveByX(0.0, y: size.height, duration: 1.0),
        SKAction.removeFromParent()
      ]))
    }
  }
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    if gameState == .GameOver {
      restartGame()
    }
  }
  
  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    let touch = touches.first as! UITouch
    let currentPoint = touch.locationInNode(self)
    let previousTouchLocation = touch.previousLocationInNode(self)
    deltaPoint = currentPoint - previousTouchLocation
  }
  
  override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    deltaPoint = CGPointZero
  }
  
  override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    deltaPoint = CGPointZero
  }
  
  func configureSceneLayers() {
    playerLayerNode.zPosition = 50.0
    hudLayerNode.zPosition = 100.0
    bulletLayerNode.zPosition = 25.0
    enemyLayerNode.zPosition = 35.0
    particleLayerNode.zPosition = 10.0
    
    let starfieldNode = SKNode()
    starfieldNode.name = "starfieldNode"
    starfieldNode.addChild(starfieldEmitterNode(speed: -48.0, lifetime: size.height / 23.0, scale: 0.2, birthrate: 1.0, color: SKColor.lightGrayColor()))
    
    let midEmitterNode = starfieldEmitterNode(speed: -32.0, lifetime: size.height / 10.0, scale: 0.14, birthrate: 2.0, color: SKColor.grayColor())
    midEmitterNode.zPosition = -10.0
    
    let distantEmitterNode = starfieldEmitterNode(speed: -20.0, lifetime: size.height / 5.0, scale: 0.1, birthrate: 5.0, color: SKColor.darkGrayColor())
    
    addChild(playerLayerNode)
    addChild(hudLayerNode)
    addChild(bulletLayerNode)
    addChild(enemyLayerNode)
    addChild(starfieldNode)
    addChild(particleLayerNode)
    starfieldNode.addChild(midEmitterNode)
    starfieldNode.addChild(distantEmitterNode)
  }
  
  func configureUI() {
    let backgroundColor = SKColor.blackColor()
    let backgroundSize = CGSize(width: size.width, height: hudHeight)
    let hudBarBackground = SKSpriteNode(color: backgroundColor, size: backgroundSize)
    hudBarBackground.position = CGPoint(x: 0.0, y: size.height - hudHeight)
    hudBarBackground.anchorPoint = CGPointZero
    hudLayerNode.addChild(hudBarBackground)
    
    scoreLabel.fontSize = 50.0
    scoreLabel.text = "Score: 0"
    scoreLabel.name = "scoreLabel"
    scoreLabel.verticalAlignmentMode = .Center
    scoreLabel.position = CGPoint(x: size.width / 2.0, y: size.height - CGRectGetHeight(scoreLabel.frame) + 3.0)
    hudLayerNode.addChild(scoreLabel)
//    scoreLabel.runAction(SKAction.repeatAction(scoreFlashAction, count: 20))
    
    let playerHealthBackgroundLabel = SKLabelNode(fontNamed: arialFontName)
    playerHealthBackgroundLabel.name = "playerHealthBackground"
    playerHealthBackgroundLabel.fontColor = SKColor.darkGrayColor()
    playerHealthBackgroundLabel.fontSize = 50.0
    playerHealthBackgroundLabel.text = healthBarString as! String
    playerHealthBackgroundLabel.horizontalAlignmentMode = .Left
    playerHealthBackgroundLabel.verticalAlignmentMode = .Top
    playerHealthBackgroundLabel.zPosition = 0.0
    playerHealthBackgroundLabel.position = CGPoint(x: CGRectGetMinX(playableRect), y: size.height - CGFloat(hudHeight) + CGRectGetHeight(playerHealthBackgroundLabel.frame))
    hudLayerNode.addChild(playerHealthBackgroundLabel)
    
    playerHealthLabel.name = "playerHealthLabel"
    playerHealthLabel.fontColor = SKColor.greenColor()
    playerHealthLabel.fontSize = 50.0
    playerHealthLabel.text = healthBarString.substringToIndex(20 * 75 / 100)
    playerHealthLabel.horizontalAlignmentMode = .Left
    playerHealthLabel.verticalAlignmentMode = .Top
    playerHealthLabel.zPosition = 1.0
    playerHealthLabel.position = CGPoint(x: CGRectGetMinX(playableRect), y: size.height - CGFloat(hudHeight) + CGRectGetHeight(playerHealthLabel.frame))
    hudLayerNode.addChild(playerHealthLabel)
    
    gameOverLabel.name = "gameOverLabel"
    gameOverLabel.fontSize = 75.0
    gameOverLabel.fontColor = SKColor.whiteColor()
    gameOverLabel.horizontalAlignmentMode = .Center
    gameOverLabel.verticalAlignmentMode = .Center
    gameOverLabel.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
    gameOverLabel.text = "GAME OVER"
    
    tapScreenLabel.name = "tapScreenLabel"
    tapScreenLabel.fontSize = 22.0
    tapScreenLabel.fontColor = SKColor.whiteColor()
    tapScreenLabel.horizontalAlignmentMode = .Center
    tapScreenLabel.verticalAlignmentMode = .Center
    tapScreenLabel.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0 - 100.0)
    tapScreenLabel.text = "Tap Screen to Restart"
  }
  
  func configureEntities() {
    playerShip = PlayerShip(entityPosition: CGPoint(x: size.width / 2.0, y: 100.0))
    playerLayerNode.addChild(playerShip)
    playerShip.createEngine()
    addEnemyOfType(.A, count: 3)
    addEnemyOfType(.B, count: 3)
  }
  
  func addEnemyOfType(type: EnemyType, count: Int) {
    for _ in 0...count {
      let enemy: Enemy
      
      switch type {
      case .A:
        enemy = EnemyA(entityPosition: CGPoint(x: CGFloat.random(min: playableRect.origin.x, max: playableRect.size.width), y: playableRect.size.height), playableRect: playableRect)
      case .B:
        enemy = EnemyB(entityPosition: CGPoint(x: CGFloat.random(min: playableRect.origin.x, max: playableRect.size.width), y: playableRect.size.height), playableRect: playableRect)
      }
      
      let initialWaypoint = CGPoint(x: CGFloat.random(min: playableRect.origin.x, max: playableRect.size.width), y: CGFloat.random(min: 0.0, max: playableRect.size.height))
      enemy.aiSteering.updateWaypoint(initialWaypoint)
      enemyLayerNode.addChild(enemy)
    }
  }
  
  func increaseScoreBy(increment: Int) {
    score += increment
    scoreLabel.text = "Score: \(score)"
    scoreLabel.removeAllActions()
    scoreLabel.runAction(scoreFlashAction)
  }
  
  func restartGame() {
    gameState = .GameRunning
    configureEntities()
    score = 0
    scoreLabel.text = "Score: 0"
    playerShip.health = playerShip.maxHealth
    playerShip.position = CGPoint(x: size.width / 2.0, y: 100.0)
    gameOverLabel.removeFromParent()
    tapScreenLabel.removeAllActions()
    tapScreenLabel.removeFromParent()
  }
  
  func starfieldEmitterNode(#speed: CGFloat, lifetime: CGFloat, scale: CGFloat, birthrate: CGFloat, color: SKColor) -> SKEmitterNode {
    let star = SKLabelNode(fontNamed: "Helvetica")
    star.fontSize = 80.0
    star.text = "✦"
    let textureView = SKView()
    let texture = textureView.textureFromNode(star)
    texture.filteringMode = .Nearest
    
    let emitterNode = SKEmitterNode()
    emitterNode.particleTexture = texture
    emitterNode.particleBirthRate = birthrate
    emitterNode.particleColor = color
    emitterNode.particleLifetime = lifetime
    emitterNode.particleSpeed = speed
    emitterNode.particleScale = scale
    emitterNode.particleColorBlendFactor = 1.0
    emitterNode.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMaxY(frame))
    emitterNode.particlePositionRange = CGVector(dx: CGRectGetMaxX(frame), dy: 0.0)
    emitterNode.particleSpeedRange = 16.0
    emitterNode.particleRotationRange = 16.0
    
    emitterNode.particleAction = SKAction.repeatActionForever(SKAction.sequence([
      SKAction.rotateByAngle(CGFloat(-M_PI_4), duration: 1.0),
      SKAction.rotateByAngle(CGFloat(M_PI_4), duration: 1.0),
    ]))
    
    let twinkles = 20
    let colorSequence = SKKeyframeSequence(capacity: twinkles * 2)
    let twinkleTime = 1.0 / CGFloat(twinkles)
    
    for i in 0..<twinkles {
      colorSequence.addKeyframeValue(SKColor.whiteColor(), time: CGFloat(i) * 2.0 * twinkleTime / 2.0)
      colorSequence.addKeyframeValue(SKColor.yellowColor(), time: CGFloat(i) * 2.0 * twinkleTime / 2.0)
    }
    
    emitterNode.particleColorSequence = colorSequence
    emitterNode.advanceSimulationTime(NSTimeInterval(lifetime))
    return emitterNode
  }
  
  func playLaserSound() {
    runAction(laserSound)
  }
  
  func playExplodeSound() {
    runAction(explodeSound)
  }
  
}

extension GameScene: SKPhysicsContactDelegate {
  
  func didBeginContact(contact: SKPhysicsContact) {
    if let enemyNode = contact.bodyA.node {
      if enemyNode.name == "enemy" {
        let enemy = enemyNode as! Entity
        enemy.collidedWith(contact.bodyA, contact: contact)
      }
    }
    
    if let playerNode = contact.bodyB.node {
      if playerNode.name == "playerShip" || playerNode.name == "bullet" {
        let player = playerNode as! Entity
        player.collidedWith(contact.bodyB, contact: contact)
      }
    }
  }
  
}

/*
* Copyright (c) 2013-2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import SpriteKit

class EnemyA: Enemy, SKPhysicsContactDelegate {
  
  override class func generateTexture() -> SKTexture? {
    
    struct SharedTexture {
      static var texture = SKTexture()
      static var onceToken: dispatch_once_t = 0
    }
    
    dispatch_once(&SharedTexture.onceToken, {
      let mainShip:SKLabelNode = SKLabelNode(fontNamed: "Arial")
      mainShip.name = "mainship"
      mainShip.fontSize = 40
      mainShip.fontColor = SKColor.whiteColor()
      mainShip.text = "(=⚇=)"
      
      let textureView = SKView()
      SharedTexture.texture = textureView.textureFromNode(mainShip)
      SharedTexture.texture.filteringMode = .Nearest
      })
    
    return SharedTexture.texture
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  init(entityPosition: CGPoint, playableRect: CGRect) {
  
    let entityTexture = EnemyA.generateTexture()!
    super.init(entityPosition: entityPosition, texture: entityTexture, playableRect: playableRect)

    name = "enemy"
    score = 225

    Enemy.loadSharedAssets()
    configureCollisionBody()
    
    scoreLabel.text = String(score)
    
    // Set a default waypoint. The actual waypoint will be called by whoever created this instance
    aiSteering = AISteering(entity: self, waypoint: CGPointZero)
  }
  
}

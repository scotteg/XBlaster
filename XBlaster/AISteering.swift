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

// This small class implements something called Autonomous Steering. It is an approach to 
// steering objects in a natural feeling way. This class implements the Seek steering behaviour.
// Detailed information on the Seek behaviour and other steering behaviours can be found at
// http://www.red3d.com/cwr/steer/SeekFlee.html
class AISteering {
  
  weak var entity: Entity!
  var maxVelocity: CGFloat = 10.0
  var maxSteeringForce: CGFloat = 0.06
  var waypointRadius: CGFloat = 50.0
  var waypoint:CGPoint = CGPointZero
  var currentPosition = CGPointZero
  var currentDirection = CGPointZero
  var waypointReached = false
  var faceDirectionOfTravel = false
  
  init(entity: Entity, waypoint: CGPoint) {
    self.entity = entity
    self.waypoint = waypoint
  }
  
  func update(delta:CFTimeInterval) {
    
    // Get the entities current position
    currentPosition = entity.position
    
    // Work out the vector to the current waypoint from the entities current position
    var desiredDirection:CGPoint = waypoint - currentPosition
    
    // Calculate the distance from the entity to the waypoint
    var distanceToWaypoint:CGFloat = desiredDirection.length()
    
    // Update the desired location of the entity based on the maxVelocity that has been 
    // defined and the distance to the waypoint
    desiredDirection = desiredDirection * maxVelocity / distanceToWaypoint
    
    // Calculate the steering force needed to turn towards the waypoint. We turn the entity over 
    // time based on the maxSteeringForce to get a natural steering movement rather than snap 
    // immediately to point directly towards the waypoint
    var force:CGPoint = desiredDirection - currentDirection
    var steeringForce:CGPoint = force * maxSteeringForce / maxVelocity
    
    // Calculate the new direction the entity should move in based on the current direction 
    // and the maximum steering force that can be applied. A higher steering force will cause
    // the entity to turn more quickly
    currentDirection = currentDirection + steeringForce

    // Calculate the entities new position by adding it's newly calculated current direction to its
    // current position and then set that as the entities position
    currentPosition = currentPosition + currentDirection
    entity.position = currentPosition

    // If the new position is within the defined waypoint radius then marked the waypoint as reached.
    // The smaller the waypointRadius the longer it will take for the entity to reach it as it will
    // over shoot the waypoint and keep turning back until it gets with the waypointRaius from the
    // waypoint
    if distanceToWaypoint < waypointRadius {
      waypointReached = true
    }
  }

  // This method is used to set a new waypoint for the entity to steer towards
  func updateWaypoint(waypoint:CGPoint) {
    self.waypoint = waypoint
    waypointReached = false
  }
}
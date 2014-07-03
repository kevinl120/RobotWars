//
//  ProBot.m
//  RobotWar
//
//  Created by Kevin Li on 7/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//


#import "ProBot.h"


typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateMoving,
    RobotStateFighting,
    RobotStateTemporaryShooting // Replacement for shooting in the method bulletHitEnemy
};

@implementation ProBot {
    RobotState _currentRobotState;
    
    CGPoint _lastEnemyPosition;
    CGFloat _lastEnemyPositionTimestamp;
    
    CGFloat _lastHitEnemyTimestamp;
    
    NSInteger _hitCounter;
    
    BOOL _forward;
    BOOL _inAimingLoop;
    BOOL _currentlyFighting;
    
}

- (void) run {
    _forward = true;
    
    [self turnRobotLeft:90];
    [self moveAhead:68];
    [self turnRobotRight:90];
    [self turnGunRight:90];
    
    while (true) {
        
        if (_currentRobotState == RobotStateMoving) {
            _currentlyFighting = false;
            [self moveBasedOnStatus: 80];
            [self pointGunUpward];
            [self shoot];
        }
        
        if (_currentRobotState == RobotStateFighting) {
            
            if (self.currentTimestamp - _lastEnemyPositionTimestamp > 8.f) {
                _currentRobotState = RobotStateMoving;
            }
            _currentlyFighting=true;
            CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastEnemyPosition];
            
            if (angle >= 0) {
                [self turnGunRight:abs(angle)];
                [self shoot];
                [self moveBasedOnStatus:105];
            } else if (angle < 0) {
                [self turnGunLeft:abs(angle)];
                [self shoot];
                [self moveBasedOnStatus:105];
            }
            else {
                while (angle > 90 || angle < -90) {
                    angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastEnemyPosition];
                    [self moveOppositeToStatus:20];
                }
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                } else if (angle < 0) {
                    [self turnGunLeft:abs(angle)];
                }
                [self shoot];
            }
        }
        
        if (_currentRobotState == RobotStateTemporaryShooting) {
            if (self.currentTimestamp - _lastHitEnemyTimestamp  > 1.f) {
                _currentRobotState = RobotStateMoving;
            }
            [self shoot];
        }
    }
}


- (void) scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    if (_currentRobotState != RobotStateFighting) {
        [self cancelActiveAction];
    }
    
    _lastEnemyPosition = position;
    _lastEnemyPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFighting;
}


- (void) hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    [self cancelActiveAction];
    _forward = !_forward;
}


- (void) gotHit {
    if (_currentRobotState == RobotStateMoving) {
        [self moveBasedOnStatus:200];
        [self moveBasedOnStatus:200];
    }
}


- (void) bulletHitEnemy:(Bullet *)bullet {
    if (!_currentlyFighting) {
        _currentRobotState = RobotStateTemporaryShooting;
        _lastHitEnemyTimestamp = self.currentTimestamp;
        _hitCounter++;
    }
    if (_hitCounter >= 3) {
        _currentRobotState = RobotStateMoving;
        _hitCounter = 0;
    }
}


- (void) moveBasedOnStatus:(NSInteger)distanceToMove {
    if (_forward) {
        [self moveAhead:distanceToMove];
    } else {
        [self moveBack:distanceToMove];
    }
}


- (void) moveOppositeToStatus:(NSInteger)distanceToMove {
    if (_forward) {
        [self moveBack:distanceToMove];
    } else {
        [self moveAhead:distanceToMove];
    }
}


- (void) pointGunUpward {
    CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:ccp(250,25000000)];
    if (angle >= 0) {
        [self turnGunRight:abs(angle)];
    } else {
        [self turnGunLeft:abs(angle)];
    }
}




@end


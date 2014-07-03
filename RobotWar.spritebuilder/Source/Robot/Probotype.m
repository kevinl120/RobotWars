//
//  Probotype.m
//  RobotWar
//
//  Created by Kevin Li on 7/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//


#import "Probotype.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFighting,
    RobotStateSearching
};

@implementation Probotype {
    RobotState _currentRobotState;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    BOOL _forward;
    NSInteger _hitCounter;
    
}



- (void)run {
    _hitCounter = 0;
    _forward = true;
    [self turnRobotRight:8];
    NSInteger searchCount = 0;
    while (true) {
        if (_currentRobotState == RobotStateFighting) {
            
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                _currentRobotState = RobotStateSearching;
            } else {
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                } else {
                    [self turnGunLeft:abs(angle)];
                }
                [self shoot];
                _hitCounter++;
                if(_hitCounter == 2)
                {
                    [self turnRobotLeft:30];
                    [self moveAhead:50];
                    _hitCounter = 0;
                }
            }
        }
        
        if (_currentRobotState == RobotStateSearching) {
            if (_forward == true) {
                [self moveAhead:50];
                searchCount++;
                if(searchCount >= 10)
                {
                    [self turnRobotLeft:90];
                    searchCount = 0;
                }
            }
            else
            {
                [self moveBack:50];
                searchCount++;
                if(searchCount >= 10)
                {
                    [self turnRobotRight:90];
                    searchCount = 0;
                }
            }
        }
        
        if (_currentRobotState == RobotStateDefault) {
            if (_forward == true) {
                [self moveAhead:100];
            }
            else
            {
                [self moveBack:100];
            }
        }
    }
}


- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    if (_currentRobotState != RobotStateFighting) {
        [self cancelActiveAction];
    }
    
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFighting;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    if (_currentRobotState != RobotStateTurnaround) {
        [self cancelActiveAction];
        
        RobotState previousState = _currentRobotState;
        _currentRobotState = RobotStateTurnaround;
        
        // always turn to head straight away from the wall
        
        _forward = !_forward;
        if(_forward == true) {
            [self moveAhead:50];
        }
        else {
            [self moveBack:50];
        }
        
        _currentRobotState = previousState;
    }
}

- (void)gotHit {
    //NSInteger randomDistance = (arc4random() % 50);
    //randomDistance += 80;
    if(_forward == true) {
        //[self moveAhead:70];
        [self turnRobotLeft:30];
        [self moveAhead:60];
    }
    else {
        //[self moveBack:70];
        [self turnRobotRight:30];
        [self moveBack:60];
    }
    _currentRobotState = RobotStateFighting;
}

- (void)bulletHitEnemy:(Bullet*)bullet
{
    
}

@end

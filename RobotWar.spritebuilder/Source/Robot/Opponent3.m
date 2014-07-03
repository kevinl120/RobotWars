//
//  Opponent3.m
//  RobotWar
//
//  Created by Kevin Li on 7/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Opponent3.h"
#import "CCNode.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
    RobotStateSearching
};

@implementation Opponent3{
    RobotState _currentRobotState;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    CGSize _screenSize;
    BOOL _leftSide;
    int _screenWidth;
    int _screenHeight;
}

- (void)declareVariables {
    _screenSize = [[CCDirector sharedDirector] viewSize];
    _screenHeight = _screenSize.height;
    _screenWidth = _screenSize.width;
    _currentRobotState = RobotStateDefault;
    if (self.position.y == 50) {
        _leftSide = FALSE;
    } else if (self.position.y == _screenWidth - 50){
        _leftSide = TRUE;
    }
}

- (void)run {
    [self declareVariables];
    [self turnRobotRight:90];
    [self moveAhead: 150];
    while (TRUE) {
        if (_currentRobotState == RobotStateDefault) {
            CCLOG(@"RobotStateDefault");
            float distanceCornerOne = [self distanceBetweenTwoPoints:CGPointMake(0, 0) secondPoint:self.position];
            float distanceCornerTwo = [self distanceBetweenTwoPoints:CGPointMake(_screenWidth, 0) secondPoint:self.position];
            float distanceCornerThree = [self distanceBetweenTwoPoints:CGPointMake(0, _screenHeight) secondPoint:self.position];
            float distanceCornerFour = [self distanceBetweenTwoPoints:CGPointMake(_screenWidth, _screenHeight) secondPoint:self.position];
            if (distanceCornerOne < 150) {
                CCLOG(@"If statement reached 1");
                [self turnRobotLeft:90];
                while (distanceCornerTwo > 150){
                    CCLOG(@"%.2f", distanceCornerTwo);
                    [self moveAhead: 10];
                    distanceCornerTwo = [self distanceBetweenTwoPoints:CGPointMake(_screenWidth, 0) secondPoint:self.position];
                }
                [self moveAhead:5];
            } else if (distanceCornerTwo < 150) {
                CCLOG(@"If statement reached 2");
                [self turnRobotLeft:90];
                while (distanceCornerFour > 150){
                    [self moveAhead: 10];
                    distanceCornerFour = [self distanceBetweenTwoPoints:CGPointMake(_screenWidth, _screenHeight) secondPoint:self.position];
                }
                [self moveAhead:5];
            } else if (distanceCornerFour < 150) {
                CCLOG(@"If statement reached 3");
                [self turnRobotLeft:90];
                while (distanceCornerThree > 150){
                    CCLOG(@"%.2f", distanceCornerThree);
                    [self moveAhead:10];
                    distanceCornerThree = [self distanceBetweenTwoPoints:CGPointMake(0, _screenHeight) secondPoint:self.position];
                }
                [self moveAhead:5];
            } else if (distanceCornerThree < 150) {
                CCLOG(@"If statement reached 4");
                [self turnRobotLeft:90];
                CCLOG(@"Turned robot 90 degrees");
                while (distanceCornerOne > 150){
                    [self moveAhead:10];
                    distanceCornerOne = [self distanceBetweenTwoPoints:CGPointMake(0, 0) secondPoint:self.position];
                }
                [self moveAhead:5];
            } else {
                CCLOG(@"Moving ahead 10");
                [self moveAhead:10];
            }
        }
        if (_currentRobotState == RobotStateFiring) {
            CCLOG(@"Robot scanned");
            CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
            if (angle >= 0)
                [self turnGunRight: angle];
            else
                [self turnGunLeft: -angle];
            _currentRobotState = RobotStateDefault;
            [self shoot];
            if (self.currentTimestamp - _lastKnownPositionTimestamp > 3.0f) {
                _currentRobotState = RobotStateDefault;
            }
        }
    }
}

- (void)gotHit {
    _currentRobotState = RobotStateDefault;
}

- (float)distanceBetweenTwoPoints:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint {
    float xMinusXSquared = (firstPoint.x - secondPoint.x) * (firstPoint.x - secondPoint.x);
    float yMinusYSquared = (firstPoint.y - secondPoint.y) * (firstPoint.y - secondPoint.y);
    return sqrt(xMinusXSquared + yMinusYSquared);
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    _lastKnownPosition = position;
    _currentRobotState = RobotStateFiring;
    _lastKnownPositionTimestamp = [self currentTimestamp];
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    if (_currentRobotState != RobotStateTurnaround) {
        [self cancelActiveAction];
        
        RobotState previousState = _currentRobotState;
        _currentRobotState = RobotStateTurnaround;
        
        // always turn to head straight away from the wall
        if (angle >= 0) {
            [self turnRobotLeft:abs(angle)];
        } else {
            [self turnRobotRight:abs(angle)];
            
        }
        
        [self moveAhead:20];
        
        _currentRobotState = previousState;
    }
}

@end
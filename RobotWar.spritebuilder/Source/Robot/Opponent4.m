//
//  SexyRobot.m
//  RobotWar
//
//  Created by Andre Askarinam on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Opponent4.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
    RobotStateSearching
};

static int DANGER_ZONE = 100;
static int CURVING_CONST = 20;
static int FIRING_MOVE_DISTANCE = 100;

@implementation Opponent4 {
    RobotState _currentRobotState;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    CGFloat distanceFromOtherTank;
    BOOL continueShooting;
    CGFloat _lastKnownHitWallTimestamp;
}

- (void)run
{
    while (true)
    {
        if (_currentRobotState == RobotStateFiring)
        {
            int roundsOfFire = 0;
            while (continueShooting || roundsOfFire == 0) {
                if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                    _currentRobotState = RobotStateSearching;
                    NSLog(@"LOOKING");
                }
                NSLog(@"FIRING ROUNDS %i!", roundsOfFire + 1);
                [self angleTankAndShoot];
                roundsOfFire++;
            }
            
        }
        
        if (_currentRobotState == RobotStateSearching) {
            [self curveAndSearchForOtherTank];
        }
        
        if (_currentRobotState == RobotStateDefault) {
            [self turnGunRight:30];
            for (int rounds = 0; rounds < 3; rounds++) {
                [self shoot];
                [self turnGunRight:10];
            }
            [self moveAhead:100];
        }
    }
}

- (void)angleGunTowardsOtherTank
{
    CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
    //NSLog(@"Angle is %f", angle);
    if (angle >= 0) {
        [self turnGunRight:abs(angle)];
    } else {
        [self turnGunLeft:abs(angle)];
    }
}

- (void)angleTankAndShoot
{
    [self updateDistanceFromOtherTank];
    if (distanceFromOtherTank < DANGER_ZONE) {
        continueShooting = false;
        [self retreatandShoot:YES];
        NSLog(@"RETREAT!");
    }
    CGFloat angle = [self angleBetweenHeadingDirectionAndWorldPosition:_lastKnownPosition];
    
    if (angle >= 0)
    {
        if (angle >= 90) {
            [self turnRobotRight:angle - 90];
        } else {
            [self turnRobotLeft:90 - angle];
        }
    }
    else
    {
        if (abs(angle) >= 90) {
            [self turnRobotLeft:-90 - angle];
        } else {
            [self turnRobotRight:angle + 90];
        }
    }
    [self updateDistanceFromOtherTank];
    
    //Check if not in middle and which way to move
    CGPoint origin = CGPointMake(self.arenaDimensions.width / 2, self.arenaDimensions.height / 2);
    CGFloat angleFromOrigin = [self angleBetweenHeadingDirectionAndWorldPosition:origin];
    if (self.robotBoundingBox.origin.x > 0.6 * self.arenaDimensions.height) {
        if (abs(angleFromOrigin) > 90) {
            [self moveBack:FIRING_MOVE_DISTANCE];
        } else {
            [self moveAhead:FIRING_MOVE_DISTANCE];
        }
    } else if (self.robotBoundingBox.origin.x < 0.4 * self.arenaDimensions.height) {
        if (abs(angleFromOrigin) > 90) {
            [self moveBack:FIRING_MOVE_DISTANCE];
        } else {
            [self moveAhead:FIRING_MOVE_DISTANCE];
        }
    } else if (self.robotBoundingBox.origin.y > 0.75 * self.arenaDimensions.width) {
        if (abs(angleFromOrigin) > 90) {
            [self moveBack:FIRING_MOVE_DISTANCE];
        } else {
            [self moveAhead:FIRING_MOVE_DISTANCE];
        }
    } else if (self.robotBoundingBox.origin.y < 0.25 * self.arenaDimensions.width) {
        if (abs(angleFromOrigin) > 90) {
            [self moveBack:FIRING_MOVE_DISTANCE];
        } else {
            [self moveAhead:FIRING_MOVE_DISTANCE];
        }
    } else {
        [self moveAhead:FIRING_MOVE_DISTANCE];
    }
    
    [self angleGunTowardsOtherTank];
    [self shoot];
    continueShooting = true;
}

- (void)retreatandShoot:(BOOL)shouldShoot
{
    CGPoint origin = CGPointMake(self.arenaDimensions.width / 2, self.arenaDimensions.height / 2);
    CGFloat angleFromOrigin = [self angleBetweenHeadingDirectionAndWorldPosition:origin];
    if (abs(angleFromOrigin) > 90) {
        CGFloat increment = 180 - abs(angleFromOrigin);
        if (angleFromOrigin >= 0) {
            [self turnRobotLeft:increment];
        } else {
            [self turnRobotRight:increment];
        }
        [self moveBack:150];
    } else {
        if (angleFromOrigin >= 0) {
            [self turnRobotLeft:abs(angleFromOrigin)];
        } else {
            [self turnRobotRight:abs(angleFromOrigin)];
        }
        [self moveAhead:150];
    }
    if (shouldShoot) {
        [self angleGunTowardsOtherTank];
        for (int rounds = 0; rounds < 2; rounds++) {
            [self angleGunTowardsOtherTank];
            [self shoot];
        }
    }
}

- (void)curveAndSearchForOtherTank
{
    [self moveAhead:50];
    CGFloat x = self.robotBoundingBox.origin.x;
    CGFloat y = self.robotBoundingBox.origin.y;
    //NSLog(@"Location: %f, %f", x, y);
    if (x > 240) {
        if (y > 160)
            [self turnRobotRight:CURVING_CONST];
        else
            [self turnRobotLeft:CURVING_CONST];
    } else {
        if (y > 160)
            [self turnRobotLeft:CURVING_CONST];
        else
            [self turnRobotRight:CURVING_CONST];
    }
}

-(void)updateDistanceFromOtherTank
{
    CGFloat x = self.robotBoundingBox.origin.x;
    CGFloat y = self.robotBoundingBox.origin.y;
    CGPoint ourTankPosition = CGPointMake(x, y);
    distanceFromOtherTank = ccpDistance(ourTankPosition, _lastKnownPosition);
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    if (_currentRobotState != RobotStateFiring) {
        [self cancelActiveAction];
    }
    
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFiring;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    if (_currentRobotState != RobotStateTurnaround) {
        [self cancelActiveAction];
        
        _currentRobotState = RobotStateTurnaround;
        
        [self updateDistanceFromOtherTank];
        if (distanceFromOtherTank < DANGER_ZONE || (_lastKnownPositionTimestamp - _lastKnownHitWallTimestamp) < 1)
            [self retreatandShoot:NO];
        else {
            if (angle >= 0) {
                [self turnRobotLeft:180 - abs(angle) + 90];
            } else {
                [self turnRobotRight:180 - abs(angle) + 90];
            }
            [self retreatandShoot:NO];
            _lastKnownHitWallTimestamp = _lastKnownPositionTimestamp;
        }
        _currentRobotState = RobotStateSearching;
    }
}


@end
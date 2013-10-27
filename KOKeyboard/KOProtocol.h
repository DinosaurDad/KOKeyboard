//
//  KOProtocol.h
//  KOKeyboard
//
//  Created by David Hoerl on 10/26/13.
//  Copyright (c) 2013 Adam Horacek. All rights reserved.
//

@protocol KOProtocol <NSObject>
- (void)trackPointStarted;
- (void)trackPointMovedX:(int)xdiff Y:(int)ydiff selecting:(BOOL)selecting;
- (void)insertText:(NSString *)text;
@end

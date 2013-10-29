//
//  ExtraKeyboardRow.m
//  KeyboardTest
//
//  Created by Kuba on 28.06.12.
//  Copyright (c) 2012 Adam Horacek, Kuba Brecka
//
//  Website: http://www.becomekodiak.com/
//  github: http://github.com/adamhoracek/KOKeyboard
//	Twitter: http://twitter.com/becomekodiak
//  Mail: adam@becomekodiak.com, kuba@becomekodiak.com
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "KOKeyboardRow.h"
#import "KOSwipeButton.h"
#import "KOProtocol.h"

@interface KOKeyboardRow () <KOProtocol, UIInputViewAudioFeedback, UIDynamicAnimatorDelegate>
@end

static BOOL isPhone;

@implementation KOKeyboardRow
{
	NSMutableArray			*constraints;
	NSMutableIndexSet		*pSet;
	NSMutableIndexSet		*lSet;
	
	CGRect					startLocation;			// cursor control
	
	KOSwipeButton			*originalSnapButton;
	KOSwipeButton			*snapButton;
	CGRect					snapbackPosition;		// button animation
	CGFloat					minX, maxX, minY, maxY;	// defines where the button can move
	CGPoint					originalTouchPt;		// finger hit this spot originally
	CGPoint					originalViewPt;			// view frame origin
	
	UIDynamicAnimator		*animator;
	UIAttachmentBehavior	*aBehavior;
	
	NSInteger				barHeight;
	NSInteger				barWidth;
    NSInteger				buttonHeight;
    NSInteger				horzMargin;
    NSInteger				buttonSpacing;
    NSInteger				buttonCount;
	NSInteger				buttonWidth;
}


+ (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

+ (void)initialize
{
	isPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (KOKeyboardRow *)applyToTextControl:(id <UITextInput>) delegate
{
	KOKeyboardRow *kov = [KOKeyboardRow new];
	kov.delegate = delegate;
	
	return kov;
}

- (instancetype)init
{
	if((self = [super init])) {
		[self setup];
	}
	return self;
}

- (void)setup
{
_useAnimation = YES;
	animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
	animator.delegate = self;
	
	constraints			= [NSMutableArray array];
	pSet				= [NSMutableIndexSet new];
	lSet				= [NSMutableIndexSet new];
	
    self.backgroundColor = [UIColor colorWithRed:156/255. green:155/255. blue:166/255. alpha:1.];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth; // UIViewAutoresizingFlexibleHeight;
	[self setTranslatesAutoresizingMaskIntoConstraints:YES];
    
	if(isPhone) {
		barHeight = 56;
		barWidth = 320;

		buttonHeight = 50;
		horzMargin = 6;
		buttonSpacing = 2;
		buttonCount = 8;
//keys = @"67589\"[]{}'<>\\|◉◉◉◉◉120346758967589";
//keys = @"12345abcde◉◉◉◉◉fghij◉◉◉◉◉123451234512345";
_keys = @"^$*?+[]\\()◉◉◉◉◉{}.|:◉◉◉◉◉\",_/;0123456789";

		//keys = @"TTTTT()\"[]{}'<>\\/$´`~^|€£◉◉◉◉◉-+=%*!?#@&_:;,.1203467589";
		// K K O K 0 K K K
		//[pSet addIndex:0];	// special
		[pSet addIndex:1];
		[pSet addIndex:2];
		[pSet addIndex:3];
		[pSet addIndex:5];
		
		//[lSet addIndex:0];	// special
		[lSet addIndex:1];
		[lSet addIndex:3];
		[lSet addIndex:4];
		[lSet addIndex:5];
		[lSet addIndex:6];
		[lSet addIndex:7];

	} else {
		barHeight = 72;
		barWidth = 768;

		buttonHeight = 60;
		horzMargin = 4;
		buttonSpacing = 6;
		buttonCount = 11;

		_keys = @"TTTTT()\"[]{}'<>\\/$´`~^|€£◉◉◉◉◉-+=%*!?#@&_:;,.1203467589";
    }
    self.bounds = CGRectMake(0, 0, barWidth, barHeight);

	buttonWidth = (barWidth - buttonCount * buttonSpacing - 2*horzMargin) / buttonCount;
	NSLayoutConstraint *lc;

	KOSwipeButton *b;
	UIView *c = self;
	NSUInteger verticalMargin = (barHeight - buttonHeight) / 2;
	
    for (int i = 0; i < buttonCount; i++) {
		UIView *lv = c;
		c = [UIView new];
		[c setTranslatesAutoresizingMaskIntoConstraints:NO];
		c.clipsToBounds = NO;
		c.tag = i;
		[self addSubview:c];
		// c.backgroundColor = i ? [UIColor redColor] : [UIColor greenColor];

        b = [[KOSwipeButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
		b.tag = i;
		[b setTranslatesAutoresizingMaskIntoConstraints:NO];

		[c addSubview:b];
		
		// SET UP IMAGE

		// setup button view first
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1 constant:0]; // FIX ME
		[b addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:buttonHeight];
		[b addConstraint:lc];
		// Top and bottom
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeTop multiplier:1 constant:verticalMargin];
		[c addConstraint:lc];
	
		// left
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationLessThanOrEqual toItem:c attribute:NSLayoutAttributeLeading multiplier:1 constant:buttonSpacing/2];
		lc.priority = 800;
		[c addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
		[c addConstraint:lc];

		// PLACE VIEW IN SUPERVIEW

		NSUInteger margin = i ? 0 : horzMargin;
		lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lv attribute:i?NSLayoutAttributeTrailing:NSLayoutAttributeLeading multiplier:1 constant:margin];
		[self addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
		[self addConstraint:lc];

		lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
		[self addConstraint:lc];
		

        b.keys = [_keys substringWithRange:NSMakeRange(i * 5, 5)];
		b.delegate = self;
		
#if 0
		NSLog(@"B: %@", [b constraints]);
		NSLog(@"C: %@", [c constraints]);
		NSLog(@"V: %@", [self constraints]);
#endif
    }
	lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-horzMargin];
	[self addConstraint:lc];


#if 0
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
		{
			NSLog(@"KEY VIEW FRAME: %@", NSStringFromCGRect(self.frame));
			NSLog(@"C FRAME: %@", NSStringFromCGRect(c.frame));
			NSLog(@"SUBVIEWS: %@", self.subviews);
			NSLog(@"%@", [self constraints]);

		} );
#endif

	__block UIView *firstView;
	[self.subviews enumerateObjectsUsingBlock:^(UIView *enclosingView, NSUInteger idx, BOOL *stop)
		{
			//NSLog(@"BUTTON: %@ subviews: %@", enclosingView, enclosingView.subviews);
			UIView *button = [enclosingView.subviews lastObject];
			assert(button);
			if(!idx) {
				firstView = button;
				[constraints addObject:[NSNull null]];	// placeholder so indexing works properly
			} else {
				NSLayoutConstraint *le = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:firstView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
				le.priority = UILayoutPriorityRequired - 1;
				NSLayoutConstraint *l0 = [NSLayoutConstraint constraintWithItem:enclosingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:0 multiplier:1 constant:10000];
				
				[self addConstraint:le];
				[self addConstraint:l0];
				[constraints addObject:l0];
			}
		} ];
	
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	[self switchToOrientation:interfaceOrientation];

    UIView *border1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barWidth, 1)];
	border1.tag = 100;
    border1.backgroundColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1.];
    border1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self insertSubview:border1 atIndex:0];

#if 0
    UIView *border2 = [[UIView alloc] initWithFrame:CGRectMake(0, 1, barWidth, 1)];
    border2.backgroundColor = [UIColor colorWithRed:191/255. green:191/255. blue:191/255. alpha:1.];
    border2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	border2.tag = 101;
    [self addSubview:border2];
#endif
}

- (void)setDelegate:(id<UITextInput>)delegate
{
	_delegate = delegate;
	if([delegate isKindOfClass:[UITextView class]]) {
		((UITextView *)delegate).inputAccessoryView = self;
	} else
	if([delegate isKindOfClass:[UITextField class]]) {
		((UITextField *)delegate).inputAccessoryView = self;
	}
	//self._delegate = t;
}

- (void)switchToOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	BOOL isPortrait = UIInterfaceOrientationIsPortrait(interfaceOrientation);
	NSIndexSet *set = isPortrait ? pSet : lSet;

	[constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *lc, NSUInteger idx, BOOL *stop)
		{
			if(!idx) return;	// index 0 is special
			UIView *c = lc.firstItem;

			if([set containsIndex:idx]) {
				lc.constant = 10000;
				c.clipsToBounds = NO;
			} else {
				lc.constant = 0;
				c.clipsToBounds = YES;
			}
		} ];
	[self needsUpdateConstraints];
}

- (BOOL) enableInputClicksWhenVisible {
    return YES;
}

- (void)insertText:(NSString *)text
{
	[[UIDevice currentDevice] playInputClick];

	if([_delegate isKindOfClass:[UITextView class]]) {
		UITextView *textView = (UITextView *)_delegate;
		if ([textView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
			// Ask textView'delegate whether we should change the text
			NSRange selectedRange = textView.selectedRange;
			BOOL shouldInsert = [textView.delegate textView:textView shouldChangeTextInRange:selectedRange replacementText:text];
			if (shouldInsert) {
				[textView insertText:text];
				// also notify someone interested in this textview
				[[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView];
			}
		} else {
			[_delegate insertText:text];
		}
	} else
	if([_delegate isKindOfClass:[UITextField class]]) {
		UITextField *textField = (UITextField *)_delegate;
		if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeTextInRange:replacementText:)]) {
			// Ask textView'delegate whether we should change the text
			UITextRange *selectedTextRange = textField.selectedTextRange;
			NSUInteger location = [textField offsetFromPosition:textField.beginningOfDocument
													 toPosition:selectedTextRange.start];
			NSUInteger length = [textField offsetFromPosition:selectedTextRange.start
												   toPosition:selectedTextRange.end];
			NSRange selectedRange = NSMakeRange(location, length);
			//NSLog(@"selectedRange: %@", NSStringFromRange(selectedRange));

			BOOL shouldInsert = [textField.delegate textField:textField shouldChangeCharactersInRange:selectedRange replacementString:text];
			if (shouldInsert) {
				[textField insertText:text];
				// also notify someone interested in this textview
				[[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField];
			}
		} else {
			[_delegate insertText:text];
		}
	}
}

- (void)trackPointStarted
{
    startLocation = [_delegate caretRectForPosition:_delegate.selectedTextRange.start];
}

- (void)trackPointMovedX:(int)xdiff Y:(int)ydiff selecting:(BOOL)selecting
{
    CGRect loc = startLocation;    
    
	// Following line causes problems DFH
    //loc.origin.y += textView.contentOffset.y;
    
    UITextPosition *p1 = [_delegate closestPositionToPoint:loc.origin];
    
    loc.origin.x -= xdiff;
    loc.origin.y -= ydiff;
    
    UITextPosition *p2 = [_delegate closestPositionToPoint:loc.origin];
    
    if (!selecting) {
        p1 = p2;
    }
    UITextRange *r = [_delegate textRangeFromPosition:p1 toPosition:p2];
	
    _delegate.selectedTextRange = r;
}

- (void)finderDown:(UITouch *)t inView:(UIView *)view
{
	if(!_useAnimation) {
		return;
	}

	UIView *box = [view superview];
	originalTouchPt = [t locationInView:self];
	originalViewPt	= [box convertPoint:view.center toView:self];
NSLog(@"CENTER IN MY COORDINATES %@", NSStringFromCGPoint(originalViewPt));
	snapbackPosition = [view convertRect:view.bounds toView:self];
//NSLog(@"VIEW frame: %@", NSStringFromCGRect(snapbackPosition));
	
	{
		CGRect frame = box.frame;
//NSLog(@"BOX frame: %@", NSStringFromCGRect(snapbackPosition));
		minX = box.tag ? (frame.origin.x - 2*buttonSpacing) : 0;
		maxX = frame.origin.x + frame.size.width + buttonSpacing + buttonSpacing - view.bounds.size.width;
		minY = 0;
		maxY = barHeight - view.bounds.size.height;
	}

#if 0
	snapShot = [view snapshotViewAfterScreenUpdates:NO];
#endif

	originalSnapButton = (KOSwipeButton *)view;
	view.alpha = 0;
	snapButton = [[KOSwipeButton alloc] initWithFrame:[view convertRect:view.bounds toView:self]];
	snapButton.keys = originalSnapButton.keys;
	
//NSLog(@"SnapShot frame: %@", NSStringFromCGRect(snapButton.frame));
	[self addSubview:snapButton];



#if 0
UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[snapShot]];

#if 0
CGRect frame = box.frame;
NSLog(@"BOX FRAME: %@ SNAPFRAME=%@", NSStringFromCGRect(frame), NSStringFromCGRect(snapShot.frame));
//UIEdgeInsets insets = UIEdgeInsetsMake(0, frame.origin.x - 3, 0, self.bounds.size.width - (frame.origin.x + frame.size.width + 3) );
//UIEdgeInsets insets = UIEdgeInsetsMake(0, -3, 0, -3);
UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
[collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:insets];
#else
collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
#endif

[animator addBehavior: collisionBehavior];





	//UIAttachmentBehavior *behavior = [[UIAttachmentBehavior alloc] initWithItem:b attachedToItem:c];
	aBehavior = [[UIAttachmentBehavior alloc] initWithItem:snapShot attachedToAnchor:pt];
	
	aBehavior.damping = 0;
	aBehavior.frequency = 0;
	
NSLog(@"finderDown=%@ INDEX:%d LENGTH=%f", NSStringFromCGPoint(pt), view.tag, aBehavior.length);

	[animator addBehavior:aBehavior];

#endif
}

- (void)finderMoved:(UITouch *)t inView:(UIView *)view selectedLabel:(NSInteger)idx
{
	if(!_useAnimation) {
		return;
	}
	CGPoint pt = [t locationInView:self];
	
	CGFloat xDiff = pt.x - originalTouchPt.x;
	CGFloat yDiff = pt.y - originalTouchPt.y;
	
	CGPoint newOrigin = snapbackPosition.origin;
	newOrigin.x += xDiff;
	newOrigin.x = MAX(newOrigin.x, minX);
	newOrigin.x = MIN(newOrigin.x, maxX);
	newOrigin.y += yDiff;
	newOrigin.y = MAX(newOrigin.y, minY);
	newOrigin.y = MIN(newOrigin.y, maxY);
	
	snapButton.frame = (CGRect){ newOrigin, snapbackPosition.size };
	[snapButton selectLabel:idx];

//NSLog(@"finderMoved=%@", NSStringFromCGPoint(pt));
//[aBehavior setAnchorPoint:pt];

}

- (void)finderUp:(UITouch *)t inView:(UIView *)view
{
	if(!_useAnimation) {
		return;
	}
	
#if 0
	[UIView animateWithDuration:.100 animations:^{
		snapButton.frame = snapbackPosition;
	} completion:^(BOOL finished) {
		view.alpha = 1;
		[snapButton removeFromSuperview];
		snapButton = nil;
	} ];
#endif

	UISnapBehavior *behavior = [[UISnapBehavior alloc] initWithItem:snapButton snapToPoint:originalViewPt];
	behavior.damping = 1;
	[animator addBehavior:behavior];

#if 0
	view.frame - snapbackPosition
	CGPoint pt = [t locationInView:self];
NSLog(@"finderReleased=%@", NSStringFromCGPoint(pt));
	[animator removeAllBehaviors];
	aBehavior = nil;
#endif

}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)ani
{
  //NSLog(@"pause centerNow=%@ desired=%@", NSStringFromCGPoint(snapButton.center), NSStringFromCGPoint(originalViewPt));
  	[UIView animateWithDuration:.10 animations:^{
		snapButton.frame = snapbackPosition;
	} completion:^(BOOL finished) {
		originalSnapButton.alpha = 1;
		originalSnapButton = nil;
		[snapButton removeFromSuperview];
		snapButton = nil;
	} ];

	[ani removeAllBehaviors];
}

#if 0
- (void)setNeedsLayout
{
	if(!aBehavior) {
		[super setNeedsLayout];
		NSLog(@"UPDATE setNeedsLayout");
	}


}
- (void)setNeedsUpdateConstraints
{
	if(!aBehavior)
	{
		NSLog(@"UPDATE setNeedsUpdateConstraints");
		[super setNeedsUpdateConstraints];
	}



}

- (void)updateConstraints
{
	[super updateConstraints];
	NSLog(@"UPDATE updateConstraints");

}
- (void)updateConstraintsIfNeeded
{
	[super updateConstraintsIfNeeded];
	NSLog(@"UPDATE updateConstraintsIfNeeded");

}

-(void)layoutSubviews
{
	[super layoutSubviews];
	NSLog(@"UPDATE layoutSubviews");

}
-(void)layoutIfNeeded
{
	[super layoutIfNeeded];
	NSLog(@"UPDATE layoutIfNeeded");

}
#endif

@end

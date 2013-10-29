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
//  Modified by David Hoerl on 28.10.2013
//  Copyright (c) 2013 David Hoerl
//

#import "KOKeyboardRow.h"

#import "KOSwipeButton.h"
#import "KOProtocol.h"
#import "CreateButton.h"

@interface KOKeyboardRow () <KOProtocol, UIInputViewAudioFeedback, UIDynamicAnimatorDelegate>
@end

static BOOL isPhone;
static BOOL isRetina;

@implementation KOKeyboardRow
{
	NSMutableArray			*constraints;
	
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
	isRetina = [[UIScreen mainScreen] scale] > 1;
}

- (instancetype)initWithDelegate:(id <UITextInput>)del;
{
	if((self = [super init])) {
		self.koDelegate = del;
	}
	return self;
}

- (void)setup
{
	if(_animation == koSnapbackAnimation) {
		animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
		animator.delegate = self;
	}
	
	constraints			= [NSMutableArray array];
	
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth; // UIViewAutoresizingFlexibleHeight;
	[self setTranslatesAutoresizingMaskIntoConstraints:YES];
    
	buttonCount = ([_keys length]+4)/5;

	barWidth = [UIScreen mainScreen].bounds.size.width;
	
	if(isPhone) {
		barHeight = 56;

		buttonHeight = 50;
		horzMargin = 6;
		buttonSpacing = 6;

		//keys = @"TTTTT()\"[]{}'<>\\/$´`~^|€£◉◉◉◉◉-+=%*!?#@&_:;,.1203467589";
	} else {
		barHeight = 72;

		buttonHeight = 60;
		horzMargin = 4;
		buttonSpacing = 6;

		//_keys = @"TTTTT()\"[]{}'<>\\/$´`~^|€£◉◉◉◉◉-+=%*!?#@&_:;,.1203467589";
    }
    self.bounds = CGRectMake(0, 0, barWidth, barHeight);

	buttonWidth = (barWidth - buttonCount * buttonSpacing - 2*horzMargin) / buttonCount;
	NSLayoutConstraint *lc;

	KOSwipeButton *b;
	UIView *c = self;
	NSUInteger verticalMargin = (barHeight - buttonHeight) / 2;
	
	__block NSUInteger firstCommonIndex = NSNotFound;
	[_portraitSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
		{
			if([_landscapeSet containsIndex:idx]) {
				firstCommonIndex = idx;
				*stop = YES;
			}
		} ];
	
    for (NSInteger i = 0; i < buttonCount; i++) {
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

    }
	lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-horzMargin];
	[self addConstraint:lc];

	UIView *firstCommonView = [((UIView *)(self.subviews[firstCommonIndex])).subviews lastObject];
	assert(firstCommonView);
	
	[self.subviews enumerateObjectsUsingBlock:^(UIView *enclosingView, NSUInteger idx, BOOL *stop)
		{
			//NSLog(@"BUTTON: %@ subviews: %@", enclosingView, enclosingView.subviews);
			KOSwipeButton *button = [enclosingView.subviews lastObject];
			assert(button);
			NSLayoutConstraint *le;
			if([button isTrackingPoint]) {
				le = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:button.bounds.size.height];
			} else {
				le = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:firstCommonView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
			}
			le.priority = UILayoutPriorityRequired - 1;
			NSLayoutConstraint *l0 = [NSLayoutConstraint constraintWithItem:enclosingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:0 multiplier:1 constant:10000];
			
			[self addConstraint:le];
			[self addConstraint:l0];
			[constraints addObject:l0];
		} ];
	
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	[self switchToOrientation:interfaceOrientation];

	CGFloat height = isRetina ? 0.5f : 1;

#if 0 // we get this "for free" now
    UIView *border1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barWidth, height)];
	border1.tag = 100;
    border1.backgroundColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1.];
    border1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [self insertSubview:border1 atIndex:0];
#endif

    UIView *border2 = [[UIView alloc] initWithFrame:CGRectMake(0, barHeight-height, barWidth, height)];
	border2.tag = 102;
    border2.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.];
    border2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self insertSubview:border2 atIndex:1];

	self.barTintColor = [CreateButton backgroundColorForType:UIKeyboardAppearanceLight];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	[self setNeedsUpdateConstraints];
	[self setNeedsLayout];
}

- (void)setKoDelegate:(id<UITextInput>)del
{
	_koDelegate = del;
	if([_koDelegate isKindOfClass:[UITextView class]]) {
		((UITextView *)_koDelegate).inputAccessoryView = self;
	} else
	if([_koDelegate isKindOfClass:[UITextField class]]) {
		((UITextField *)_koDelegate).inputAccessoryView = self;
	}
}

- (void)switchToOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	BOOL isPortrait = UIInterfaceOrientationIsPortrait(interfaceOrientation);
	NSIndexSet *set = isPortrait ? _portraitSet : _landscapeSet;

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

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

- (void)insertText:(NSString *)text
{
	[[UIDevice currentDevice] playInputClick];

	if([_koDelegate isKindOfClass:[UITextView class]]) {
		UITextView *textView = (UITextView *)_koDelegate;
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
			[_koDelegate insertText:text];
		}
	} else
	if([_koDelegate isKindOfClass:[UITextField class]]) {
		UITextField *textField = (UITextField *)_koDelegate;
		if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
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
			[_koDelegate insertText:text];
		}
	}
}

- (void)trackPointStarted
{
    startLocation = [_koDelegate caretRectForPosition:_koDelegate.selectedTextRange.start];
}

- (void)trackPointMovedX:(int)xdiff Y:(int)ydiff selecting:(BOOL)selecting
{
    CGPoint loc = CGPointMake( CGRectGetMidX(startLocation), CGRectGetMidY(startLocation) ) ;

	// Following line causes problems DFH
    //loc.origin.y += textView.contentOffset.y;
	if(selecting) ydiff = 0; // DFH
    
    UITextPosition *p1 = [_koDelegate closestPositionToPoint:loc];
    
    loc.x -= xdiff;
    loc.y -= ydiff;
    
    UITextPosition *p2 = [_koDelegate closestPositionToPoint:loc];
    
    if (!selecting) {
        p1 = p2;
    }
    UITextRange *r = [_koDelegate textRangeFromPosition:p1 toPosition:p2];
	
    _koDelegate.selectedTextRange = r;
}

- (void)trackPointEnded
{
//NSLog(@"FUCK!");
	UITextRange *r = [_koDelegate selectedTextRange];
	if(!r.empty) {
		// need to defer this or the menu stops the button unhiliting
		dispatch_async(dispatch_get_main_queue(), ^
			{
				UITextRange *selectionRange	= [_koDelegate selectedTextRange];
				CGRect selectionStartRect	= [_koDelegate caretRectForPosition:selectionRange.start];
				CGRect selectionEndRect		= [_koDelegate caretRectForPosition:selectionRange.end];
				CGRect selectionRect		= CGRectUnion(selectionStartRect, selectionEndRect);

				// bring up edit menu.
				UIMenuController *theMenu = [UIMenuController sharedMenuController];
				UIView *view = (UIView *)_koDelegate;
				[theMenu setTargetRect:selectionRect inView:view];
				[theMenu setMenuVisible:YES animated:YES];
			} );
	}
}

- (void)finderDown:(UITouch *)t inView:(UIView *)view
{
	if(_animation == koNoAnimation) {
		return;
	}

	UIView *box = [view superview];
	originalTouchPt = [t locationInView:self];
	originalViewPt	= [box convertPoint:view.center toView:self];
	snapbackPosition = [view convertRect:view.bounds toView:self];
}

- (void)finderMoved:(UITouch *)t inView:(UIView *)view selectedLabel:(NSInteger)idx
{
	if(_animation == koNoAnimation) {
		return;
	}
	
	if(!snapButton) {
		UIView *box = [view superview];
		{
			CGRect frame = box.frame;
			//NSLog(@"BOX frame: %@", NSStringFromCGRect(snapbackPosition));
			minX = box.tag ? (frame.origin.x - buttonSpacing/2) : 0;
			maxX = frame.origin.x + frame.size.width + buttonSpacing/2 - view.bounds.size.width;
			minY = 0;
			maxY = barHeight - view.bounds.size.height;
		}

		originalSnapButton = (KOSwipeButton *)view;
		snapButton = [[KOSwipeButton alloc] initWithFrame:[box convertRect:view.frame toView:self]];
		snapButton.keys = originalSnapButton.keys;

		//NSLog(@"SnapShot frame: %@", NSStringFromCGRect(snapButton.frame));
		view.alpha = 0;
		[self addSubview:snapButton];
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
}

- (void)finderUp:(UITouch *)t inView:(UIView *)view
{
	switch(_animation) {
	case koNoAnimation:
		return;
	
	case koTraditinalAnimation:
	{
		[UIView animateWithDuration:.100 animations:^{
			snapButton.frame = snapbackPosition;
		} completion:^(BOOL finished) {
			view.alpha = 1;
			[snapButton removeFromSuperview];
			snapButton = nil;
		} ];
	}	break;
	
	case koSnapbackAnimation:
	{
		UISnapBehavior *behavior = [[UISnapBehavior alloc] initWithItem:snapButton snapToPoint:originalViewPt];
		behavior.damping = 1;
		[animator addBehavior:behavior];
	}	break;
	}
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

@end

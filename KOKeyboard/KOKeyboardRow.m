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

@interface KOKeyboardRow () <KOProtocol, UIInputViewAudioFeedback>
@end

static BOOL isPhone;

@implementation KOKeyboardRow
{
	NSMutableArray *pConstraints;
	NSMutableArray *lConstraints;
	NSMutableIndexSet *pSet;
	NSMutableIndexSet *lSet;
	
	CGRect startLocation;
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
	int barHeight;
	int barWidth;

	if(isPhone) {
		barHeight = 52;
		barWidth = 320;
	} else {
		barHeight = 72;
		barWidth = 768;
	}
    self.frame = CGRectMake(0, 0, barWidth, barHeight);

	pConstraints	= [NSMutableArray array];
	lConstraints	= [NSMutableArray array];
	pSet			= [NSMutableIndexSet new];
	lSet			= [NSMutableIndexSet new];
	
    self.backgroundColor = [UIColor colorWithRed:156/255. green:155/255. blue:166/255. alpha:1.];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth; // UIViewAutoresizingFlexibleHeight;
	[self setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    int buttonHeight;
    int horzMargin;
    int buttonSpacing;
    int buttonCount;
	NSString *keys;
	int buttonWidth;

	if(isPhone) {
		buttonHeight = 50;
		horzMargin = 6;
		buttonSpacing = 2;
		buttonCount = 8;
//keys = @"67589\"[]{}'<>\\|◉◉◉◉◉120346758967589";
//keys = @"12345abcde◉◉◉◉◉fghij◉◉◉◉◉123451234512345";
keys = @"^$*?+[]\\()◉◉◉◉◉{}.|:◉◉◉◉◉\",_/;0123456789";

		//keys = @"TTTTT()\"[]{}'<>\\/$´`~^|€£◉◉◉◉◉-+=%*!?#@&_:;,.1203467589";
		// K K O K 0 K K K
		[pSet addIndex:0];
		[pSet addIndex:1];
		[pSet addIndex:2];
		[pSet addIndex:3];
		[pSet addIndex:5];
		
		[lSet addIndex:0];
		[lSet addIndex:1];
		[lSet addIndex:3];
		[lSet addIndex:4];
		[lSet addIndex:5];
		[lSet addIndex:6];
		[lSet addIndex:7];

	} else {
		buttonHeight = 60;
		horzMargin = 4;
		buttonSpacing = 6;
		buttonCount = 11;

		keys = @"TTTTT()\"[]{}'<>\\/$´`~^|€£◉◉◉◉◉-+=%*!?#@&_:;,.1203467589";
    }
	buttonWidth = (barWidth - buttonCount * buttonSpacing - 2*horzMargin) / buttonCount;
	NSLayoutConstraint *lc;

	KOSwipeButton *b;
	UIView *c = self;
	NSUInteger verticalMargin = (barHeight - buttonHeight) / 2;
	
    for (int i = 0; i < buttonCount; i++) { // buttonCount
		
		UIView *lv = c;
		c = [UIView new];
		[c setTranslatesAutoresizingMaskIntoConstraints:NO];
		c.clipsToBounds = YES;
		c.tag = i;
		[self addSubview:c];
		// c.backgroundColor = i ? [UIColor redColor] : [UIColor greenColor];

        b = [[KOSwipeButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
		assert(!b.autoresizingMask);
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
		

        b.keys = [keys substringWithRange:NSMakeRange(i * 5, 5)];
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
	[self setNeedsUpdateConstraints];
#endif

	__block UIView *firstView;
	[self.subviews enumerateObjectsUsingBlock:^(UIView *enclosingView, NSUInteger idx, BOOL *stop)
		{
			//NSLog(@"BUTTON: %@ subviews: %@", enclosingView, enclosingView.subviews);
		
			UIView *button = [enclosingView.subviews lastObject];
			assert(button);

			if(!idx) {
				firstView = button;
			} else {
				NSLayoutConstraint *le = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:firstView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
				NSLayoutConstraint *l0 = [NSLayoutConstraint constraintWithItem:enclosingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:0];
				//[self addConstraint:lc];
				if([pSet containsIndex:idx]) {
					[pConstraints addObject:le];
				} else {
					[pConstraints addObject:l0];
				
				}
				if([lSet containsIndex:idx]) {
					[lConstraints addObject:le];
				} else {
					[lConstraints addObject:l0];
				}
			}
		} ];
	
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if(UIInterfaceOrientationIsPortrait(interfaceOrientation) == UIInterfaceOrientationPortrait) {
		[self addConstraints:pConstraints];
	} else {
		[self addConstraints:lConstraints];
	}

    UIView *border1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barWidth, 1)];
	border1.tag = 100;
    border1.backgroundColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1.];
    border1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:border1];
    
    UIView *border2 = [[UIView alloc] initWithFrame:CGRectMake(0, 1, barWidth, 1)];
    border2.backgroundColor = [UIColor colorWithRed:191/255. green:191/255. blue:191/255. alpha:1.];
    border2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	border2.tag = 101;
    [self addSubview:border2];
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
	if(UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
		[self removeConstraints:lConstraints];
		[self addConstraints:pConstraints];
	} else {
		[self removeConstraints:pConstraints];
		[self addConstraints:lConstraints];
	}
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

@end

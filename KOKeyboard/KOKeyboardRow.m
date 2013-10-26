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

@interface KOKeyboardRow ()

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, assign) CGRect startLocation;

@end

static BOOL isPhone;

@implementation KOKeyboardRow
@synthesize textView, startLocation;

+ (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

+ (void)initialize
{
	isPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (KOKeyboardRow *)applyToTextView:(UITextView *)t
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
    
    KOKeyboardRow *v = [[KOKeyboardRow alloc] initWithFrame:CGRectMake(0, 0, barWidth, barHeight)];
    v.backgroundColor = [UIColor colorWithRed:156/255. green:155/255. blue:166/255. alpha:1.];
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth; // UIViewAutoresizingFlexibleHeight;
    v.textView = t;
	[v setTranslatesAutoresizingMaskIntoConstraints:YES];

    UIView *border1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barWidth, 1)];
    border1.backgroundColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1.];
    border1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [v addSubview:border1];
    
    UIView *border2 = [[UIView alloc] initWithFrame:CGRectMake(0, 1, barWidth, 1)];
    border2.backgroundColor = [UIColor colorWithRed:191/255. green:191/255. blue:191/255. alpha:1.];
    border2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [v addSubview:border2];
    
    int buttonHeight;
    int leftMargin;
    int topMargin;
    int buttonSpacing;
    int buttonCount;
	NSString *keys;
	int buttonWidth;

	if(isPhone) {
		buttonHeight = 50;
		leftMargin = 3;
		topMargin = 0;
		buttonSpacing = 6;
		buttonCount = 7;
		keys = @"67589\"[]{}'<>\\|◉◉◉◉◉120346758967589";
	} else {
		buttonHeight = 60;
		leftMargin = 3;
		topMargin = 1;
		buttonSpacing = 6;
		buttonCount = 11;

		keys = @"TTTTT()\"[]{}'<>\\/$´`~^|€£◉◉◉◉◉-+=%*!?#@&_:;,.1203467589";
    }
	buttonWidth = (barWidth - 2 * leftMargin - (buttonCount - 1) * buttonSpacing) / buttonCount;
	leftMargin = (barWidth - buttonWidth * buttonCount - buttonSpacing * (buttonCount - 1)) / 2;

	NSLayoutConstraint *lc;
	KOSwipeButton *b;
	UIView *c = v;
    for (int i = 0; i < 2; i++) { // buttonCount
#if 1
		NSUInteger verticalMargin = (barHeight - buttonHeight) / 2;
		
		UIView *lv = c;
		c = [UIView new];
[c setTranslatesAutoresizingMaskIntoConstraints:NO];
		c.tag = i;
		[v addSubview:c];
c.backgroundColor = i ? [UIColor redColor] : [UIColor greenColor];

#if 1

#if 0
        b = [[KOSwipeButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
		assert(!b.autoresizingMask);
		[b setTranslatesAutoresizingMaskIntoConstraints:NO];

		[c addSubview:b];
		
		// SET UP IMAGE
		
		// setup inner first
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1 constant:0];
		[b addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:0 multiplier:1 constant:buttonWidth];
		[b addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:buttonHeight];
		[b addConstraint:lc];
		// Top and bottom
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeTop multiplier:1 constant:verticalMargin];
		[c addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeBottom multiplier:1 constant:-verticalMargin];
		[c addConstraint:lc];
		// left and right
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationLessThanOrEqual toItem:c attribute:NSLayoutAttributeLeft multiplier:1 constant:leftMargin];
		[c addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:c attribute:NSLayoutAttributeRight multiplier:1 constant:-leftMargin];
		[c addConstraint:lc];
#else
		b = [UIView new];
		b.backgroundColor = [UIColor yellowColor];
		[b setTranslatesAutoresizingMaskIntoConstraints:NO];
		[c addSubview:b];


#if 1
		// setup inner first
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1 constant:10]; // FIX ME
		[b addConstraint:lc];
//lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:buttonWidth];
//[b addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:buttonHeight];
		[b addConstraint:lc];
		// Top and bottom
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeTop multiplier:1 constant:verticalMargin];
		[c addConstraint:lc];

// CRASHES?!?!?
//lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeBottom multiplier:1 constant:-verticalMargin];
//[c addConstraint:lc];
		// left and right
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeLeft multiplier:1 constant:leftMargin];
		[c addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeRight multiplier:1 constant:-leftMargin];
		[c addConstraint:lc];
#else // CRASHES
		// setup inner first
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1 constant:0];
		[b addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:0 multiplier:1 constant:buttonWidth];
		[b addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:buttonHeight];
		[b addConstraint:lc];
		// Top and bottom
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeTop multiplier:1 constant:verticalMargin];
		[c addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeBottom multiplier:1 constant:-verticalMargin];
		[c addConstraint:lc];
		// left and right
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationLessThanOrEqual toItem:c attribute:NSLayoutAttributeLeft multiplier:1 constant:leftMargin];
		[c addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:c attribute:NSLayoutAttributeRight multiplier:1 constant:-leftMargin];
		[c addConstraint:lc];
#endif

#endif

		lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1 constant:buttonWidth+2*leftMargin]; // NSLayoutRelationEqual
		[c addConstraint:lc];
#else
		lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1 constant:buttonWidth+2*leftMargin];
		[c addConstraint:lc];
#endif

		// PLACE VIEW IN SUPERVIEW

		lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lv attribute:i?NSLayoutAttributeTrailing:NSLayoutAttributeLeading multiplier:1 constant:0];
		[v addConstraint:lc];
#if 0
		if(i) {
			lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:lv attribute:NSLayoutAttributeWidth multiplier:1 constant:0]; // NSLayoutRelationEqual
			[v addConstraint:lc];
		}
#endif
		lc = [NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
		[v addConstraint:lc];

		lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeTop multiplier:1 constant:0];
		[v addConstraint:lc];
		

//lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
//[v addConstraint:lc];
		
//NSLog(@"BUTTON FRAME: %@", NSStringFromCGRect(b.frame));



  //      b.keys = [keys substringWithRange:NSMakeRange(i * 5, 5)];
  //      b.delegate = v;
		
		
NSLog(@"B: %@", [b constraints]);
NSLog(@"C: %@", [c constraints]);
NSLog(@"V: %@", [v constraints]);
#else
        b = [[KOSwipeButton alloc] initWithFrame:CGRectMake(leftMargin + i * (buttonSpacing + buttonWidth), topMargin + (barHeight - buttonHeight) / 2, buttonWidth, buttonHeight)];
        b.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//NSLog(@"BUTTON FRAME: %@", NSStringFromCGRect(b.frame));
        b.keys = [keys substringWithRange:NSMakeRange(i * 5, 5)];
        b.delegate = v;
        [v addSubview:b];
#endif
    }
	lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
	[v addConstraint:lc];

dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
    {
		NSLog(@"KEY VIEW FRAME: %@", NSStringFromCGRect(v.frame));
		NSLog(@"C FRAME: %@", NSStringFromCGRect(c.frame));
        NSLog(@"SUBVIEWS: %@", v.subviews);
		NSLog(@"%@", [v constraints]);

    } );
	[v setNeedsUpdateConstraints];

    t.inputAccessoryView = v;
	return v;
}

- (void)insertText:(NSString *)text
{
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
        [textView insertText:text];
    }

}

- (void)trackPointStarted
{
    startLocation = [textView caretRectForPosition:textView.selectedTextRange.start];
}

- (void)trackPointMovedX:(int)xdiff Y:(int)ydiff selecting:(BOOL)selecting
{
    CGRect loc = startLocation;    
    
    loc.origin.y -= textView.contentOffset.y;
    
    UITextPosition *p1 = [textView closestPositionToPoint:loc.origin];
    
    loc.origin.x -= xdiff;
    loc.origin.y -= ydiff;
    
    UITextPosition *p2 = [textView closestPositionToPoint:loc.origin];
    
    if (!selecting) {
        p1 = p2;
    }
    UITextRange *r = [textView textRangeFromPosition:p1 toPosition:p2];
    
    textView.selectedTextRange = r;
}

@end

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
@property (nonatomic, retain) id <UITextInput> textInput;
//@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, assign) CGRect startLocation;

@end

static BOOL isPhone;

@implementation KOKeyboardRow
{
	NSMutableArray *pConstraints;
	NSMutableArray *lConstraints;
	NSMutableIndexSet *pSet;
	NSMutableIndexSet *lSet;
}

@synthesize textInput, startLocation;

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
	
	v->pConstraints	= [NSMutableArray array];
	v->lConstraints	= [NSMutableArray array];
	v->pSet			= [NSMutableIndexSet new];
	v->lSet			= [NSMutableIndexSet new];
	
    v.backgroundColor = [UIColor colorWithRed:156/255. green:155/255. blue:166/255. alpha:1.];
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth; // UIViewAutoresizingFlexibleHeight;
    v.textView = t;
	[v setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    int buttonHeight;
    //int leftMargin;
    int topMargin;
    int buttonSpacing;
    int buttonCount;
	NSString *keys;
	int buttonWidth;

	if(isPhone) {
		buttonHeight = 50;
		topMargin = 0;
		buttonSpacing = 2;
		buttonCount = 8;
		buttonWidth = 100;
		keys = @"67589\"[]{}'<>\\|◉◉◉◉◉120346758967589";
		keys = @"12345abcde◉◉◉◉◉fghij◉◉◉◉◉123451234512345";
		//keys = @"TTTTT()\"[]{}'<>\\/$´`~^|€£◉◉◉◉◉-+=%*!?#@&_:;,.1203467589";
		// K K O K 0 K K K
		[v->pSet addIndex:0];
		[v->pSet addIndex:1];
		[v->pSet addIndex:2];
		[v->pSet addIndex:3];
		[v->pSet addIndex:5];
		
		[v->lSet addIndex:0];
		[v->lSet addIndex:1];
		[v->lSet addIndex:3];
		[v->lSet addIndex:4];
		[v->lSet addIndex:5];
		[v->lSet addIndex:6];
		[v->lSet addIndex:7];

	} else {
		buttonHeight = 60;
		//leftMargin = 3;
		topMargin = 1;
		buttonSpacing = 6;
		buttonCount = 11;

		keys = @"TTTTT()\"[]{}'<>\\/$´`~^|€£◉◉◉◉◉-+=%*!?#@&_:;,.1203467589";
    }
	buttonWidth = (barWidth - buttonCount * buttonSpacing) / buttonCount;
	NSLayoutConstraint *lc;

	KOSwipeButton *b;
	UIView *c = v;
    for (int i = 0; i < buttonCount; i++) { // buttonCount
		NSUInteger verticalMargin = (barHeight - buttonHeight) / 2;
		
		UIView *lv = c;
		c = [UIView new];
		[c setTranslatesAutoresizingMaskIntoConstraints:NO];
		c.clipsToBounds = YES;
		c.tag = i;
		[v addSubview:c];
		// c.backgroundColor = i ? [UIColor redColor] : [UIColor greenColor];

        b = [[KOSwipeButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
		assert(!b.autoresizingMask);
		[b setTranslatesAutoresizingMaskIntoConstraints:NO];

		[c addSubview:b];
		
		// SET UP IMAGE

		// setup inner first
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1 constant:0]; // FIX ME
		[b addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:buttonHeight];
		[b addConstraint:lc];
		// Top and bottom
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeTop multiplier:1 constant:verticalMargin];
		[c addConstraint:lc];

		// left and right
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationLessThanOrEqual toItem:c attribute:NSLayoutAttributeLeft multiplier:1 constant:buttonSpacing/2];
		lc.priority = 800;
		[c addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
		[c addConstraint:lc];

		// PLACE VIEW IN SUPERVIEW

		lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lv attribute:i?NSLayoutAttributeTrailing:NSLayoutAttributeLeading multiplier:1 constant:0];
		[v addConstraint:lc];
		lc = [NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:c attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
		[v addConstraint:lc];

		lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeTop multiplier:1 constant:0];
		[v addConstraint:lc];
		

        b.keys = [keys substringWithRange:NSMakeRange(i * 5, 5)];
		b.delegate = v;
		
#if 0
		NSLog(@"B: %@", [b constraints]);
		NSLog(@"C: %@", [c constraints]);
		NSLog(@"V: %@", [v constraints]);
#endif
    }
	lc = [NSLayoutConstraint constraintWithItem:c attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
	[v addConstraint:lc];


#if 0
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
    {
		NSLog(@"KEY VIEW FRAME: %@", NSStringFromCGRect(v.frame));
		NSLog(@"C FRAME: %@", NSStringFromCGRect(c.frame));
        NSLog(@"SUBVIEWS: %@", v.subviews);
		NSLog(@"%@", [v constraints]);

    } );
	[v setNeedsUpdateConstraints];
#endif

	__block UIView *firstView;
	[v.subviews enumerateObjectsUsingBlock:^(UIView *enclosingView, NSUInteger idx, BOOL *stop)
		{
			//NSLog(@"BUTTON: %@ subviews: %@", enclosingView, enclosingView.subviews);
		
			UIView *button = [enclosingView.subviews lastObject];
			assert(button);

			if(!idx) {
				firstView = button;
			} else {
				NSLayoutConstraint *le = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:firstView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
				NSLayoutConstraint *l0 = [NSLayoutConstraint constraintWithItem:enclosingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:0];
				//[v addConstraint:lc];
				if([v->pSet containsIndex:idx]) {
					[v->pConstraints addObject:le];
				} else {
					[v->pConstraints addObject:l0];
				
				}
				if([v->lSet containsIndex:idx]) {
					[v->lConstraints addObject:le];
				} else {
					[v->lConstraints addObject:l0];
				}
			}
		} ];
	
	UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	if(UIInterfaceOrientationIsPortrait(interfaceOrientation) == UIInterfaceOrientationPortrait) {
		[v addConstraints:v->pConstraints];
	} else {
		[v addConstraints:v->lConstraints];
	}

    UIView *border1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barWidth, 1)];
	border1.tag = 100;
    border1.backgroundColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1.];
    border1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [v addSubview:border1];
    
    UIView *border2 = [[UIView alloc] initWithFrame:CGRectMake(0, 1, barWidth, 1)];
    border2.backgroundColor = [UIColor colorWithRed:191/255. green:191/255. blue:191/255. alpha:1.];
    border2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	border2.tag = 101;
    [v addSubview:border2];

    t.inputAccessoryView = v;
	return v;
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

#if 0

	v->pConstraints	= [NSMutableArray array];
	v->lConstraints	= [NSMutableArray array];
	v->pSet			= [NSMutableIndexSet new];
	v->lSet			= [NSMutableIndexSet new];
#endif

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
    
	// Not needed! DFH
    //loc.origin.y += textView.contentOffset.y;
    
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

#if 0
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	NSLog(@"LAYOUT SUBVIEWS %@", self.subviews);
}
#endif

@end

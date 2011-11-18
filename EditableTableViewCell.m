//
//  IngredientTableViewCell.m
//  Recipe Box
//
//  Created by Jacques Fortier on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EditableTableViewCell.h"

static const CGFloat kTextViewWidth = 320;

#define kFontSize ([UIFont systemFontSize])
//#define kMediumFont [UIFont font

static const CGFloat kTextViewInset = 31;
static const CGFloat kTextViewVerticalPadding = 15;
static const CGFloat kTopPadding = 6;
static const CGFloat kBottomPadding = 6;

static UITextView *dummyTextView;

@implementation EditableTableViewCell

@synthesize delegate;
@synthesize textView;
@synthesize text;
@synthesize placeholder;

- (void)dealloc {
    [textView release], textView = nil;
    [super dealloc];
}

+ (UITextView *)createTextView {
    UIPlaceHolderTextView *newTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectZero];
    newTextView.font = STANDARD_FONT_16;
    newTextView.backgroundColor = [UIColor clearColor];
    newTextView.opaque = YES;
    newTextView.scrollEnabled = NO;
    newTextView.showsVerticalScrollIndicator = NO;
    newTextView.showsHorizontalScrollIndicator = NO;
    newTextView.contentInset = UIEdgeInsetsZero;
    newTextView.returnKeyType = UIReturnKeyDone;
    
    return newTextView;
}

+ (UITextView *)dummyTextView {
    return dummyTextView;
}

+ (CGFloat)heightForText:(NSString *)text {
    if (text == nil || text.length == 0) {
        text = @"Xy";
    }
    
    dummyTextView.text = text;
    
    CGSize textSize = dummyTextView.contentSize;
    
    return textSize.height + kBottomPadding + kTopPadding - 1;
}


+ (void)initialize {
    dummyTextView = [EditableTableViewCell createTextView];
    dummyTextView.alpha = 0.0;
    dummyTextView.frame = CGRectMake(0, 0, kTextViewWidth, 500);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        textView = (UIPlaceHolderTextView *) [EditableTableViewCell createTextView];
        textView.delegate = self;
        [self.contentView addSubview:textView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect contentRect = self.contentView.bounds;

    contentRect.origin.y += kTopPadding;
    contentRect.size.height -= kTopPadding + kBottomPadding;

    textView.frame = contentRect;
    textView.contentOffset = CGPointZero;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setText:(NSMutableString *)newText {
    if (newText != text) {
        [text release];
        text = [newText retain];
        textView.text = newText;
        //NSLog(@"New height: %f", textView.contentSize.height);
    }
}

- (void)setPlaceholder:(NSString *)newPlaceholder {
    textView.placeholder = newPlaceholder;
}

- (NSString *)placeholder {
    return textView.placeholder;
}

#pragma mark -
#pragma mark UITextView delegate

- (void) textViewDidBeginEditing:(UITextView *)theTextView {
    if ([delegate respondsToSelector:@selector(editableTableViewCellDidBeginEditing:)]) {
        [delegate editableTableViewCellDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)theTextView {
    [text setString:theTextView.text];

    if ([delegate respondsToSelector:@selector(editableTableViewCellDidEndEditing:)]) {
        [delegate editableTableViewCellDidEndEditing:self];
    }
}


- (void)textViewDidChange:(UITextView *)theTextView {
    CGFloat suggested = [self suggestedHeight];
    
    if (fabs(suggested - self.frame.size.height) > 0.01) {
        // NSLog(@"should change height");
        if ([delegate respondsToSelector:@selector(editableTableViewCell:heightChangedTo:)]) {
            [delegate editableTableViewCell:self heightChangedTo:suggested];
        }
    }
}

- (CGFloat)suggestedHeight {
    return textView.contentSize.height + kTopPadding + kBottomPadding - 1;
}

- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)newText {
    if ([newText isEqualToString:@"\n"]) {
        [theTextView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end

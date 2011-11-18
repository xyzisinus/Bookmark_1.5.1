#import <UIKit/UIKit.h>
#import "EditableTableViewCellDelegate.h"
#import "UIPlaceholderTextView.h"

@interface EditableTableViewCell : UITableViewCell<UITextViewDelegate> {
}

@property(nonatomic, assign)    id<NSObject, EditableTableViewCellDelegate> delegate;
@property(nonatomic, readonly)  UIPlaceHolderTextView                       *textView;
@property(nonatomic, retain)    NSMutableString                             *text;
@property(nonatomic, assign)    NSString                                    *placeholder;

+ (UITextView *)dummyTextView;
+ (CGFloat)heightForText:(NSString *)text;

- (CGFloat)suggestedHeight;

@end

//
//  TouchLabel.h
//  Bookmark
//
//  Created by Barry Ezell on 8/2/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TouchLabelDelegate
@required
- (void)labelWasTouched:(UILabel *)label;
@end

@interface TouchLabel : UILabel {
	id<TouchLabelDelegate> labelDelegate;
}

@property (nonatomic, assign) id<TouchLabelDelegate> labelDelegate;

@end

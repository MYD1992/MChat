//
//  LTBarButtonItem.m
//  MChat
//
//  Created by 林涛 on 2017/2/9.
//  Copyright © 2017年 林涛. All rights reserved.
//

#import "LTBarButtonItem.h"



@implementation LTBarButtonItem
{
    UIImageView * _imageView;
    UILabel * _numberLabel;
    NSInteger _number;
}

-(instancetype) initWithTarget:(id)target action:(_Nonnull SEL)action image:(UIImage *)image{
    if (self = [super initWithFrame:CGRectMake(0, 0, 34, 30)]) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 , 25, 35)];
        _imageView.image = image;
        [self addSubview:_imageView];
        
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(23, 7, 16, 16)];
        _numberLabel.backgroundColor = [UIColor redColor];
        _numberLabel.font = [UIFont systemFontOfSize:10];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
//        _numberLabel.text = @"88";
        _numberLabel.layer.masksToBounds = YES;
        _numberLabel.layer.cornerRadius = 8;
        _numberLabel.hidden = YES;
        [self addSubview:_numberLabel];
        
        _imageView.userInteractionEnabled = YES;
        _numberLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_numberLabel addGestureRecognizer:tap];
        [_imageView addGestureRecognizer:tap];
        [self addGestureRecognizer:tap];
        [self setClipsToBounds:NO];
    }
    return self;
}




-(void)setNumber:(NSInteger)number{
    _number = number;
    if (number == 0) {
        _numberLabel.hidden = YES;
    }else{
        _numberLabel.hidden = NO;
        _numberLabel.text = [NSString stringWithFormat:@"%ld",number];
    }
}

-(void)setVerticalPositionAdjustment:(CGFloat) adjustment{
    CGRect imageFrame = _imageView.frame;
    CGRect numberFrame = _numberLabel.frame;
    imageFrame.origin.x = imageFrame.origin.x + adjustment;
    numberFrame.origin.x = _numberLabel.frame.origin.x + adjustment;
    _imageView.frame = imageFrame;
    _numberLabel.frame = numberFrame;
}

@end

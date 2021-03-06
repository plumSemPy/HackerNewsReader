//
//  HNCommentCell.m
//  HackerNewsReader
//
//  Created by Ryan Nystrom on 4/11/15.
//  Copyright (c) 2015 Ryan Nystrom. All rights reserved.
//

#import "HNCommentCell.h"

#import "UIColor+HackerNews.h"
#import "UIFont+HackerNews.h"

#import "HNComment+AttributedStrings.h"

@interface HNCommentCell ()

@property (nonatomic, strong, readonly) UIView *commentContentView;
@property (nonatomic, strong, readonly) UIView *overlayView;

@end

@implementation HNCommentCell

@synthesize commentContentView = _commentContentView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = YES;

        _commentContentView = [[UIView alloc] init];
        _commentContentView.opaque = YES;
        _commentContentView.backgroundColor = [UIColor whiteColor];
        _commentContentView.contentMode = UIViewContentModeLeft;
        _commentContentView.layer.contentsScale = [UIScreen mainScreen].scale;
        _commentContentView.layer.contentsGravity = kCAGravityTopLeft;
        [self.contentView addSubview:_commentContentView];

        _overlayView = [[UIView alloc] init];
        _overlayView.backgroundColor = [UIColor hn_overlayHighlightColor];
        _overlayView.hidden = YES;
        [self.contentView addSubview:_overlayView];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [tap addTarget:self action:@selector(onTapGesture:)];
        [self.contentView addGestureRecognizer:tap];

        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
        longPress.minimumPressDuration = 0.25;
        [longPress addTarget:self action:@selector(onLongPressGesture:)];
        [self.contentView addGestureRecognizer:longPress];
    }
    return self;
}


#pragma mark - Public API

+ (UIEdgeInsets)contentInsetsForIndentationLevel:(NSUInteger)indentationLevel indentationWidth:(CGFloat)indentationWidth {
    return UIEdgeInsetsMake(8.0, 15.0 + indentationLevel * indentationWidth, 8.0, 15.0);
}

- (void)setCommentBitmap:(id)commentBitmap {
    self.commentContentView.layer.contents = commentBitmap;
}

- (void)setCommentContentSize:(CGSize)commentContentSize
             indentationLevel:(NSUInteger)indentationLevel
             indentationWidth:(CGFloat)indentationWidth {
    UIEdgeInsets insets = [self.class contentInsetsForIndentationLevel:indentationLevel indentationWidth:indentationWidth];
    CGPoint inset = CGPointMake(floorf(insets.left), floorf(insets.top));
    commentContentSize.width = ceilf(commentContentSize.width);
    commentContentSize.height = ceilf(commentContentSize.height);
    self.commentContentView.frame = (CGRect){inset, commentContentSize};
    [self setNeedsLayout];
}


#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    self.overlayView.frame = self.contentView.bounds;
}


#pragma mark - Gestures

- (void)onTapGesture:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.commentContentView];
    if ([self.delegate respondsToSelector:@selector(commentCell:didTapCommentAtPoint:)]) {
        [self.delegate commentCell:self didTapCommentAtPoint:point];
    }
}

- (void)onLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    if (recognizer.state == UIGestureRecognizerStateBegan &&
        [self.delegate respondsToSelector:@selector(commentCell:didLongPressAtPoint:)]) {
        [self.delegate commentCell:self didLongPressAtPoint:point];
    }
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.overlayView.hidden = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.overlayView.hidden = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.overlayView.hidden = YES;
}


@end

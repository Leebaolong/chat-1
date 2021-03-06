//
//  MIMMessageImageView.m
//  MyIM
//
//  Created by Jonathan on 15/8/19.
//  Copyright (c) 2015年 Jonathan. All rights reserved.
//

#import "MIMMessageImageView.h"

#import "SDWebImageManager.h"

#import "SDWebImageDownloaderOperation.h"

typedef void(^MIMMessageImageTap)(MIMMessageImageView *messsageImageView);

@interface MIMMessageImageView ()
{
    CAShapeLayer *_maskLayer;
}
@property (assign, nonatomic) MIMMessageCellStyle style;

@property (strong, nonatomic) MIMMessageImageTap imageTapBlock;

@property (strong, nonatomic) NSString *url;

@property (strong, nonatomic) SDWebImageDownloaderOperation *currentOperation;

@property (assign, nonatomic) CGSize   imageSize;

@end

@implementation MIMMessageImageView

- (instancetype)initFromNibWithCellStyle:(MIMMessageCellStyle)style
{
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([MIMMessageImageView class]) owner:nil options:nil] lastObject];
    if (self) {
        _style = style;
        
        _imageSize = CGSizeMake(200, 200);

        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        _maskLayer.strokeColor = [UIColor clearColor].CGColor;
        _maskLayer.contents = (id)[UIImage imageNamed:self.style == MIMMessageCellStyleOutgoing?@"chatto_bg_normal":@"chatfrom_bg_normal"] .CGImage;
        _maskLayer.frame = CGRectMake(0, 0, _imageSize.width, _imageSize.height);
        _maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
        _maskLayer.contentsScale = [UIScreen mainScreen].scale;
        
        self.layer.mask = _maskLayer;
//        self.imageView.layer.mask = _maskLayer;

        
    }
    return self;
}

- (void)awakeFromNib
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick)];
    [self.imageView addGestureRecognizer:gesture];
}

- (void)imageClick
{
    if (self.imageTapBlock) {
        self.imageTapBlock(self);
    }
}

- (void)receiveImageTapWithBlock:(void (^)(MIMMessageImageView *))block
{
    self.imageTapBlock = block;
}


- (void)resetMaskSizeWithImageSize:(CGSize)size
{
    if (CGSizeEqualToSize(self.imageSize, size)) {
        return;
    }
    self.imageSize = size;
    
    CGSize showSize = [MIMMessageImageView getImageViewSizeWithImageSize:size];

    
    _maskLayer = [CAShapeLayer layer];
    _maskLayer.fillColor = [UIColor clearColor].CGColor;
    _maskLayer.strokeColor = [UIColor clearColor].CGColor;
    _maskLayer.contents = (id)[UIImage imageNamed:self.style == MIMMessageCellStyleOutgoing?@"chatto_bg_normal":@"chatfrom_bg_normal"] .CGImage;
    _maskLayer.frame = CGRectMake(0, 0, showSize.width, showSize.height);
    _maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
    _maskLayer.contentsScale = [UIScreen mainScreen].scale;
    
    self.layer.mask = _maskLayer;
    
//    CGSize showSize = [MIMMessageImageView getImageViewSizeWithImageSize:size];
//    _maskLayer.frame = CGRectMake(0, 0, showSize.width, showSize.height);
}

- (void)loadViewWithImageUrl:(NSString *)url imageSize:(CGSize)size atIndex:(NSInteger)index
{

//    if ([_url isEqualToString:url]) {
//        return;
//    }
    self.url = url;
    _index = index;

    [self resetMaskSizeWithImageSize:size];
    
    __weak typeof(self) weakSelf = self;
    if (self.currentOperation) {
        [self.currentOperation cancel];
    }
    self.currentOperation = [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            [weakSelf setContentImage:image];
        }
    }];
}

- (void)loadViewWithImage:(UIImage *)image atIndex:(NSInteger)index;
{
    [self resetMaskSizeWithImageSize:image.size];
    _index = index;
    [self setContentImage:image];
}

- (void)setContentImage:(UIImage *)image
{
    [self.imageView setImage:image];
}


+ (CGSize)getImageViewSizeWithImageSize:(CGSize )imageSize
{
//    return CGSizeMake(150, 150);

 //  处理 图片显示大小
    CGFloat ratio           = imageSize.height / imageSize.width; //高宽比
    CGFloat maxWidth        = MIM_MESSAGE_MAX_IMAGE_WIDTH;
    CGFloat minWidth        = MIM_MESSAGE_MIN_IMAGE_WIDTH;
    CGFloat maxHeight       = MIM_MESSAGE_MAX_IMAGE_HEIGHT;
    CGFloat minHeight       = MIM_MESSAGE_MIN_IMAGE_HEIGHT;
    CGFloat minHeightRatio  = minHeight / maxWidth; //最小高度 高宽比
    CGFloat minWidthRatio   = maxHeight / minWidth; //最小宽度 高宽比
    
    if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
        return CGSizeMake(maxWidth, maxHeight);
    }
    
    if (ratio <= 1) {//宽大于高
        if (ratio <= minHeightRatio) { //比例小于minHeightRatio 则使用minHeightRatio
            if(imageSize.width < maxWidth){ //图片宽小于最大宽
                return CGSizeMake(imageSize.width, imageSize.width *minHeightRatio);
            }
            return CGSizeMake(maxWidth, minHeight);
        }
        else{
            if(imageSize.width < maxWidth){ //图片宽小于最大宽
                return CGSizeMake(imageSize.width, imageSize.height);
            }
            return CGSizeMake(maxWidth, maxWidth * ratio);
        }
    }
    else{ //高大于宽
        if (ratio >= minWidthRatio) { //比例大于 minWidthRatio
            if(imageSize.height < maxHeight){ //图片高小于最大高
                return CGSizeMake(imageSize.height / minWidthRatio, imageSize.height);
            }
            return CGSizeMake(minWidth, minHeight);
        }
        else{
            if(imageSize.height < maxHeight){ //图片高小于最大高
                return CGSizeMake(imageSize.width, imageSize.height);
            }
            return CGSizeMake(maxHeight / ratio, maxHeight);
        }
    }
    
    return CGSizeMake(150, 150);
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

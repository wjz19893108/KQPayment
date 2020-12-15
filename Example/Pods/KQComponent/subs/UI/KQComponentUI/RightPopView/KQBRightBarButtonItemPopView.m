//
//  KQBRightBarButtonItemPopView.m
//  kuaiQianbao
//
//  Created by building wang on 16/1/14.
//
//

#import "KQBRightBarButtonItemPopView.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kArrowHeight 10.f
#define kArrowCurvature 6.f
#define SPACE 2.f
#define ROW_HEIGHT 44.f
#define TITLE_FONT [UIFont systemFontOfSize:16]

static const NSString *kIcon = @"icon";
static const NSString *kTitle = @"title";

@interface KQBRightBarButtonItemPopView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic) CGPoint showPoint;

@property (nonatomic, strong) UIButton *handerView;
@property (nonatomic, strong) UIButton *maskView;

@end

@implementation KQBRightBarButtonItemPopView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderColor = UIColorFromRGB(67, 67, 67);
        self.fillColor = UIColorFromRGB(67, 67, 67);
        self.fontColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.maskColor = [UIColor clearColor];
        self.maskAlpha = 1.0f;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithPoint:(CGPoint)point popViewArray:(NSArray *)popViewArray{
    self = [super init];
    if (self) {
        self.showPoint = point;
        _titleArray = [@[] mutableCopy];
        _imageArray = [@[] mutableCopy];
        [popViewArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_titleArray addObject:obj[kTitle]];
            [_imageArray addObject:KQC_NON_NIL(obj[kIcon])];
        }];
        
        self.frame = [self getViewFrame];
        [self addSubview:self.tableView];
    }
    return self;
}

- (CGRect)getViewFrame{
    CGRect frame = CGRectZero;
    
    frame.size.height = [self.titleArray count] * ROW_HEIGHT + SPACE + kArrowHeight;
    
    for (NSString *title in self.titleArray) {
        //iOS7兼容性修改 feng.zou 2016-03-28
        //CGFloat width =  [title sizeWithFont:TITLE_FONT constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByCharWrapping].width;
        CGFloat width = [NSString kqc_calcStrSize:title font:TITLE_FONT lineBreakMode:NSLineBreakByCharWrapping maxSize:CGSizeMake(300, 100)].width;
        frame.size.width = MAX(width, frame.size.width);
    }
    
    if ([self.titleArray count] == [self.imageArray count]) {
        frame.size.width = 10 + 25 + 10 + frame.size.width + 40;
    }else{
        frame.size.width = 10 + frame.size.width + 40;
    }
    
    frame.origin.x = self.showPoint.x - frame.size.width/2;
    frame.origin.y = self.showPoint.y;
    
    //左间隔最小5x
    if (frame.origin.x < 5) {
        frame.origin.x = 5;
    }
    //右间隔最小5x
    if ((frame.origin.x + frame.size.width) > 315) {
        frame.origin.x = KQC_SCREEN_WIDTH - frame.size.width-5;
    }
    
    return frame;
}

- (void)show{
    self.handerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_handerView setFrame:[UIScreen mainScreen].bounds];
    [_handerView setBackgroundColor:[UIColor clearColor]];
    [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_handerView addSubview:self];
    
    self.maskView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.maskView.frame = CGRectMake(0, KQC_NAVIGATIONBAR_HEIGHT + KQC_STATUSBAR_HEIGHT, KQC_SCREEN_HEIGHT, KQC_SCREEN_HEIGHT - KQC_NAVIGATIONBAR_HEIGHT - KQC_STATUSBAR_HEIGHT);
    self.maskView.backgroundColor = self.maskColor;
    self.maskView.alpha = self.maskAlpha;
    [self.maskView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_handerView addSubview:self.maskView];
    [_handerView bringSubviewToFront:self];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:_handerView];
    
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
    self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width, arrowPoint.y / self.frame.size.height);
    self.frame = [self getViewFrame];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)dismiss{
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animate{
    if (!animate) {
        [_handerView removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_handerView removeFromSuperview];
    }];
    
}

#pragma mark - UITableView
- (UITableView *)tableView{
    if (_tableView != nil) {
        return _tableView;
    }
    
    CGRect rect = self.frame;
    rect.origin.x = SPACE;
    rect.origin.y = kArrowHeight + SPACE;
    rect.size.width -= SPACE * 2;
    rect.size.height -= (SPACE * 2 + kArrowHeight);
    
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceHorizontal = NO;
    _tableView.alwaysBounceVertical = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    [self setTableViewSeperatorLine:_tableView];
    //    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    return _tableView;
}

- (void) setTableViewSeperatorLine:(UITableView*)tableView {
    if([tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void) setTableCellSeperatorLine:(UITableViewCell*)cell {
    if([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_titleArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundView = [[UIView alloc] init];
        cell.backgroundView.backgroundColor = self.fillColor;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = self.fontColor;
        cell.textLabel.textAlignment = self.textAlignment;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setTableCellSeperatorLine:cell];
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }

    if ([_imageArray count] == [_titleArray count]) {
        NSString *imgName = [_imageArray objectAtIndex:indexPath.row];
        if ([imgName hasPrefix:@"http://"]
            || [imgName hasPrefix:@"https://"]) {
            UIImage *image = [UIImage kqc_imageWithColor:[UIColor whiteColor] size:CGSizeMake(15, 15)];
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:image];
        } else {
            cell.imageView.image = [UIImage imageNamed:imgName];
        }
    }
    
    cell.textLabel.text = [_titleArray objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.selectRowAtIndex) {
        self.selectRowAtIndex(indexPath.row);
    }
    [self dismiss:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ROW_HEIGHT;
}

- (void)drawRect:(CGRect)rect{
    [self.borderColor set]; //设置线条颜色
    
    CGRect frame = CGRectMake(0, 10, self.bounds.size.width, self.bounds.size.height - kArrowHeight);
    
    static float cornerRadius = 6;
    
    float xMin = CGRectGetMinX(frame);
    float yMin = CGRectGetMinY(frame);
    
    float xMax = CGRectGetMaxX(frame);
    float yMax = CGRectGetMaxY(frame);
    
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
    
    UIBezierPath *popoverPath = [UIBezierPath bezierPath];
    [popoverPath moveToPoint:CGPointMake(xMin + cornerRadius, yMin)];//左上角
    
    /********************向上的箭头**********************/
    [popoverPath addLineToPoint:CGPointMake(arrowPoint.x - kArrowHeight, yMin)];//left side
    [popoverPath addCurveToPoint:arrowPoint
                   controlPoint1:CGPointMake(arrowPoint.x - kArrowHeight + kArrowCurvature, yMin)
                   controlPoint2:arrowPoint];//actual arrow point
    
    [popoverPath addCurveToPoint:CGPointMake(arrowPoint.x + kArrowHeight, yMin)
                   controlPoint1:arrowPoint
                   controlPoint2:CGPointMake(arrowPoint.x + kArrowHeight - kArrowCurvature, yMin)];//right side
    /********************向上的箭头**********************/
    
    
//    [popoverPath addLineToPoint:CGPointMake(xMax - cornerRadius, yMin)];//右上角
    [popoverPath addArcWithCenter:CGPointMake(xMax - cornerRadius, yMin + cornerRadius) radius:cornerRadius startAngle:1.5 * M_PI endAngle:0 clockwise:YES];
    
//    [popoverPath addLineToPoint:CGPointMake(xMax, yMax - cornerRadius)];//右下角
    [popoverPath addArcWithCenter:CGPointMake(xMax - cornerRadius, yMax - cornerRadius) radius:cornerRadius startAngle:0 endAngle:0.5 * M_PI clockwise:YES];
    
//    [popoverPath addLineToPoint:CGPointMake(xMin + cornerRadius, yMax)];//左下角
    [popoverPath addArcWithCenter:CGPointMake(xMin + cornerRadius, yMax - cornerRadius) radius:cornerRadius startAngle:0.5 * M_PI endAngle:M_PI clockwise:YES];
    
//    [popoverPath addLineToPoint:CGPointMake(xMin, yMin + cornerRadius)];//左下角
    [popoverPath addArcWithCenter:CGPointMake(xMin + cornerRadius, yMin + cornerRadius) radius:cornerRadius startAngle:1 * M_PI endAngle:1.5 * M_PI clockwise:YES];
    
    //填充颜色
    [self.fillColor setFill];
    [popoverPath fill];
    
//    [popoverPath closePath];
    [popoverPath stroke];
}

@end

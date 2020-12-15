//
//  KQShareView.m
//  kuaiQianbao
//
//  Created by building wang on 15/8/19. Modified by zouf on 15/11/3.
//
//

#import "KQBShareView.h"
#import "KQBShareButtonData.h"
#import "KQCShareToSNS.h"
#import <Photos/Photos.h>
//#import "UIView+KQBAddition.h"

#define SHARE_BACKGROUND_COLOR                  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]
#define SHARE_ANIMATE_DURATION                  0.25f

#define SHARE_TITLE_FONT                        [UIFont systemFontOfSize:17]

#define SHARE_LABEL_FONT                        [UIFont systemFontOfSize:12]
#define SHARE_LABEL_SHADOW_OFFSET               CGSizeMake(0, 0.8f)
#define SHARE_LABEL_NUMBER_LINES                2

#define TITLE_VIEW_HEIGHT                       40      //顶部标题视图的高度，如果有的话
#define CANCEL_VIEW_HEIGHT                      44      //底部取消视图高度
#define SHARE_VIEW_HEIGHT                       110     //中间分享视图高度
#define SHARE_VIEW_NUM_PER_LINE                 3       //每行有几个分享按钮

#define SHARE_BUTTON_WIDTH                      50      //分享按钮宽度
#define SHARE_BUTTON_HEIGHT                     50      //分享按钮高度

#define SHARE_TITLE_HEIGHT                      20      //分享标题高度

#define SHARE_BUTTON_START_TAG                  10990   // 分享按钮的tag从这个开始，加分享类型枚举值

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface KQBShareView ()
{
    dispatch_semaphore_t semaphore;
}

@property (nonatomic,strong) UIView *backGroundView;
@property (nonatomic, strong) NSArray *shareButtonDataArray;

@end

@implementation KQBShareView

#pragma mark - Public method
- (instancetype)initWithTitle:(NSString *)title{
    self = [super init];
    if (self) {
        semaphore = dispatch_semaphore_create(1);
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, KQC_SCREEN_WIDTH, KQC_SCREEN_HEIGHT);
        self.backgroundColor = SHARE_BACKGROUND_COLOR;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        [self addGestureRecognizer:tapGesture];
        
        //初始化分享按钮数据模型
        KQBShareButtonData *dataWXSceneSession = [[KQBShareButtonData alloc] initWithData:KQCShareTypeWXSceneSession buttonTitle:@"微信好友" buttonIcon:@"icon_session"];
        KQBShareButtonData *dataWXSceneTimeline = [[KQBShareButtonData alloc] initWithData:KQCShareTypeWXSceneTimeline buttonTitle:@"微信朋友圈" buttonIcon:@"icon_timeline"];
        if (self.shareData.shareIsMiniProgram) {
            self.shareButtonDataArray = @[dataWXSceneSession];
        } else {
            self.shareButtonDataArray = @[dataWXSceneSession, dataWXSceneTimeline];
        }
        //创建分享按钮
        [self creatButtonsWithTitle:title];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title shareData:(KQCShareData *)data {
    self = [super init];
    if (self) {
        self.shareData = data;
        semaphore = dispatch_semaphore_create(1);
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, KQC_SCREEN_WIDTH, KQC_SCREEN_HEIGHT);
        self.backgroundColor = SHARE_BACKGROUND_COLOR;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        [self addGestureRecognizer:tapGesture];
        
        //初始化分享按钮数据模型
        KQBShareButtonData *dataWXSceneSession = [[KQBShareButtonData alloc] initWithData:KQCShareTypeWXSceneSession buttonTitle:@"微信好友" buttonIcon:@"icon_session"];
        KQBShareButtonData *dataWXSceneTimeline = [[KQBShareButtonData alloc] initWithData:KQCShareTypeWXSceneTimeline buttonTitle:@"朋友圈" buttonIcon:@"icon_timeline"];
        KQBShareButtonData *dataWXScenePhotographs = [[KQBShareButtonData alloc] initWithData:KQCShareTypePhotographs buttonTitle:@"保存到相册" buttonIcon:@"saveToAlbum"];
        
        if (self.shareData.shareIsMiniProgram) {
            self.shareButtonDataArray = @[dataWXSceneSession];
        } else {
            if (self.shareData.shareImage) {
                self.shareButtonDataArray = @[dataWXSceneTimeline, dataWXSceneSession, dataWXScenePhotographs];
            } else {
                self.shareButtonDataArray = @[dataWXSceneTimeline, dataWXSceneSession];
            }
        }
        
        //创建分享按钮
        [self creatButtonsWithTitle:title];
    }
    return self;
}

- (void)show{
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}

- (void)dismiss
{
    [self tappedCancel];
}

#pragma mark - Praviate method
- (void)creatButtonsWithTitle:(NSString *)title{
    //创建标题
    UILabel *titleLabel;
    if (title.length > 0) {
        titleLabel = [self creatTitleLabelWith:title];
    }
    
    CGFloat s = self.shareButtonDataArray.count;
    CGFloat a = s/SHARE_VIEW_NUM_PER_LINE;
    NSInteger b = ceil(a);
    
    //计算分享视图高度
    CGFloat shareViewHeight = (b * SHARE_VIEW_HEIGHT + CANCEL_VIEW_HEIGHT + titleLabel.size.height);
    
    //生成KQShareView
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, KQC_SCREEN_HEIGHT, KQC_SCREEN_HEIGHT, shareViewHeight)];
    self.backGroundView.backgroundColor = UIColorFromRGB(229, 235, 236);
    
    //分享视图创建完成后在加入标题
    [self.backGroundView addSubview:titleLabel];
    
    //给KQShareView添加响应事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackGroundView)];
    [self.backGroundView addGestureRecognizer:tapGesture];
    
    [self addSubview:self.backGroundView];
    
    //取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, shareViewHeight - CANCEL_VIEW_HEIGHT, KQC_SCREEN_WIDTH, CANCEL_VIEW_HEIGHT);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn.layer setBorderWidth:1.0];//画线的宽度
    [cancelBtn.layer setBorderColor:UIColorFromRGB(232,232,232).CGColor];//颜色
    [cancelBtn.layer setMasksToBounds:YES];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [self.backGroundView addSubview:cancelBtn];
    
    //各个分享按钮视图
    [self.shareButtonDataArray enumerateObjectsUsingBlock:^(KQBShareButtonData* data, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger line = idx/SHARE_VIEW_NUM_PER_LINE;   //第几行
        NSInteger column = idx%SHARE_VIEW_NUM_PER_LINE; //第几列
        
        //创建空白的占位View，后面的分享按钮和label都再次View中添加
        UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(column*(KQC_SCREEN_WIDTH/SHARE_VIEW_NUM_PER_LINE), line*SHARE_VIEW_HEIGHT+titleLabel.size.height, KQC_SCREEN_WIDTH/SHARE_VIEW_NUM_PER_LINE, SHARE_VIEW_HEIGHT)];
        [self.backGroundView addSubview:shareView];
        
        UIButton *shareButton = [UIButton new];
        shareButton.tag = data.shareType + SHARE_BUTTON_START_TAG;
        [shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setImage:[UIImage imageNamed:data.shareButtonIcon] forState:UIControlStateNormal];
        [shareView addSubview:shareButton];
        
        UILabel *shareLabel = [self creatShareLabel];
        shareLabel.text = data.shareButtonTitle;
        [shareView addSubview:shareLabel];
        
        //分享按钮约束，距离顶部15个单位，水平居中
        [shareButton mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(shareView).with.offset(20);
            make.centerX.equalTo(shareView);
            make.size.mas_equalTo(CGSizeMake(SHARE_BUTTON_WIDTH, SHARE_BUTTON_HEIGHT));
        }];
        
        //title约束，距离底部5个单位
        [shareLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(shareView).with.offset(0);
            make.bottom.equalTo(shareView).with.offset(-15);
            make.size.mas_equalTo(CGSizeMake(KQC_SCREEN_WIDTH/SHARE_VIEW_NUM_PER_LINE, SHARE_TITLE_HEIGHT));
        }];
    }];
    
    [UIView animateWithDuration:SHARE_ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, KQC_SCREEN_HEIGHT-shareViewHeight, KQC_SCREEN_WIDTH, shareViewHeight)];
    } completion:^(BOOL finished) {
    }];
}

// 图标底部名称
- (UILabel *)creatShareLabel{
    UILabel *shareLabel = [UILabel new];
    shareLabel.backgroundColor = [UIColor clearColor];
    shareLabel.textAlignment = NSTextAlignmentCenter;
    shareLabel.font = SHARE_LABEL_FONT;
    shareLabel.textColor = UIColorFromRGB(153, 153, 153);
    return shareLabel;
}

// 分享到
- (UILabel *)creatTitleLabelWith:(NSString *)title{
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KQC_SCREEN_WIDTH, TITLE_VIEW_HEIGHT)];
    titlelabel.backgroundColor = [UIColor clearColor];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.shadowOffset = SHARE_LABEL_SHADOW_OFFSET;
    titlelabel.font = SHARE_TITLE_FONT;
    titlelabel.text = title;
    titlelabel.textColor = UIColorFromRGB(102, 102, 102);
    titlelabel.numberOfLines = SHARE_LABEL_NUMBER_LINES;
    return titlelabel;
}

- (void)shareButtonClicked:(UIButton*)sender
{
    //防止重复点击分享按钮
    if (dispatch_semaphore_wait(semaphore, 0) != 0) {
        return;
    }
    if (self.selectedViewBlock) {
        self.selectedViewBlock(sender.tag - SHARE_BUTTON_START_TAG);
    }
    if (self.selectedBlock) {
        self.selectedBlock(sender.tag - SHARE_BUTTON_START_TAG, self.shareData);
    }
    
    if ((sender.tag - SHARE_BUTTON_START_TAG) ==  KQCShareTypePhotographs) {
        [self photoPermissionCheck];
        [self tappedCancel];
        return;
    }
    
    if (self.shareData.shareImage) {
        //如果图片已经下载了，这里就会直接走的实际分享
        if ([self shareToSNS:sender.tag - SHARE_BUTTON_START_TAG]) {
            return;
        }
    }
    
    //到这里可以开始等待下载过程
    WS(weakSelf);
    if (self.shareData.shareIconDownloaded == nil) {
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:self.shareData.shareIconUrl] options:SDWebImageRefreshCached|SDWebImageRetryFailed progress:NULL completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                weakSelf.shareData.shareIconDownloaded = image;
            }
            else{
                //使用一个默认的icon
                weakSelf.shareData.shareIconDownloaded = [UIImage imageNamed:@"Icon"];
            }
            [weakSelf shareToSNS:sender.tag - SHARE_BUTTON_START_TAG];
        }];
    }
}

- (BOOL)shareToSNS:(NSInteger)tag
{
    if (!self.shareData.shareImage) {
        //到这里可以结束等待下载过程
        if (!self.shareData.shareIconDownloaded) {
            return NO;
        }
    }
    [KQCShareToSNS shareDataToSNS:self.shareData shareType:(KQCShareType)tag completesBlock:^(BOOL isSuccess) {
        
    }];
    //确定已经调用了分享，可以收起界面
    [self tappedCancel];
    return YES;
}

- (void)tappedCancel{
    [UIView animateWithDuration:SHARE_ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, KQC_SCREEN_HEIGHT, KQC_SCREEN_WIDTH, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)tappedBackGroundView{
    DLog(@"走你");
}

- (void)dealloc
{
    //dealloc前需要释放信号，否则会引起崩溃
    dispatch_semaphore_signal(semaphore);
    DLog(@"%@:dealloc", self);
}

#pragma mark - 保存到相册
#pragma mark -- <获取当前App对应的自定义相册>
- (PHAssetCollection*)createCollection {
    //获取App名字
    NSString *title = [NSBundle mainBundle].infoDictionary[(__bridge NSString*)kCFBundleNameKey];
    //抓取所有【自定义相册】
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 查询当前App对应的自定义相册
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    //当前对应的app相册没有被创建
    NSError *error = nil;
    __block NSString *createCollectionID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        //创建一个【自定义相册】(需要这个block执行完，相册才创建成功)
        createCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        DLog(@"创建相册失败");
        return nil;
    }
    // 根据唯一标识，获得刚才创建的相册
    PHAssetCollection *createCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createCollectionID] options:nil].firstObject;
    return createCollection;
}

// 权限检查
- (void)photoPermissionCheck {
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    // 检查用户访问权限
    // 如果用户还没有做出选择，会自动弹框
    // 如果之前已经做过选择，会直接执行block
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusDenied ) { // 用户拒绝当前App访问权限
                if (oldStatus != PHAuthorizationStatusNotDetermined) {
                    DLog(@"提醒用户打开开关");
                    [self showAlert];
                }
            } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前App访问
                [self saveImageToAlbum];
            } else if (status == PHAuthorizationStatusRestricted) { // 无法访问相册
                DLog(@"因系统原因，无法访问相册");
                [self showAlert];
            }
        });
    }];
}

- (void)showAlert {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"无法启动相册"
                              message:@"请为快钱刷开放照片权限 手机设置-> 隐私-> 照片 -> 快钱刷(打开)"
                              delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
    [alertView show];
}

// 保存图片到相册
- (void)saveImageToAlbum {
    // 1.先保存图片到【相机胶卷】
    /// 同步执行修改操作
    NSError *error = nil;
    __block PHObjectPlaceholder *placeholder = nil;
    
    NSData *imgData = self.shareData.shareImageData;
    UIImage *image = [UIImage imageWithData:imgData];
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        placeholder =  [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
    } error:&error];
    if (error) {
        DLog(@"保存失败");
        return;
    }
    // 2.拥有一个【自定义相册】
    PHAssetCollection *assetCollection = [self createCollection];
    if (assetCollection == nil) {
        DLog(@"创建相册失败");
    }
    // 3.将刚才保存到【相机胶卷】里面的图片引用到【自定义相册】
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        PHAssetCollectionChangeRequest *requtes = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [requtes addAssets:@[placeholder]];
    } error:&error];
    if (error) {
        DLog(@"保存图片失败");
    } else {
        DLog(@"保存图片成功");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"已保存到系统相册"
                                                       delegate:nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil,nil];
        [alert show];
    }
}
@end

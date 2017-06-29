//
//  HTTPServiceRequest.m
//  XiaDongJian
//
//  Created by XXXX on 16/4/1.
//  Copyright (c) 2016年 XiaDongJian. All rights reserved.
//

#import "HTTPServiceRequest.h"
#import "AFHTTPSessionManager.h"

#import "MBProgressHUD.h"


@interface HTTPServiceRequest ()

@property (nonatomic,strong)UIWebView *webview;


@end


//解决AFN内存泄漏
static AFHTTPSessionManager *manager ;
static AFURLSessionManager *urlsession ;

@implementation HTTPServiceRequest

#pragma mark------获取网络请求类
+(HTTPServiceRequest *)shareHTTPService{
    static HTTPServiceRequest *manager=nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (manager==nil) {
            manager=[[HTTPServiceRequest alloc]init];
        }
        
    });
    return manager;
}

#pragma mark------解决AFN的内存泄漏问题
+ (AFHTTPSessionManager *)sharedHTTPSessionManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 10;
    });
    return manager;
}

+ (AFURLSessionManager *)sharedURLSessionManager{
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        urlsession = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return urlsession;
}

#pragma mark------AFN  GET请求
/**
 *  AFN  GET请求
 *
 *  @param urlString    URL链接
 *  @param dic          传入的参数
 *  @param sucBlock     成功后的数据
 *  @param failureBlock 失败后的数据,失败后动画隐藏自己写，不做封装
 */
-(void)GetrequestWithUrl:(NSString *)urlString withDictionary:(NSDictionary *)dic withSuccessBlock:(SuccessBlock)sucBlock withFailureBlock:(FailureBlock)failureBlock WithHttpAnimationType:(HttpHUDType)type AndAnimationTIme:(NSInteger)time AddToView:(UIView *)view AndText:(NSString *)text
{

    AFHTTPSessionManager * manager= [HTTPServiceRequest sharedHTTPSessionManager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    __block  int Once = 1;
    [manager GET:urlString parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //这里如果dic有多个参数就会调用多次
        dispatch_async(dispatch_get_main_queue(), ^{
            if (view && Once) {
                switch (type) {
                    case KAnimationImage:
                        [HTTPServiceRequest ShowWithText:text WithAddToView:view];
                        break;
                    case KTextOnly:
                        [HTTPServiceRequest ShowTextOnlyWithWindowCenter:text AndShowTime:time ? time : 999];//如果时间为0表示一直显示直到成功
                        break;
                    case KHUDWithText:
                    {
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
                        hud.labelText = text;
                        [hud hide:YES afterDelay:time ? time : 999];
                    }
                        break;
                    default:
                        break;
                }
                Once = 0;
            }
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        sucBlock(dict);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        failureBlock(error);
//        [HTTPServiceRequest HideHUDAnimationForView:view];
        
    }];
}


#pragma mark------AFN  POST请求
/**
 *  AFN post请求
 *
 *  @param urlString    请求URL
 *  @param dic          请求所需参数
 *  @param sucBlock     成功的回调
 *  @param failureBlock 失败的回调
 *  @param type         请求过程中的加载动画
 *  @param time         为0表示一直显示
 *  @param view         加载动画要添加的目标View，可为Window
 *  @param text         加载动画是否有文字，可为nil
 */
- (void)PostrequestWithUrl:(NSString *)urlString withDictionary:(id)dic withSuccessBlock:(SuccessBlock)sucBlock withFailureBlock:(FailureBlock)failureBlock WithHttpAnimationType:(HttpHUDType)type AndAnimationTIme:(NSInteger)time AddToView:(UIView *)view AndText:(NSString *)text
{
    AFHTTPSessionManager * manager = [HTTPServiceRequest sharedHTTPSessionManager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    
    __block  int Once = 1;
    [manager POST:urlString parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        //这里如果dic有多个参数就会调用多次
        dispatch_async(dispatch_get_main_queue(), ^{
            if (view && Once) {
                switch (type) {
                    case KAnimationImage:
                        [HTTPServiceRequest ShowWithText:text WithAddToView:view];
                        break;
                    case KTextOnly:
                        [HTTPServiceRequest ShowTextOnlyWithWindowCenter:text AndShowTime:time ? time : 999];//如果时间为0表示一直显示直到成功
                        break;
                    case KHUDWithText:
                    {
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
                        hud.labelText = text;
                        [hud hide:YES afterDelay:time ? time : 999];
                    }
                        break;
                    case KOnlyAnnular:
                    {
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
                        [hud hide:YES afterDelay:time ? time : 999];
                    }
                    default:
                        break;
                }
                Once = 0;
            }
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        AFJSONResponseSerializer *URLNull = [[AFJSONResponseSerializer alloc] init];
        URLNull.removesKeysWithNullValues = YES;//去掉空值
        URLNull.readingOptions = NSJSONReadingMutableContainers;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        sucBlock(dict);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
        failureBlock(error);
//        [HTTPServiceRequest HideHUDAnimationForView:view];//隐藏动画
    }];
}

#pragma mark------上传图片的函数
/**
 *  上传图片的函数
 *
 *  @param image        上传的图片资源
 *  @param sucBlock     上传成功后的回调
 *  @param failureBlock 失败后的回调
 */
- (void)UploadSomthingWithImage:(UIImage *)image withSuccessBlock:(SuccessBlock)sucBlock withFailureBlock:(FailureBlock)failureBlock
{
    
    AFHTTPSessionManager *manager = [HTTPServiceRequest sharedHTTPSessionManager];
    manager.requestSerializer.timeoutInterval = 10;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:@"" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if(UIImagePNGRepresentation(image))
        {
            [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"file" fileName:@"123.png" mimeType:@"image/png"];
        }else
        {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:@"fire" fileName:@"123.png" mimeType:@"image/jpeg"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        sucBlock(dict);

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failureBlock(error);
    }];
}


#pragma mark-----JSON数据解析精度丢失问题解决
//数据精度丢失
+ (NSString *)decimalNumberWithDouble:(double)conversionValue
{
    NSString *doubleString = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}


#pragma mark-----自定义HUD窗口，有一个对勾一个感叹号，下面文字详情
/**
 *  自定义HUD窗口，有一个对勾一个感叹号，下面文字详情
 *
 *  @param text   文字详情
 *  @param time   显示时间
 *  @param Ktype  窗口类型
 */
+ (void)ShowhHUDWithText:(NSString *)text AndShowTime:(NSInteger)time AndStateType:(State)Ktype
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *image1 = [[UIImage imageNamed:Ktype == KWrong ? @"gantan": @"Done" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,35, 35)];
    imageV.image = image1;
    hud.customView = imageV;
    hud.square = YES;
    hud.labelText = text;
    hud.labelFont = [UIFont systemFontOfSize:12];
    hud.margin = 10;
    [hud hide:YES afterDelay:time];
}

#pragma mark-----显示自定义动画，图片可以在MBProgressHUD.m文件中更改
/**
 *  显示自定义动画，图片可以在MBProgressHUD.m文件中更改
 *
 *  @param text 文字内容
 *  @param view 显示到的目标View
 */
+ (void)ShowWithText:(NSString *)text WithAddToView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.color = [UIColor clearColor];
    hud.mode = MBProgressHUDMyCustomAnimation;//自定义动画类型
    hud.labelText = text;
    hud.labelColor = [UIColor blackColor];
    hud.labelFont = [UIFont systemFontOfSize:12];
    hud.minShowTime = 0.5;
//    hud.yOffset = 64;//向Y轴的偏移量
//    hud.minSize = CGSizeMake(ScreenW, ScreenH-200);//最小大小
    hud.square = NO;//是否宽高相等
//    hud.cornerRadius = 0;//圆角半径
//    hud.userInteractionEnabled = NO;//允许点击
    [hud hide:YES afterDelay:100];
}

#pragma mark----- 显示一个HUD文本框在屏幕中间
/**
 *  显示一个HUD文本框在屏幕中间，宽度最宽屏幕一半，自动换行
 *
 *  @param text 要显示的文字
 *  @param time 要显示的时间
 */
+ (void)ShowTextOnlyWithWindowCenter:(NSString *)text AndShowTime:(NSInteger)time
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    CGSize TextSizeWidth = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15]} context:nil].size;
    
    CGSize TextSizeHeight;
    CGFloat Screen_Width = [UIScreen mainScreen].bounds.size.width;
    if(TextSizeWidth.width > [UIScreen mainScreen].bounds.size.width/2)
    {
        TextSizeWidth.width = Screen_Width/2 - 20;
        TextSizeHeight = [text boundingRectWithSize:CGSizeMake(Screen_Width/2 - 20,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15]} context:nil].size;
    }else
    {
        TextSizeHeight.height = 20;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, TextSizeWidth.width, TextSizeHeight.height)];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    hud.customView = label;
    hud.alpha = 0.8;
    hud.color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
//    hud.minShowTime = 0.2;
    hud.margin = 10;
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;//显示期间允许用户点击,提示框显示时间尽量短，
    [hud hide:YES afterDelay:time];
}

#pragma mark----- 显示网络错误的小人图片
/**
 *  显示网络错误的小人图片
 */
+ (void)ShowHttpErrorImageWithWindow
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.color = [UIColor clearColor];
    UIImageView *imagev = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 38, 60)];
    imagev.image = [UIImage imageNamed:@"001"];
    hud.customView = imagev;
    hud.labelText = @"网络开小差啦";
    hud.labelFont = [UIFont systemFontOfSize:12];
    hud.labelColor =[UIColor blackColor];
    [hud hide:YES afterDelay:2];
}

#pragma mark----- 隐藏目标view上的所有HUD窗口
/**
 *  隐藏目标view上的所有HUD窗口
 *
 *  @param view 目标view
 */
+ (void)HideHUDAnimationForView:(UIView *)view
{
    view ? [MBProgressHUD hideAllHUDsForView:view animated:YES] : [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
}

/**
 *  自定义Present控制器动画
 *
 *  @param left 方向
 */
+ (void)PresentAnimationWithDirction:(Direction)left
{
    //创建核心动画
    CATransition *PresentAnimation=[CATransition animation];
    //告诉要执行什么动画
    //设置过度效果
    PresentAnimation.type=@"push";
    
    switch (left) {
        case Kleft:
            //设置动画的过度方向（向左）
            PresentAnimation.subtype=kCATransitionFromLeft;
            break;
        case KRight:
            //设置动画的过度方向（向右）
            PresentAnimation.subtype=kCATransitionFromRight;
            break;
        case KTop:
            //设置动画的过度方向（向上）
            PresentAnimation.subtype=kCATransitionFromTop;
            break;
        case KBttom:
            //设置动画的过度方向（向下）
            PresentAnimation.subtype=kCATransitionFromBottom;
            break;
    }
    //设置动画的时间
    PresentAnimation.duration=0.3;
    //添加动画
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:PresentAnimation forKey:nil];
}

@end

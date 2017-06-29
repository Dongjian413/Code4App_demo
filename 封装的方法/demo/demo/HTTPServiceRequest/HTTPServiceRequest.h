

//AFN的正确的解析姿势,要修改AFN这个文件#import "AFURLResponseSerialization.h"
//self.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain",@"text/html", @"text/json", @"text/javascript", nil];


//  Created by XXXX on 16/4/1.
//  Copyright (c) 2016年 XiaDongJian. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^SuccessBlock)(NSDictionary * dict);
typedef void(^FailureBlock)(NSError *error);

typedef void(^AlertBlock)();

typedef enum
{
    KWrong = 1,
    KDone
} State;//HUD提示框的状态

//present动画方向
typedef enum
{
    Kleft,
    KRight,
    KTop,
    KBttom
} Direction;


typedef enum
{
    KAnimationImage = 1, //自定义HUD加载动画，带加载文字
    KTextOnly,//HUD文字显示在屏幕中间，宽度不会超过屏幕一半，自动换行
    KHUDWithText,//一个菊花加载图标和一个标题
    KOnlyAnnular//只有一个菊花加载图标
    //...未完待续
} HttpHUDType;//网络加载时显示的HUD提示框的类型.为0没有任何动画

@interface HTTPServiceRequest : NSObject


+(HTTPServiceRequest *)shareHTTPService;

#pragma mark------AFN  GET请求
/**
 *  AFN  GET请求
 *
 *  @param urlString    URL链接
 *  @param dic          传入的参数
 *  @param sucBlock     成功后的数据
 *  @param failureBlock 失败后的数据,失败后动画隐藏自己写，不做封装
 */
-(void)GetrequestWithUrl:(NSString *)urlString withDictionary:(NSDictionary *)dic withSuccessBlock:(SuccessBlock)sucBlock withFailureBlock:(FailureBlock)failureBlock WithHttpAnimationType:(HttpHUDType)type AndAnimationTIme:(NSInteger)time AddToView:(UIView *)view AndText:(NSString *)text;

#pragma mark------AFN  POST请求
/**
 *  AFN  POST请求
 *
 *  @param urlString    post链接
 *  @param dic          传入的参数
 *  @param sucBlock     成功后的数据
 *  @param failureBlock 失败后的数据
 */
-(void)PostrequestWithUrl:(NSString *)urlString withDictionary:(id)dic withSuccessBlock:(SuccessBlock)sucBlock withFailureBlock:(FailureBlock)failureBlock WithHttpAnimationType:(HttpHUDType)type AndAnimationTIme:(NSInteger)time AddToView:(UIView *)view AndText:(NSString *)text;


#pragma mark------上传图片的函数
/**
 *  上传图片的函数
 *
 *  @param image        上传的图片资源
 *  @param sucBlock     上传成功后的回调
 *  @param failureBlock 失败后的回调
 */
- (void)UploadSomthingWithImage:(UIImage *)image withSuccessBlock:(SuccessBlock)sucBlock withFailureBlock:(FailureBlock)failureBlock;

/*!
 @brief 数据精度丢失
 */
+ (NSString *)decimalNumberWithDouble:(double)conversionValue;

/**
 *  显示警告窗口
 *
 *  @param text 警告提示文字
 *  @param time 窗口显示时间
 */
+ (void)ShowhHUDWithText:(NSString *)text AndShowTime:(NSInteger)time AndStateType:(State)Ktype;


#pragma mark-----显示自定义动画，图片可以在MBProgressHUD.m文件中更改
/**
 *  显示自定义动画，图片可以在MBProgressHUD.m文件中更改
 *
 *  @param text 文字内容
 *  @param view 显示到的目标View
 */
+ (void)ShowWithText:(NSString *)text WithAddToView:(UIView *)view;


#pragma mark----- 隐藏目标view上的所有HUD窗口
/**
 *  隐藏目标view上的所有HUD窗口
 *
 *  @param view 目标view  如果为空就影藏window上的HUD窗口
 */
+ (void)HideHUDAnimationForView:(UIView *)view;




#pragma mark----- 显示一个HUD文本框在屏幕中间
/**
 *  显示一个HUD文本框在屏幕中间，宽度最宽屏幕一半，自动换行
 *
 *  @param text 要显示的文字
 *  @param time 要显示的时间
 */
+ (void)ShowTextOnlyWithWindowCenter:(NSString *)text AndShowTime:(NSInteger)time;




#pragma mark-----自定义Present控制器动画，带有四个方向可选
/**
 *  自定义Present控制器动画
 *
 *  @param left 方向
 */
+ (void)PresentAnimationWithDirction:(Direction)left;



@end

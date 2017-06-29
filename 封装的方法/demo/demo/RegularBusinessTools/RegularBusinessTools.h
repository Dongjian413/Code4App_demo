//
//  RegularBusinessTools.h
//  XC2
//
//  Created by Mac on 17/1/7.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegularBusinessTools : NSObject

/**
 相隔多少天没有打开应用就通过本地通知提示用户重新打开应用
 
 @param day 相隔的天数
 @param message 提示的内容
 @param alertTitle 提示的标题【iOS8.2以上】
 */
+ (void)RemindUserWithNotficationAfterAFewDays:(NSInteger)day
                              AndRemindMessage:(NSString *)message
                                AndRemindTitle:(NSString *)alertTitle;


/**
 根据APPID异步检查至苹果商店更新,
 如果本地版本号比商店应用版本号小就弹出更新窗口，只有更新按钮
 @param AppID APPID
 */
+ (void)CheckTheUpdateWithAppID:(NSString *)AppID;

/**
 用户使用两周后再打开应用提示去评价，根据APPID跳转应用市场

 @param AppID AppID
 */
+ (void)GotoEvaluateWithAppID:(NSString *)AppID;

/*!
 @brief 判断是否是第一次启动
 */
+ (BOOL)isFirstBuldVesion;

@end

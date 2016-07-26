//
//  ZYCollectionViewLayout.h
//  瀑布流测试
//
//  Created by ZhouYong on 16/7/25.
//  Copyright © 2016年 ZhouYong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZYCollectionViewLayout;

@protocol ZYCollectionViewLayoutDelegate <NSObject>

@required
//定义强制实现高度的方法
- (CGFloat)collectionViewLayout:(ZYCollectionViewLayout *)collectionViewLayout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth;

//可选的方法
@optional
//瀑布流列数
- (NSInteger)numberOfColumnInWaterflowLayout:(ZYCollectionViewLayout *)waterflowLayout;
//瀑布流的列间距
- (CGFloat)marginOfColumnInWaterflowLayout:(ZYCollectionViewLayout *)waterflowLayout;
//瀑布流的行间距
- (CGFloat)marginOfRowInWaterflowLayout:(ZYCollectionViewLayout *)waterflowLayout;
//瀑布流视图的内边距
- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(ZYCollectionViewLayout *)waterflowLayout;




@end

@interface ZYCollectionViewLayout : UICollectionViewLayout
//设置代理
@property (nonatomic, weak)id<ZYCollectionViewLayoutDelegate> delegate;

@end

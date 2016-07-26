//
//  ZYCollectionViewLayout.m
//  瀑布流测试
//
//  Created by ZhouYong on 16/7/25.
//  Copyright © 2016年 ZhouYong. All rights reserved.
//

#import "ZYCollectionViewLayout.h"

//每一列间距
static const CGFloat ZYColumnMargin = 10;

//每一行间距
static const CGFloat ZYRowMargin = 10;

//边缘间距
static const UIEdgeInsets ZYEdgeInsert = {10, 10, 10, 10};

static const CGFloat ZYDefaultColumnCount = 3;


@interface ZYCollectionViewLayout ()
//存放cell的布局属性
@property (nonatomic, strong)NSMutableArray *attrsArray;

//存放列高度的数组
@property (nonatomic, strong)NSMutableArray *columnHeights;

#pragma mark**********常见的数据************
- (CGFloat)rowMargin;
- (CGFloat)columnMargin;
- (NSUInteger)columnCount;
- (UIEdgeInsets)edgeInserts;

@end

@implementation ZYCollectionViewLayout

#pragma mark**********常见的数据处理************
- (CGFloat)rowMargin
{
    if ([self.delegate respondsToSelector:@selector(marginOfRowInWaterflowLayout:)])
    {
        return [self.delegate marginOfRowInWaterflowLayout:self];
    }
    else
    {
        return ZYRowMargin;
    }
}

- (CGFloat)columnMargin
{
    if ([self.delegate respondsToSelector:@selector(marginOfColumnInWaterflowLayout:)]) {
        return [self.delegate marginOfColumnInWaterflowLayout:self];
    }else
    {
        return ZYColumnMargin;
    }
}

- (NSUInteger)columnCount
{
//    按照设定的列数目返回瀑布流列数目
    if ([self.delegate respondsToSelector:@selector(numberOfColumnInWaterflowLayout:)]) {
        return [self.delegate numberOfColumnInWaterflowLayout:self];
    }else
    {
//        返回默认的列数目
        return ZYDefaultColumnCount;
    }
}

- (UIEdgeInsets)edgeInserts
{
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInWaterflowLayout:)]) {
        return  [self.delegate edgeInsetsInWaterflowLayout:self];
    }else
    {
        return ZYEdgeInsert;
    }
}



//cell的布局属性
- (NSMutableArray *)attrsArray{
    if (_attrsArray == nil) {
        _attrsArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _attrsArray;
}


//存放每一列的高度
- (NSMutableArray *)columnHeights{
    if (_columnHeights == nil) {
        _columnHeights = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _columnHeights;
}


//初始化,这个方法程序启动只会执行一次
- (void)prepareLayout
{
    [super prepareLayout];
    NSLog(@"%s",__func__);


//    先清除以前计算的所有高度
    [self.columnHeights removeAllObjects];
    for (NSInteger i = 0;  i < self.columnCount; i ++) {
        [self.columnHeights addObject:@(self.edgeInserts.top)];
    }
//    如果以后用到刷新，这样我们清空内部所有的属性，避免数组越加越大
    [self.attrsArray removeAllObjects];

    //    开始创建每一个cell对应的布局属性 一般而言，瀑布流只有一组cell
    NSInteger count = [self.collectionView numberOfItemsInSection:0];

    for (NSInteger i = 0; i < count; i ++) {
        //        拿到当前cell的位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
//        拿到indexpath位置对应的cell的布局属性
        UICollectionViewLayoutAttributes * attrs = [self layoutAttributesForItemAtIndexPath:indexPath];

        [self.attrsArray addObject:attrs];
    }
}



//决定cell的排布
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSLog(@"%s",__func__);

    return self.attrsArray;
}


//返回indexpath位置cell对应的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //        创建这个位置cell对应的布局属性
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

//    找出高度最短的那一列
    NSInteger desShortestColumn = 0;

//    默认第一列高度最短
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];

//    然后遍历每一列，得出最短的那一列
    for (NSInteger i = 1; i < self.columnCount; i++) {
//        获取第i列的高度
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];

        if (columnHeight < minColumnHeight)
        {
//            交换最小列高度
            minColumnHeight = columnHeight;

//            获取最小列下标
            desShortestColumn = i;
        }
    }

//    设置cell的宽度  （屏幕宽度 - 左边距 - 右边距 - 所有的列间距之和)/列数目
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - self.edgeInserts.left - self.edgeInserts.right - (self.columnCount - 1)*self.columnMargin)/self.columnCount;

//    强制实现这个方法返回高度
    CGFloat height = [self.delegate collectionViewLayout:self heightForItemAtIndex:indexPath.item itemWidth:width];

//    获取每一个cell的x位置  为什么要找出高度最短的那一列的x坐标呢？因为每次都是从高度最短的那一列开始布局的
    CGFloat x = self.edgeInserts.left + (width + self.columnMargin)*desShortestColumn;

    CGFloat y = minColumnHeight;
    if (y != self.edgeInserts.top)
    {
        y = y + self.rowMargin;
    }

    //        设置布局属性的frame
    attrs.frame = CGRectMake(x, y, width, height);

//    更新最短的那一列的高度
    self.columnHeights[desShortestColumn] = @(CGRectGetMaxY(attrs.frame));

    return attrs;
}

- (CGSize)collectionViewContentSize
{
//    取出最高列的高度
//    假设第一列最高
    CGFloat maxColumnHeight = [self.columnHeights[0] doubleValue];
    for (NSInteger i = 1; i < self.columnCount; i++) {
        if (maxColumnHeight < [self.columnHeights[i] doubleValue])
        {
            maxColumnHeight = [self.columnHeights[i] doubleValue];
        }
    }
    NSLog(@"%s",__func__);
    return CGSizeMake(0, maxColumnHeight + self.edgeInserts.bottom);
}


@end
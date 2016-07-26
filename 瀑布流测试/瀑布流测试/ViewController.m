//
//  ViewController.m
//  瀑布流测试
//
//  Created by ZhouYong on 16/7/25.
//  Copyright © 2016年 ZhouYong. All rights reserved.
//

#import "ViewController.h"
#import "ZYCollectionViewLayout.h"
#import "XMGShopCell.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "XMGShop.h"


@interface ViewController ()<UICollectionViewDataSource, ZYCollectionViewLayoutDelegate>

//存放衣服的数组
@property (nonatomic, strong)NSMutableArray *clothes;

@property (nonatomic, weak)UICollectionView *collectionView;

@end

@implementation ViewController

- (NSMutableArray *)clothes{
    if (_clothes == nil) {
        _clothes = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _clothes;
}


//重用标志
static  NSString * const reuseIdentifier = @"shop";

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupLayout];

    [self setupRefresh];
}

- (void)setupLayout
{
    ZYCollectionViewLayout *layout = [[ZYCollectionViewLayout alloc] init];
//自己定义的一个代理
    layout.delegate = self;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    //    设置数据源的代理对象
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];

    //    registerClass通过类名来注册
//    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
//    从nib文件中加载我们的cell
    [collectionView registerNib:[UINib nibWithNibName:@"XMGShopCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
}


- (void)loadNewData
{
    //    每次刷新先清空之前的数据
    [self.clothes removeAllObjects];

    NSArray *clothes = [XMGShop objectArrayWithFilename:@"1.plist"];

    [self.clothes addObjectsFromArray:clothes];

    [self.collectionView reloadData];

    [self.collectionView.header endRefreshing];
}

- (void)loadMoreData
{
    NSArray *clothes = [XMGShop objectArrayWithFilename:@"1.plist"];

    [self.clothes addObjectsFromArray:clothes];

    [self.collectionView reloadData];
// 刷新数据结束后要停止刷新
    [self.collectionView.footer endRefreshing];
}

- (void)setupRefresh
{
    self.collectionView.footer.hidden = YES;
    self.collectionView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self.collectionView.header beginRefreshing];
    self.collectionView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}



#pragma mark**********UICollectionViewDataSource************
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    在每次刷新表格的时候根据返回的clothes的数量决定下拉菜单是否显示
    self.collectionView.footer.hidden = self.clothes.count == 0;
//    返回衣服的数量
    return self.clothes.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XMGShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/256.0 green:arc4random()%255/256.0 blue:arc4random()%255/256.0 alpha:arc4random()%255/256.0];
    cell.shop = self.clothes[indexPath.item];

//    idea：在每一个cell上添加一个label，但是label也要动态地创建。
//    NSInteger tag = 10;
//    UILabel *label = (UILabel *)[cell.contentView viewWithTag:tag];
//    if (label == nil) {
//        label = [[UILabel alloc] init];
//        label.tag = tag;
//        [cell.contentView addSubview:label];
//    }
//    label.text = [NSString stringWithFormat:@"%ld",indexPath.item];
//
//    [label sizeToFit];

    return cell;
}


#pragma mark**********ZYCollectionViewLayoutDelegate************
- (CGFloat)collectionViewLayout:(ZYCollectionViewLayout *)collectionViewLayout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth
{
    XMGShop *shop = self.clothes[index];
    return itemWidth * shop.h / shop.w;
}

- (CGFloat)marginOfColumnInWaterflowLayout:(ZYCollectionViewLayout *)waterflowLayout
{
    return 20;
}

- (CGFloat)marginOfRowInWaterflowLayout:(ZYCollectionViewLayout *)waterflowLayout
{
    return 20;
}

- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(ZYCollectionViewLayout *)waterflowLayout
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (NSInteger)numberOfColumnInWaterflowLayout:(ZYCollectionViewLayout *)waterflowLayout
{
    return 4;
}



@end

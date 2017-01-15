//
//  ViewController.m
//  DZ19 UIView
//
//  Created by Vasilii on 14.01.17.
//  Copyright © 2017 Vasilii Burenkov. All rights reserved.
//

#import "ViewController.h"

//энум, перечисление для клеток и фигур
typedef enum {
    TagBlackCell,
    TagWhiteCell,
    TagWhiteChecker,
    TagRedChecker,
    
}TagCell;

@interface ViewController ()

@property (strong, nonatomic) UIView *chessBoard;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //устанавливается цвет фон нашего вью
    self.view.backgroundColor = [UIColor grayColor];
    
    // инициализируем шахматную доску
    self.chessBoard = [[UIView alloc] initWithFrame:CGRectInset(self.view.bounds, 0, 0)];
    
    //минимальная сторона шахматной доски равна самой минимальной доске во внутренних границах по ширине и высоте
    CGFloat minSideChessBoard = MIN(CGRectGetWidth(self.chessBoard.bounds), CGRectGetHeight(self.chessBoard.bounds));
    
    //шахматная доска в форме квадрата с минимальной стороной
    self.chessBoard.bounds = CGRectMake(self.chessBoard.bounds.origin.x, self.chessBoard.bounds.origin.y, minSideChessBoard, minSideChessBoard);
    
    self.chessBoard.backgroundColor = [UIColor whiteColor];
    
    //создаются клетки и фигуры
    [self createCellsAndCheckers: self.chessBoard];
    
    [self.view addSubview: self.chessBoard];
}

-(void) createCellsAndCheckers: (UIView*) chessBoard {
    for (int y = 0; y < 8; y += 1) {
        for (int x = 0; x < 8 ; x += 1) {
            CGRect cellFrame;
            //размер 1/8
            cellFrame.size = CGSizeMake(CGRectGetWidth(chessBoard.bounds) / 8, CGRectGetMaxX(chessBoard.bounds) / 8);
            //начало координат
            cellFrame.origin = CGPointMake(x * CGRectGetWidth(cellFrame), y * CGRectGetHeight(cellFrame));
            //инициализируем ячейку
            UIView * cell = [[UIView alloc] initWithFrame:cellFrame];
            
            //определяем цвет ячейки
            cell.backgroundColor = (x + y) % 2 == 0 ? [UIColor whiteColor] : [UIColor blackColor];
            cell.tag = (x + y) % 2 == 0 ? TagWhiteCell : TagBlackCell;
            
            //создаем ячейки на шахматной доске
            [self.chessBoard addSubview:cell];
            
            //расставляем шашки по клеткам доски
            if ((y <= 2 || y >= 5) && (x+y) % 2 != 0) {
                //создаем фигуру шашки
                CGRect checkFrame = CGRectInset(cellFrame, 10, 10);
                //инициализируем, задаем цевет
                UIView *checker = [[UIView alloc] initWithFrame:checkFrame];
                checker.backgroundColor = y <= 3 ? [UIColor whiteColor] : [UIColor redColor];
                
                // скругляем вью шашки
                checker.layer.cornerRadius = checker.frame.size.width /2;
                [chessBoard addSubview:checker];
            }
        }
    }
}
// метод который поддерживает маски всех ориентациий
-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(UIColor*) randomColor {
    return [UIColor colorWithRed:0.1 + (arc4random_uniform(100) * 0.01) green:0.1 + (arc4random_uniform(100) * 0.01) blue: 0.1 + (arc4random_uniform(100) * 0.01) alpha:0.8];
}
//метод перетасовыающий шашки и меняющий цвет черных клеток
-(void) shuffleCheckersAndColorBlackCells: (UIView*) chessBoard {
   
    UIColor *color = [self randomColor];
    //анимаиция с задержекой 3 секунды
    [UIView animateWithDuration:3 animations:^{
        for (UIView * cell in self.chessBoard.subviews) {
            if (cell.tag == TagBlackCell) { // если имя (метка) ячейки
                cell.backgroundColor = color;
            }
            
            CGPoint whiteChecherOrigin;
            CGPoint redCheckerOrigin;
            
            // рендомный индекс для шашек
            NSInteger indexWhiteChecker = arc4random_uniform((UInt32)chessBoard.subviews.count - 1);
            NSInteger indexRedChecker = arc4random_uniform((UInt32)chessBoard.subviews.count - 1);
            
            //через цикл while ищем в self.chessBoard.subviews красную шашку
            while (![[chessBoard.subviews objectAtIndex: indexWhiteChecker] viewWithTag:TagWhiteChecker]) {
                indexWhiteChecker = arc4random_uniform((UInt32)self.chessBoard.subviews.count - 1 );
            }
            while (![[chessBoard.subviews objectAtIndex: indexRedChecker] viewWithTag:TagRedChecker]) {
                indexRedChecker = arc4random_uniform((UInt32)self.chessBoard.subviews.count - 1 );
            }
            
            //создаем белые и красные шашки
            whiteChecherOrigin = [chessBoard.subviews objectAtIndex:indexWhiteChecker].frame.origin;
            redCheckerOrigin = [chessBoard.subviews objectAtIndex:indexRedChecker].frame.origin;
            
            
            [chessBoard.subviews objectAtIndex:indexWhiteChecker].frame = CGRectMake(redCheckerOrigin.x,
                                                                                     redCheckerOrigin.y,
                                                                                     CGRectGetWidth([chessBoard.subviews objectAtIndex:indexWhiteChecker].frame),
                                                                                     CGRectGetHeight([chessBoard.subviews objectAtIndex:indexWhiteChecker].frame));
            
            [chessBoard.subviews objectAtIndex:indexRedChecker].frame = CGRectMake(whiteChecherOrigin.x,
                                                                                     whiteChecherOrigin.y,
                                                                                     CGRectGetWidth([chessBoard.subviews objectAtIndex:indexRedChecker].frame),
                                                                                     CGRectGetHeight([chessBoard.subviews objectAtIndex:indexRedChecker].frame));
            
            [chessBoard exchangeSubviewAtIndex:indexWhiteChecker withSubviewAtIndex:indexRedChecker];
        }
    }];
}



//стандартный метод  apple
-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        // определяем центр как сeрединиу самой вью
        self.chessBoard.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(self.view.frame) / 2);
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //вызываем созданный выше метод перетасовывающий шашки
        [self shuffleCheckersAndColorBlackCells:self.chessBoard];
    }];
    
             [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
    

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

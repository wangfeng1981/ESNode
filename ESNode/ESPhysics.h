//
//  ESPhysics.h
//  ESNode
//
//  Created by Wang Feng on 13-4-14.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import <Foundation/Foundation.h>


union espVector2f
{
    struct { float x, y ; };
    float v[2];
};
typedef union espVector2f espVector2f;
espVector2f espVec2Make(float v0,float v1) ;
float       espVec2DotProduct(espVector2f v1,espVector2f v2) ;
espVector2f espVec2listProjection(espVector2f* vlist,int nv,espVector2f axis) ;
bool espVec2Overlapped(espVector2f m,espVector2f t,float* penetrateDist) ;
bool espPolyOverlappedOnAxis(espVector2f* mvlist,int mnv,espVector2f* tvlist,int tnv,espVector2f axis,float* penetrateDist) ;

struct espTileShape
{
    short nvert,naxis ;
    espVector2f vert4[4] ;
    espVector2f axis[3] ;
    int nextTileIndex ;
};
typedef struct espTileShape espTileShape ;
espTileShape espTileShapeMakeRect(float x0,float y0,float wid,float hei) ;/*(x0,y0) is bottom left point*/
espTileShape espTileShapeMakeTria(float x0,float y0,float wid,float hei) ;/*(x0,y0) is right angle point*/
bool espPolyCollide(espTileShape* m, espTileShape* t, espVector2f* pback ) ;

struct espMovingObject
{
    short type ; //0-invalid 1-player 2-npc 3-enemy
    float x,y,halfwid,halfhei ;
    float xspeed,yspeed ;
};
typedef struct espMovingObject espMovingObject;
espMovingObject espMovingObjectMake(short type,int xcenter,int ycenter,int hwid,int hhei) ;
void espMovingObjectUpdate(espMovingObject* m,float timeinter) ;
espTileShape espMovingObjectShape(espMovingObject* m) ;

//espGrid
/* neighbours[8]    5 6 7
                    3 x 4
                    0 1 2
 */
struct espGrid
{
    int firstTileIndex ;//-1 for invalid.
    int neighbours[8] ;
};
typedef struct espGrid espGrid;
espGrid espGridMake(int irow,int icol,int nrow,int ncol) ;
void espGridAttachTile(espGrid* grids,int igrid,espTileShape* tiles, int itile, int nvalidtiles ) ;


#define ESPWORLD2D_MAXNUMBER_MOVOBJ 5
@interface espWorld2D :NSObject
{
    espTileShape* tileShapeArray ;/* tileShapeArray use left bottom as origin (0,0) and row first.*/
    int numberOfValidTiles ;
    espMovingObject movObjectArray[ESPWORLD2D_MAXNUMBER_MOVOBJ] ;
    int numberOfMovObjects ;
    //grids
    espGrid* gridsArray ;
    int      gridRowNum,gridColNum ;
    int      gridWidth,gridHeight ;
}
@property(readonly,nonatomic)int numberOfValidTiles ;
@property(readonly,nonatomic)int numberOfMovObjects ;

-(id)initWithShortDataArray:(short*)data colNum:(int)ncol rowNum:(int)nrow tileWid:(float)tw tileHei:(float)th shapelist:(espTileShape*)shplist numInShapelist:(int)nshps ;

-(void)update:(GLfloat)timeinter ;
-(espMovingObject*)getMovObj:(int)index ;
-(int)addMovObject:(short)type x:(int)cx y:(int)cy halfwidth:(int)hw halfheight:(int)hh ;
//grids
-(void)buildGridsWorldSize:(CGSize)worldsz gridSize:(CGSize)gridsz ;

@end

//
//  ESPhysics.m
//  ESNode
//
//  Created by Wang Feng on 13-4-14.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import "ESPhysics.h"

#define f2i(f) (int)(f+0.5)

espVector2f espVec2Make(float v0,float v1)
{
    espVector2f vec ;
    vec.v[0] = v0 ; vec.v[1] = v1 ;
    return vec ;
}
float espVec2DotProduct(espVector2f v1,espVector2f v2)
{
    return v1.x*v2.x + v1.y*v2.y ;
}
espVector2f espVec2listProjection(espVector2f* vlist,int nv,espVector2f axis)
{
    float prj = espVec2DotProduct(vlist[0], axis) ;
    espVector2f result = espVec2Make(prj, prj) ;
    for (int i = 1; i<nv; i++) {
        prj = espVec2DotProduct(vlist[i], axis) ;
        if( prj > result.v[1] )
            result.v[1] = prj ;
        else if( prj < result.v[0] )
            result.v[0] = prj ;
    }
    return result ;
}
bool espVec2Overlapped(espVector2f m,espVector2f t,float* penetrateDist)
{
    if( m.v[0] > t.v[0] && m.v[0] < t.v[1] )
    {
        *penetrateDist = m.v[0] - t.v[1] ;
        return true ;
    }else if( m.v[1] > t.v[0] && m.v[1] < t.v[1] )
    {
        *penetrateDist = m.v[1] - t.v[0] ;
        return true ;
    }
    return false ;
}
bool espPolyOverlappedOnAxis(espVector2f* mvlist,int mnv,espVector2f* tvlist,int tnv,espVector2f axis,float* penetrateDist) 
{
    espVector2f mprj = espVec2listProjection(mvlist, mnv, axis) ;
    espVector2f tprj = espVec2listProjection(tvlist, tnv, axis) ;
    return espVec2Overlapped(mprj, tprj, penetrateDist) ;
}
bool espPolyCollide(espTileShape* m, espTileShape* t, espVector2f* pback )
{// m is always rect.
    float mpd = 0.f ;
    float pd = 0.f ;
    if( espPolyOverlappedOnAxis(m->vert4, m->nvert, t->vert4, t->nvert, t->axis[0], &mpd) ==false )
        return false ;
    pback->x = t->axis[0].x ;
    pback->y = t->axis[0].y ;
    for (int i = 1; i<t->naxis ; i++) {
        if( espPolyOverlappedOnAxis(m->vert4, m->nvert, t->vert4, t->nvert, t->axis[i], &pd) ==false )
            return false ;
        else if( fabsf(pd) < fabsf(mpd) )
        {
            mpd = pd ;
            pback->x = t->axis[i].x ;
            pback->y = t->axis[i].y ;
        }
    }
    pback->x = pback->x*mpd ;
    pback->y = pback->y*mpd ;
    return true ;
}



espTileShape espTileShapeMakeRect(float x0,float y0,float wid,float hei)
{
    espTileShape shp ;
    shp.vert4[0].x = x0 ;
    shp.vert4[0].y = y0 ;
    shp.vert4[1].x = x0+wid ;
    shp.vert4[1].y = y0 ;
    shp.vert4[2].x = x0 ;
    shp.vert4[2].y = y0+hei ;
    shp.vert4[3].x = shp.vert4[1].x ;
    shp.vert4[3].y = shp.vert4[2].y ;
    shp.nvert = 4 ;
    shp.axis[0].x = 1.f ;
    shp.axis[0].y = 0.f ;
    shp.axis[1].x = 0.f ;
    shp.axis[1].y = 1.f ;
    shp.naxis = 2 ;
    shp.nextTileIndex = -1 ;
    return shp ;
}
espTileShape espTileShapeMakeTria(float x0,float y0,float wid,float hei)
{
    espTileShape shp ;
    shp.vert4[0].x = x0 ;
    shp.vert4[0].y = y0 ;
    shp.vert4[1].x = x0+wid ;
    shp.vert4[1].y = y0 ;
    shp.vert4[2].x = x0 ;
    shp.vert4[2].y = y0+hei ;
    shp.nvert = 3 ;
    shp.axis[0].x = 1.f ;
    shp.axis[0].y = 0.f ;
    shp.axis[1].x = 0.f ;
    shp.axis[1].y = 1.f ;
    if( wid * hei > 0 )
    {
        shp.axis[2].x = 0.7071f ;
        shp.axis[2].y = 0.7071f ;
    }else
    {
        shp.axis[2].x = -0.7071f ;
        shp.axis[2].y = 0.7071f ;
    }
    shp.naxis = 3 ;
    shp.nextTileIndex = -1 ;
    return shp ;
}
espMovingObject espMovingObjectMake(short type,int xcenter,int ycenter,int hwid,int hhei)
{
    espMovingObject mobj ;
    mobj.xspeed = mobj.yspeed = 0.f ;
    mobj.x = xcenter ;
    mobj.y = ycenter ;
    mobj.type = type ;
    mobj.halfwid = hwid ;
    mobj.halfhei = hhei ;
    return mobj ;
}

void espMovingObjectUpdate(espMovingObject* m,float timeinter )
{
    m->x += m->xspeed * timeinter ;
    m->y += m->yspeed * timeinter ;
}
espTileShape espMovingObjectShape(espMovingObject* m)
{
    return espTileShapeMakeRect( m->x - m->halfwid , m->y - m->halfhei , 2*m->halfwid, 2*m->halfhei) ;
}

#pragma mark - espGrid
espGrid espGridMake(int irow,int icol,int nrow,int ncol)
{
    espGrid g ;
    g.firstTileIndex = -1 ;
    int r0 = irow - 1 ;
    int r1 = irow + 1 ;
    int c0 = icol - 1 ;
    int c1 = icol + 1 ;
    if( r0 >= 0 && c0 >= 0 )     g.neighbours[0] = r0*ncol + c0 ; else g.neighbours[0] = -1 ;
    if( r0 >= 0 )                g.neighbours[1] = r0*ncol+icol ; else g.neighbours[1] = -1 ;
    if( r0 >= 0 && c1 < ncol )   g.neighbours[2] = r0*ncol+c1 ; else g.neighbours[2] = -1 ;
    if( c0 >= 0 )                g.neighbours[3] = irow*ncol+c0 ; else g.neighbours[3] = -1 ;
    if( c1 < ncol )              g.neighbours[4] = irow*ncol+c1 ; else g.neighbours[4] = -1 ;
    if( r1 < nrow && c0 >= 0 )   g.neighbours[5] = r1*ncol+c0 ; else g.neighbours[5] = -1 ;
    if( r1 < nrow )              g.neighbours[6] = r1*ncol+icol ; else g.neighbours[6] = -1 ;
    if( r1 < nrow && c1 < ncol ) g.neighbours[7] = r1*ncol+c1 ; else g.neighbours[7] = -1 ;
    return g ;
}
void espGridAttachTile(espGrid* grids,int igrid,espTileShape* tiles, int itile, int nvalidtiles) 
{
    if( grids[igrid].firstTileIndex==-1 )
        grids[igrid].firstTileIndex = itile ;
    else
    {
        int ivalid = 0 ;
        int cursor = grids[igrid].firstTileIndex ;
        while ( tiles[cursor].nextTileIndex >=0) {
            cursor = tiles[cursor].nextTileIndex ;
            ivalid ++ ;
            if( ivalid==nvalidtiles ) return ;
        }
        tiles[cursor].nextTileIndex = itile ;
    }
}


#pragma mark - espWorld2D
@implementation espWorld2D
@synthesize numberOfValidTiles,numberOfMovObjects ;
-(void)dealloc
{
    if( tileShapeArray )
    {
        free(tileShapeArray) ;
        tileShapeArray = NULL ;
    }
    if( gridsArray )
    {
        free(gridsArray) ;
        gridsArray = NULL ;
    }
    [super dealloc] ;
}
-(id)initWithShortDataArray:(short*)data colNum:(int)ncol rowNum:(int)nrow tileWid:(float)tw tileHei:(float)th shapelist:(espTileShape*)shplist numInShapelist:(int)nshps 
{
    self = [super init] ;
    if( self )
    {
        gridColNum = gridRowNum = gridWidth = gridHeight = 0 ;
        gridsArray = NULL ;
        
        numberOfMovObjects = 0 ;
        numberOfValidTiles = 0 ;
        for (int irow =0 ; irow < nrow ; irow++) {
            for (int icol = 0; icol < ncol ; icol++ ) {
                short tileval = data[irow * ncol + icol ] ;
                if( tileval> 0 )
                {
                    numberOfValidTiles++ ;
                }
            }
        }
        
        tileShapeArray = malloc(sizeof(espTileShape)*numberOfValidTiles) ;
        int ivalid = 0 ;
        for (int irow =0 ; irow < nrow ; irow++) {
            for (int icol = 0; icol < ncol ; icol++ ) {
                short tileval = data[irow * ncol + icol ] ;
                if( tileval> 0 )
                {
                    int ishp = tileval - 1 ;
                    tileShapeArray[ivalid] = shplist[ishp] ;
                    int xofs = icol*tw ;
                    int yofs = (nrow-1-irow)*th ;
                    for (int ivert = 0; ivert < tileShapeArray[ivalid].nvert ; ivert++) {
                        tileShapeArray[ivalid].vert4[ivert].x += xofs ;
                        tileShapeArray[ivalid].vert4[ivert].y += yofs ;
                    }
                    //
                    ivalid++ ;
                }
            }
        }
        [self buildGridsWorldSize:CGSizeMake(ncol*tw, nrow*th) gridSize:CGSizeMake(tw, th)] ;
    }
    return self ;
}
-(void)update:(GLfloat)timeinter
{
    if( numberOfMovObjects == 0 ) return ;
    timeinter = 0.033f ;
    
    espVector2f vback ;
    for (int im=0 ; im < numberOfMovObjects ; im++ ) {
        espMovingObjectUpdate(&movObjectArray[im], timeinter) ;
        espTileShape m = espMovingObjectShape(&movObjectArray[im]) ;
        int gridcol = movObjectArray[im].x / gridWidth ;
        int gridrow = movObjectArray[im].y / gridHeight ;
        espGrid grid0 = gridsArray[gridrow*gridColNum+gridcol] ;
        for (int ineig = -1 ; ineig < 8 ; ineig ++ ) {
            espGrid grid ;
            if( ineig >= 0 )
            {
                if( grid0.neighbours[ineig] < 0 ) continue ;
                grid = gridsArray[grid0.neighbours[ineig]] ;
            }
            else grid = grid0 ;
            int itile = grid.firstTileIndex ;
            while (itile>=0) {
                
                if( espPolyCollide( &m , &tileShapeArray[itile], &vback) )
                {
                    movObjectArray[im].x -= vback.x ;
                    movObjectArray[im].y -= vback.y ;
                    if( fabsf(vback.y) > 0.0001f ) movObjectArray[im].yspeed = 0.f ;
                    if( fabsf(vback.x) > 0.0001f ) movObjectArray[im].xspeed = 0.f ;
                    m = espMovingObjectShape(&movObjectArray[im]) ;
                }
                itile = tileShapeArray[itile].nextTileIndex ;
            }
        }
        movObjectArray[im].yspeed -= 200.f*timeinter ;
        if( movObjectArray[im].yspeed < -100.f ) movObjectArray[im].yspeed = -100.f ;
        if( fabsf(movObjectArray[im].xspeed) > 1.f )
            movObjectArray[im].xspeed *= 0.9f ;
        else movObjectArray[im].xspeed = 0.f ;
    }

}

-(espMovingObject*)getMovObj:(int)index
{
    if( index < 0 || index >= numberOfMovObjects ) return NULL ;
    return &movObjectArray[index] ;
}

-(int)addMovObject:(short)type x:(int)cx y:(int)cy halfwidth:(int)hw halfheight:(int)hh
{
    if( numberOfMovObjects == ESPWORLD2D_MAXNUMBER_MOVOBJ ) return -1;
    movObjectArray[numberOfMovObjects] = espMovingObjectMake(type, cx, cy, hw, hh) ;
    numberOfMovObjects++ ;
    return numberOfMovObjects-1 ;
}

-(void)buildGridsWorldSize:(CGSize)worldsz gridSize:(CGSize)gridsz
{
    gridRowNum = (int)ceilf(worldsz.height / gridsz.height ) ;
    gridColNum = (int)ceilf(worldsz.width / gridsz.width ) ;
    gridWidth = (int)gridsz.width ;
    gridHeight = (int)gridsz.height ;
    if( gridsArray )
        free(gridsArray) ;
    gridsArray = (espGrid*)malloc(sizeof(espGrid)*gridRowNum*gridColNum) ;
    for (int irow = 0; irow < gridRowNum; irow++ ) {
        for (int icol = 0; icol < gridColNum ; icol++ ) {
            gridsArray[irow*gridColNum+icol] = espGridMake(irow, icol, gridRowNum, gridColNum) ;
        }
    }
    int irow,icol ;
    float x0,x1,y0,y1 ;
    for (int i = 0; i<numberOfValidTiles ; i++) {
        espTileShape* t = &tileShapeArray[i] ;
        x0 = MIN(t->vert4[0].x, MIN(t->vert4[1].x, t->vert4[2].x)) ;
        x1 = MAX(t->vert4[0].x, MAX(t->vert4[1].x, t->vert4[2].x)) ;
        y0 = MIN(t->vert4[0].y, MIN(t->vert4[1].y, t->vert4[2].y)) ;
        y1 = MAX(t->vert4[0].y, MAX(t->vert4[1].y, t->vert4[2].y)) ;
        icol = (int)floorf( (x0+x1)/2/gridWidth ) ;
        irow = (int)floorf( (y0+y1)/2/gridHeight ) ;
        espGridAttachTile(gridsArray, irow*gridColNum+icol, tileShapeArray, i , numberOfValidTiles) ;
    }
}

@end

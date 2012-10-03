"""Analysis code run on data from bird 1807"""

import Approximate_Grid_Stitching as AGS
import os.path
reload(AGS)

mydir = os.path.join('c:\\stetner', 'data', 'tracing', '1807-hvcx', 'right2col1row2')

nx = 9
ny = 8
nz = 62
# These numbers were found by pairwise stitching of max intensity projections of cycles
dxx = 282
dyy = -282
dyx = 2.8
dxy = -2.5


ps = AGS.PrairieSeries(nx=nx, ny=ny, nz=nz, dxx=dxx, dyy=dyy, dyx=dyx, dxy=dxy, dirname=mydir)
#ps.set_z(30)
#print ps.dxx, ps.dyy, ps.dxy, ps.dyx
#ps.stitch_coordinates()
#ps.imp_stitched.show()

ps.setZ(23)
AGS.StitchableGrid.stitchAbsolute(ps)
ps.impStitched.show()
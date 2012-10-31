"""Analysis code run on data from bird 1807"""

import Approximate_Grid_Stitching as AGS
import os.path
import ij.plugin.ZProjector

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

#ps.setZ(23)
#AGS.StitchableGrid.stitchAbsolute(ps)
#ps.impStitched.show()


#imp.show()
params = ps.defaultStitchingParams()
params.computeOverlap = True
params.dimensionality = 3

#ps.patchZStack(x=4, y=2).show()
#ps.patchZStack(x=4, y=3).show()

#imp = ps.stitchOneCol(4, params)
#imp.show()

#ps.stitchByCols()
#ps.impStitched.show()


for iy in range(3):
	filename = 'column%02.f.tif' % iy
	imp = ps.stitchOneCol(iy, params)
	IJ.save(imp, os.path.join(mydir, filename))
	print 'Saved ' + os.path.join(mydir, filename)


"""
col = 7
for iy in range(ps.ny):
	imp = ps.patchZStack(x=col, y=iy)
	imp.setTitle('Column %g Row %g' % (col, iy))
	imp.show()
	zp = ij.plugin.ZProjector(imp)
	zp.setMethod(1) #Max Intensity
	zp.doProjection()
	mip = zp.getProjection()
	mip.setTitle('MIP of Column %g Row %g' % (col, iy))
	mip.show()
	"""

print "ok"
import os.path
import Approximate_Grid_Stitching as AGS
import ij.plugin.ZProjector

mydir = os.path.join('C:\\stetner', 'data', 'tracing', 'mes068-lmanx', 'mes068-L2col5row2', 'zseries')
ps = AGS.PrairieSeries(dirname=mydir, nx=4, ny=3, nz=71)

for col in range(ps.nx):
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
	
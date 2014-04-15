"""Stitch z-stacks for brain slice L3col2row1 with a single HVC-X axon. This is
the most medial section that I could find axons in. Area X is rather small in 
this plane.

I imaged this slice on the slide without removing cover slip. There is little 
impact on image quality. I imaged the brain with laser wavelength of 900 nm. 
There is high background autofluorescence at this wavelength, but there is very
little attenuation with depth."""

import os.path
from Approximate_Grid_Stitching import PrairieSeries, stitchSequentialWithRoi
import ij.ImagePlus

indir  = os.path.join('c:\\stetner', 'data', 'tracing', 'hvc-x', 'mes074', 
                      'ZSeries-11072012-1238-299-L3col2row1')
outdir = os.path.join('c:\\stetner', 'data', 'tracing', 'hvc-x', 'mes074', 
                      'L3col2row1-stitched')

ps = PrairieSeries(dirname=indir, nx=6, ny=5, nz=91)

# Stitch each column together by cross correlation
"""
params = ps.defaultStitchingParams()
params.computeOverlap = True
params.dimensionality = 3
for col in range(ps.nx):
	imp = ps.stitchOneCol(col, params)
	filename = 'column%02.f.tif' % col
	IJ.save(imp, os.path.join(outdir, filename))
"""

# There is a problem with column 2 row 4. Replace column02.tif with rows 0-3 
# stitched and leave row 4 out for now
"""
for row in range(ps.ny):
    imp = ps.patchZStack(x=2, y=row)
    imp.setTitle('Column 2 Row %g' % row)
    imp.show()
"""
    

# Manually specify ROIs to stitch columns together using MIPs

roiLeft = [None for i in range(ps.nx)]
roiRght = [None for i in range(ps.nx)]

# ROI definitions
# 0-1
roiRght[0] = Roi(310, 730, 80, 100)
roiLeft[1] = Roi(10, 730, 70, 90)
# 1-2
roiRght[1] = Roi(380, 560, 130, 130)
roiLeft[2] = Roi(30, 240, 160, 150)
# 2-3
roiRght[2] = Roi(340, 910, 150, 140)
roiLeft[3] = Roi(30, 1260, 140, 100)
# 3-4
roiRght[3] = Roi(330, 1210, 90, 90)
roiLeft[4] = Roi(30, 1220, 90, 80)
# 4-5
roiRght[4] = Roi(290, 1370, 160, 230)
roiLeft[5] = Roi(30, 1320, 160, 230)

def columnImages():
    for col in range(ps.nx):
        filename = 'column%02.f.tif' % col
        yield ij.ImagePlus(os.path.join(outdir, filename))

stitched = stitchSequentialWithRoi(columnImages(), roiLeft, roiRght)
IJ.save(stitched, os.path.join(outdir, 'complete.tif'))

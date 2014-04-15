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
from plugin.Stitching_Pairwise import performPairWiseStitching


indir  = os.path.join('c:\\stetner', 'data', 'tracing', 'hvc-x', 'mes074', 
                      'ZSeries-11072012-1238-300-L3col1row1')
outdir = os.path.join('c:\\stetner', 'data', 'tracing', 'hvc-x', 'mes074', 
                      'L3col1row1-stitched')

ps = PrairieSeries(dirname=indir, nx=7, ny=7, nz=85)

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

# Problems with Columns 1, 3, 4, and 6. For columns 1, 3, and 4 it looks like 
# only the sixth row is failing to be stitched properly. Column 6 has bigger
# problems. Maybe we can just leave out row 6 from columns 1, 3, and 4?
"""
for col in [1, 3, 4]:
    fifth = ps.patchZStack(x=col, y=5)
    fifth.setTitle('Column %g Row 5' % col)
    fifth.show()
    
    sixth = ps.patchZStack(x=col, y=6)
    sixth.setTitle('Column %g Row 6' % col)
    sixth.show()
"""

# Yes. The sixth row in columns 1, 3, and 4 have no axon segments. It is safe 
# to just leave these patches out. Stitch columns 1, 3, and 4 with just rows 
# 0-5 and replace the old broken images.
"""
params = ps.defaultStitchingParams()
params.computeOverlap = True
params.dimensionality = 3
for col in [1, 3, 4]:
    stitched = None
    for row in range(6):
        next = ps.patchZStack(x=col, y=row)
        if stitched is None:
            stitched = next
        else:
            performPairWiseStitching(stitched, next, params)
            stitchedNew = IJ.getImage()
            stitched.close()
            stitched = stitchedNew
    filename = 'column%02.f.tif' % col
    IJ.save(stitched, os.path.join(outdir, filename))
    print 'Done with column %g' % col
"""

# Column 6 does not provide any new axon segments. Just leave it out
"""
for row in range(ps.ny):
    imp = ps.patchMIP(x=6, y=row)
    imp.setTitle('Column 6 Row %g' % row)
    imp.show()
"""
    
# Manually specify ROIs to stitch columns together

roiLeft = [None for i in range(ps.nx)]
roiRght = [None for i in range(ps.nx)]

# ROI definitions
# 0-1
roiRght[0] = Roi(280, 680, 200, 700)
roiLeft[1] = Roi(20, 470, 160, 650)
# 1-2
roiRght[1] = Roi(360, 1260, 150, 240)
roiLeft[2] = Roi(40, 1510, 190, 300)
# 2-3
roiRght[2] = Roi(320, 1790, 140, 200)
roiLeft[3] = Roi(20, 1470, 140, 200)
# 3-4
roiRght[3] = Roi(330, 860, 170, 350)
roiLeft[4] = Roi(20, 840, 210, 390)
# 4-5
roiRght[4] = Roi(310, 1280, 190, 170)
roiLeft[5] = Roi(10, 1580, 190, 180)


def columnImages():
    for col in range(6):
        filename = 'column%02.f.tif' % col
        yield ij.ImagePlus(os.path.join(outdir, filename))

stitched = stitchSequentialWithRoi(columnImages(), roiLeft, roiRght)
IJ.save(stitched, os.path.join(outdir, 'complete.tif'))
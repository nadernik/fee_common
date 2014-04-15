import os.path
import Approximate_Grid_Stitching as AGS
from mpicbg.stitching.PairWiseStitchingImgLib import stitchPairwise
from plugin.Stitching_Pairwise import performPairWiseStitching
from Stetner_Stitching_Tools import stitchStackUsingMIP, shiftRoi
from ij.gui import Roi

###############################################################################
mydir = os.path.join('C:\\stetner', 'data', 'tracing', 'mes074-hvcx', 
                     'L2col5row2')
outdir = os.path.join('C:\\stetner', 'data', 'tracing', 'mes074-hvcx', 
                      'L2col5row2-stitched')
ps = AGS.PrairieSeries(dirname=mydir, nx=11, ny=10, nz=78)

def mipfile(col):
	fname = 'column%02.f_MIP.tif' % col
	return os.path.join(outdir, fname)

def zstackfile(col):
	fname = 'column%02.f_ZStack.tif' % col
	return os.path.join(outdir, fname)

###############################################################################

# Manually go through each MIP and record the ones that have axon pieces
"""
col = 10 # Change this to get one column at a time
for iy in range(ps.ny):
	mip = ps.patchMIP(x=col, y=iy)
	mip.setTitle('MIP of Column %g Row %g' % (col, iy))
	mip.show()
"""

good_rows = []
good_rows.append(range(5, 7))  # for column 0
good_rows.append(range(4, 7))  # for column 1
good_rows.append(range(2, 9))  # for column 2
good_rows.append(range(0, 9))  # for column 3
good_rows.append(range(0, 9))  # for column 4, row 6 may be problematic
good_rows.append(range(0, 8))  # for column 5
good_rows.append(range(0, 10)) # for column 6
good_rows.append(range(0, 9))  # for column 7, row 6 may be problematic
good_rows.append(range(0, 9))  # for column 8, row 5 may be problematic
good_rows.append(range(0, 8))  # for column 9, row 5 may be problematic
good_rows.append(range(0))     # for column 10 (no good rows)

# Stitch each column individually. 
"""
for col in range(ps.nx):
	stitchedMIP = None
	stitchedZStack = None
	for row in good_rows[col]:
		if stitchedMIP is None:
			# start with first row
			stitchedMIP = ps.patchMIP(x=col, y=row)
			stitchedZStack = ps.patchZStack(x=col, y=row)
		else:
			# get the offsets that maximize correlation between max
			# intensity projections
			params = ps.defaultStitchingParams()
			params.computeOverlap = True
			result = stitchPairwise(stitchedMIP, ps.patchMIP(x=col, y=row), None, 
			                        None, 1, 1, params)
			xOffset = result.getOffset(0)
			yOffset = result.getOffset(1)
			crossCorrelation = result.getCrossCorrelation()

			# Use these offsets to stitch the max intensity 
			# projection AND the z stack. assume zero offset in 
			# z dimension
			params.computeOverlap = False
			params.xOffset = xOffset
			params.yOffset = yOffset
			performPairWiseStitching(stitchedMIP, ps.patchMIP(x=col, y=row), params)
			stitchedMIP.close() # close old image
			stitchedMIP = IJ.getImage()
			params.dimensionality = 3
			params.zOffset = 0
			performPairWiseStitching(stitchedZStack, ps.patchZStack(x=col, y=row), params)
			stitchedZStack.close() # close the old stack
			stitchedZStack = IJ.getImage()
			
	# Show and save the stitched images
	stitchedMIP.show()
	stitchedZStack.show()
	IJ.save(stitchedMIP, mipfile(col))
	IJ.save(stitchedZStack, zstackfile(col))

	# Close to save memory
	stitchedMIP.close()
	stitchedZStack.close()
"""

"""NOTE!!!!! This failed on columns 9 and 10, so omit these from the rest of the analysis"""

###############################################################################
# Now stitch columns together!
"""
stitchedMIP = None
stitchedZStack = None
for col in range(9): # excluding cols 9 and 10 because they failed earlier
	thisMIP = IJ.openImage(mipfile(col))
	thisZStack = IJ.openImage(zstackfile(col))
	if stitchedMIP is None:
		stitchedMIP = thisMIP
		stitchedZStack = thisZStack
	else:
		print 'stitching col %g' % col
		res = stitchStackUsingMIP(stitchedMIP, thisMIP, stitchedZStack, thisZStack)
		#stitchedMIP.close()    # close old images
		#stitchedZStack.close() # close old images
		stitchedMIP = res['MIP']
		stitchedZStack = res['ZStack']
"""
"""This didn't work. Need to manually specify each Roi"""		
###############################################################################

""" Stitch the columns together from left to right. Use manually defined ROIs 
on the maximum intensity projections to get accurate stitching."""

roiLeft = [None for i in range(ps.nx)]
roiRght = [None for i in range(ps.nx)]
lastXOffset = 0
lastYOffset = 0
stitchedMIP = None
stitchedZStack = None

# ROI definitions
# 0-1
roiRght[0] = Roi(310, 430, 140, 160)
roiLeft[1] = Roi(10, 440, 140, 170)
# 1-2
roiRght[1] = Roi(350, 700, 160, 180)
roiLeft[2] = Roi(40, 1340, 170, 160)
# 2-3
roiRght[2] = Roi(330, 320, 170, 370)
roiLeft[3] = Roi(40, 300, 150, 390)
# 3-4
roiRght[3] = Roi(320, 240, 150, 200)
roiLeft[4] = Roi(20, 220, 150, 220)
# 4-5
roiRght[4] = Roi(320, 1810, 190, 480)
roiLeft[5] = Roi(20, 1470, 160, 490)
# 5-6
roiRght[5] = Roi(340, 470, 160, 280)
roiLeft[6] = Roi(50, 1150, 150, 230)
# 6-7
roiRght[6] = Roi(400, 2060, 100, 190)
roiLeft[7] = Roi(100, 1800, 80, 150)
# 7-8
roiRght[7] = Roi(320, 2180, 90, 90)
roiLeft[8] = Roi(20, 2190, 60, 80)

for col in range(ps.nx):
	# Only stitch if ROIs are defined
	if roiRght[col] is None or roiLeft[col + 1] is None:
		print 'Skipping column %g' % col
		continue
	
	if stitchedMIP is None or stitchedZStack is None:
		stitchedMIP = IJ.openImage(mipfile(col))
		stitchedZStack = IJ.openImage(zstackfile(col))
	
	thisMIP = IJ.openImage(mipfile(col + 1))
	thisZStack = IJ.openImage(zstackfile(col + 1))
	stitchedMIP.setRoi(shiftRoi(roiRght[col], lastXOffset, lastYOffset))
	thisMIP.setRoi(roiLeft[col + 1])
	
	res = stitchStackUsingMIP(stitchedMIP, thisMIP, stitchedZStack, thisZStack)
	stitchedMIP    = res['MIP']
	stitchedZStack = res['ZStack']
	lastXOffset    = res['XOffset']
	lastYOffset    = res['YOffset']

stitchedMIP.show()
stitchedZStack.show()

IJ.save(stitchedMIP, os.path.join(outdir, 'stitchedMIP.tif'))
IJ.save(stitchedZStack, os.path.join(outdir, 'stitchedZStack.tif'))



"""DONE!"""
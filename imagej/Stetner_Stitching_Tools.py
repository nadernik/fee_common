from plugin.Stitching_Pairwise import performPairWiseStitching
from mpicbg.stitching import StitchingParameters
from mpicbg.stitching.PairWiseStitchingImgLib import stitchPairwise
from ij import IJ
from ij.gui import Roi

################################################################################
def stitchStackUsingMIP(mip1, mip2, zstack1, zstack2):
	# get the offsets that maximize correlation between max
	# intensity projections
	params = StitchingParameters()
	params.dimensionality = 2
	params.fusionMethod = 3 # Max Intensity
	params.fusedName = "FusedImage"
	params.checkPeaks = 5 # This is the default when using the GUI
	params.computeOverlap = True
	params.subpixelAccuracy = True
	params.xOffset = 0
	params.yOffset = 0
	params.zOffset = 0
	params.channel1 = 1
	params.channel2 = 1
	params.timeSelect = 0 # No timeseries
	
	result = stitchPairwise(mip1, mip2, mip1.getRoi(), mip2.getRoi(), 1, 1, params)
	params.xOffset = result.getOffset(0)
	params.yOffset = result.getOffset(1)
	crossCorrelation = result.getCrossCorrelation()
	
	# Use these offsets to stitch the MIPs
	params.computeOverlap = False
	performPairWiseStitching(mip1, mip2, params)
	stitchedMIP = IJ.getImage()
	stitchedMIP.hide()
	
	# Use these offsets to stitch the Z stacks. Assume z offset is zero.
	params.dimensionality = 3
	performPairWiseStitching(zstack1, zstack2, params)
	stitchedZStack = IJ.getImage()
	stitchedZStack.hide()
	return {'MIP': stitchedMIP, 'ZStack': stitchedZStack, 
	        'XOffset': params.xOffset, 'YOffset': params.yOffset}
################################################################################
def shiftRoi(oldRoi, dx, dy):
	"""Return a new ROI with top right corner shifted but the same width and height."""
	oldX   = oldRoi.getBounds().getX()
	oldY   = oldRoi.getBounds().getY()
	width  = oldRoi.getBounds().getWidth()
	height = oldRoi.getBounds().getHeight()
	return Roi(oldX + dx, oldY + dy, width, height)
################################################################################

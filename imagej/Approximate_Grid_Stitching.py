import os.path
import re
from ij import IJ, ImagePlus
from ij.gui import Roi
import ij.plugin.ZProjector
from plugin.Stitching_Pairwise import performPairWiseStitching
from mpicbg.stitching import StitchingParameters
from mpicbg.stitching.PairWiseStitchingImgLib import stitchPairwise

class StitchableGrid():
    
    def __init__(self, nx, ny, dxx, dyy, dxy, dyx):
        self.nx = nx
        self.ny = ny
        self.dxx = dxx
        self.dyy = dyy
        self.dxy = dxy
        self.dyx = dyx
        self.crossCorrThreshold = 0.1

    def defaultStitchingParams(self):
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
        return params
        
    def xyOffsetsAbsolute(self, ix, iy):
        xOffset = ix * self.dxx + iy * self.dxy
        yOffset = iy * self.dyy + ix * self.dyx
        return (xOffset, yOffset)
    
    def xyOffsetsApproximate(self, imp2):
        """This function is slow because it computes the cross correlation 
        between images."""
        params = self.defaultStitchingParams()
        params.computeOverlap = True
        imp1 = self.impStitched
        result = stitchPairwise(imp1, imp2, imp1.getRoi(), imp2.getRoi(), 
                                1, 1, params)
        xOffset = result.getOffset(0)
        yOffset = result.getOffset(1)
        crossCorrelation = result.getCrossCorrelation()
        return (xOffset, yOffset, crossCorrelation)

    def stitchPairwise(self, newimp, params):
        performPairWiseStitching(self.impStitched, newimp, params)
        self.impStitched = IJ.getImage()
        self.impStitched.hide()
    
    def stitchAbsolute(self):
        """Stitch based on absolute positions determined by grid"""
        params = self.defaultStitchingParams()
        params.computeOverlap = False
        for iy in range(self.ny):
            for ix in range(self.nx):
                if iy == 0 and ix == 0:
                    self.impStitched = self.getPatch(x=0, y=0)
                else:
                    (x, y) = self.xyOffsetsAbsolute(ix, iy)
                    params.xOffset = x
                    params.yOffset = y
                    self.stitchPairwise(self.getPatch(x=ix, y=iy), params)
                    self.impStitched.show()
                    
    def stitchApproximate(self):
        """Stitch by trying to find best match that is close to the grid.
        The image is stitched in rows. x is incremented from 0 to nx then y is 
        incremented and the process repeats. """
        
        params = self.defaultStitchingParams()
        params.computeOverlap = False
        
        for iy in range(self.ny):
            for ix in range(self.nx):
                newimp = self.getPatch(x=ix, y=iy)
                xAbs, yAbs = self.xyOffsetsAbsolute(ix, iy)
                if iy == 0 and ix == 0: # First image (0th image in 0th row)
                    self.impStitched = newimp
                    continue # no need to stitch the first image to anything
                elif ix == 0: # First image in rows 1+
                    pass #self.setRoiNewRow(newimp)
                else:
                    pass #self.setRoiContinueRow(newimp, xAbs)
                
                xApx, yApx, crossCorr = self.xyOffsetsApproximate(newimp)
                
                if crossCorr > self.crossCorrThreshold:
                    params.xOffset = xApx
                    params.yOffset = yApx
                else:
                    params.xOffset = xAbs
                    params.yOffset = yAbs
                self.stitchPairwise(newimp, params)
                self.impStitched.show()
    
    def setRoiNewRow(self, imp2):
        imp1 = self.impStitched
        
        # ROI on the top of new image
        roi2 = Roi(0, 0, imp2.width, self.dyy)
        imp2.setRoi(roi2)

        # ROI on the bottom left corner of existing image
        roi1 = Roi(0, imp1.height - self.dyy, imp2.width, self.dyy)
        imp1.setRoi(roi1)
    def setRoiContinueRow(self, imp2, xOffset):
        imp1 = self.impStitched
        # ROI on the left of new image
        roi2 = Roi(0, 0, self.dxx, imp2.height)
        imp2.setRoi(roi2)

        # ROI on the right of old image
        roi1 = Roi(xOffset, imp1.height - imp2.height, self.dxx, imp2.height)
        imp1.setRoi(roi1)

class ZeissSeries(StitchableGrid):
    def __init__(self, nx=1, ny=1, dxx=0, dyy=0, dxy=0, dyx=0, dirname=''):
        StitchableGrid.__init__(self, nx, ny, dxx, dyy, dxy, dyx)
        if os.path.isdir(dirname):
		    self.setDir(dirname)
    
    def setDir(self, dirname):
        self.dirname = dirname
        basename = os.path.basename(os.path.normpath(dirname))
        self.baseFileName = basename[:-len('.tif_Files')]

    def getFileName(self, x=-1, y=-1, cycle=0):
        if x >= 0 and y >= 0:
            # x and y (if provided) override cycle number
            cycle = self.xy2cycle(x, y)
        filename = self.baseFileName + '_p%03.f.tif' % cycle
        return os.path.join(self.dirname, filename)
        
    def getPatch(self, x=-1, y=-1, cycle=0):
        return IJ.openImage(self.getFileName(x, y, cycle))
        
    def xy2cycle(self, x, y):
        if x >= self.nx:
            raise IndexError('x too high')
        if y >= self.ny:
            raise IndexError('y too high')
        return y * self.nx + x

class PrairieSeries(StitchableGrid):
    def __init__(self, nx=1, ny=1, dxx=0, dyy=0, 
                 dxy=0, dyx=0, dirname='', nz=1):
        assert dyy <= 0
        StitchableGrid.__init__(self, nx, ny, dxx, dyy, dxy, dyx)
        self.nz = nz
        if os.path.isdir(dirname):
		    self.setDir(dirname)
        self.getPatch = self.patchFunction(0)
    
    def setDir(self, dirname):
        self.dirname = dirname
        allfiles = os.listdir(dirname)
        # ZSeries-08212012-1940-226_Cycle001_CurrentSettings_Ch1_000011.tif
        m = None
        try:
            while m is None:
                filename = allfiles.pop()
                m = re.match('(.+)_Cycle(\d+)(.+)_(\d+).tif', filename)
        except IndexError:
            print 'Unknown filename format'
            raise
        
        # make filename templtae
        cyc = '%0' + str(len(m.group(2))) + '.f' # replace cycle with field
        z   = '%0' + str(len(m.group(4))) + '.f' # replace z with field
        self.fn_tmpl = (m.group(1) + '_Cycle' + cyc + 
                        m.group(3) + '_' + z + '.tif')
        
    
    def getFileName(self, x=-1, y=-1, cycle=0, z=0):
        if x >= 0 and y >= 0:
            # x and y (if provided) override cycle number
            cycle = self.xy2cycle(x, y)
        # function arguments are zero-based indexed but files are indexed starting at 1
        fn = self.fn_tmpl % (cycle + 1, z + 1)
        return os.path.join(self.dirname, fn)
    
    def setZ(self, z):
        self.getPatch = self.patchFunction(z)
    
    def stitchAbsolute(self):
        self.stitchedZStack = None
        for iz in range(self.nz):
            print 'starting z %g' % iz
            self.setZ(iz)
            StitchableGrid.stitchAbsolute(self)
            if self.stitchedZStack is None:
                self.stitchedZStack = self.impStitched.createEmptyStack()
            self.stitchedZStack.addSlice(str(iz), 
                                          self.impStitched.getProcessor())
        self.impStitched = ImagePlus('Stitched Image', self.stitchedZStack)
    
    def stitchApproximate():
        self.stitchedZStack = None
        for iz in range(self.nz):
            self.setZ(iz)
            StitchableGrid.stitchApproximate(self)
            if self.stitchedZStack is None:
                self.impstitchedZStack = self.impStitched.createEmptyStack()
            self.stitchedZStack.addSlice(str(iz), 
                                          self.impStitched.getProcessor())
        self.impStitched = ImagePlus('Stitched Image', self.stitchedZStack)
        
    def patchFunction(self, z):
        def getPatch(x=-1, y=-1, cycle=0):
            filename = self.getFileName(x, y, cycle, z)
            return IJ.openImage(filename)
        return getPatch
        
    def xy2cycle(self, x, y):
        if x >= self.nx:
            raise IndexError('x too high')
        if y >= self.ny:
            raise IndexError('y too high')
        return y * self.nx + x
    
    def xyOffsetsAbsolute(self, ix, iy):
        """Override parent because in PrairieSeries, new rows are added to the 
        TOP of the image. The coordinates are always relative to the top right 
        corner of the image, so after we add the first image in a new row, we 
        no longer need to account for the yOffset between rows (dyy). Note that
        the offsets computed here only work when we iterate over x, then over 
        y."""
        
        xOffset = ix * self.dxx + iy * self.dxy
        if ix == 0: # if new row
            yOffset = self.dyy
        else:
            yOffset = self.dyx
        return (xOffset, yOffset)
        
    def setRoiNewRow(self, imp2):
        imp1 = self.impStitched
        
        # ROI on top of old image
        roi1 = Roi(0, 0, imp2.width, -self.dyy)
        imp1.setRoi(roi1)
        
        # ROI on bottom of new image
        roi2 = Roi(0, imp2.height + self.dyy, imp2.width, self.dyy)
        imp2.setRoi(roi2)
    
    def setRoiContinueRow(self, imp2, xOffset):
        imp1 = self.impStitched
        
        # ROI on Left side of new image
        roi2 = Roi(0, 0, self.dxx, imp2.height)
        imp2.setRoi(roi2)
        
        # ROI in top right part of old image
        roi1 = Roi(xOffset, 0, self.dxx, imp2.height)
        imp1.setRoi(roi1)
    
    def patchZStack(self, x=-1, y=-1, cycle=0):
    	"""Z Stack of one cycle in the series"""
        imp = IJ.openImage(self.getFileName(x, y, cycle, 0))
        imp.close()
        stk = imp.createEmptyStack()
        for z in range(self.nz):
            filename = self.getFileName(x, y, cycle, z)
            imp = IJ.openImage(filename)
            stk.addSlice(os.path.basename(filename), imp.getProcessor())
            imp.close()
        return ImagePlus('Patch', stk)
    
    def patchMIP(self, x=-1, y=-1, cycle=0):
        """Maximum intensity projection of one cycle in the series"""
        imp = self.patchZStack(x, y, cycle)
        zp = ij.plugin.ZProjector(imp)
        zp.setMethod(1) #Max Intensity
        zp.doProjection()
        return zp.getProjection()
    
    def stitchOneCol(self, ix, params):
        impCol = self.patchZStack(x=ix, y=0)
        for iy in range(1, self.ny):
            newimp = self.patchZStack(x=ix, y=iy)
            performPairWiseStitching(impCol, newimp, params)
            impColNew = IJ.getImage()
            #impCol.close()
            impCol = impColNew
            #impCol.hide()
        return impCol
    
    def stitchByCols(self):
        params = self.defaultStitchingParams()
        params.computeOverlap = True
        params.dimensionality = 3
        self.impStitched = self.stitchOneCol(0, params)
        for col in range(1, self.nx):
            impCol = self.stitchOneCol(col, params)
            self.stitchPairwise(impCol, params)
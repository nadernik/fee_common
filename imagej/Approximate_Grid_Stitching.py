import os.path
import re
from ij import IJ
from ij.gui import Roi
from plugin.Stitching_Pairwise import performPairWiseStitching
from mpicbg.stitching import StitchingParameters
from mpicbg.stitching.PairWiseStitchingImgLib import stitchPairwise

class StitchableGrid():

    default_params = StitchingParameters()
    default_params.dimensionality = 2
    default_params.fusionMethod = 3 # Max Intensity
    default_params.fusedName = "FusedImage"
    default_params.checkPeaks = 5 # This is the default when using the GUI
    default_params.computeOverlap = True
    default_params.subpixelAccuracy = True
    default_params.xOffset = 0
    default_params.yOffset = 0
    default_params.zOffset = 0
    default_params.channel1 = 1
    default_params.channel2 = 1
    default_params.timeSelect = 0 # No timeseries
    
    xcorr_threshold = 0.1
    
    def __init__(self, nx, ny, dxx, dyy, dxy, dyx):
        self.nx = nx
        self.ny = ny
        self.dxx = dxx
        self.dyy = dyy
        self.dxy = dxy
        self.dyx = dyx

    def stitch_grid(self):
        # Estimate dxx and dyx by stitching horizontal neighbors
        # Estimate dxy and dyy by stitching vertical neighbors
        # Remove outliers
        
        stitched = self.get_patch(x=0, y=0)
        for iy in range(self.ny):
            if iy == 0:
                # For the very first image, don't stitch it to anything
                self.imp_stitched = self.get_patch(x=0, y=0)
            else: 
                # For the first image in rows 1+, stitch it in at the bottom of the 
                # existing image.
                self.add_below(self.get_patch(x=0, y=iy))
                
            for ix in range(1, self.nx):
                # For each additional image in this row, stitch it in to the right of 
                # the image we just added
                self.add_right(self.get_patch(x=ix, y=iy))
    
    def max_xcorr(self, imp2):
        imp1 = self.imp_stitched
        result = stitchPairwise(imp1, imp2, 
            imp1.getRoi(), imp2.getRoi(), 1, 1, StitchableGrid.default_params)
        return result.getCrossCorrelation()
    
    def stitch_approx(self, imp_to_add, x, y):
        """Stitch images by cross-correlation (if good match) or coordinates.
        
        Tries to stitch new image to existing self.imp_stitched. Uses the 
        coordinates that maximize the cross-correlation if the max value of 
        the cross-correlation is at least xcorr_threshold. Otherwise, 
        stitches by coordinates."""
        
        # This doesn't work. Might be related to this old issue:
        # http://bugs.jython.org/issue1551...but
        ##BROKEN## params = copy.copy(StitchableGrid.default_params)
        params = StitchableGrid.default_params
        params
        
        # Only use best fit if the max correlation is over threshold
        ##BROKEN## params.computeOverlap = (self.max_xcorr(imp_to_add) >= 
        ##BROKEN##                          StitchableGrid.xcorr_threshold)
        params.computeOverlap =  (self.max_xcorr(imp_to_add) >= 
                                  StitchableGrid.xcorr_threshold)
        # overwrites default params! this is not ideal
            
        performPairWiseStitching(self.imp_stitched, imp_to_add, params)
        self.imp_stitched = IJ.getImage()
        self.imp_stitched.hide()
    
    def add_below(self, imp_to_add):
        imp_old = self.imp_stitched
        
        # ROI on the top of new image
        roi_add = Roi(0, 0, imp_to_add.width, self.dyy)
        imp_to_add.setRoi(roi_add)

        # ROI on the bottom left corner of existing image
        roi_old = Roi(0, imp_old.height - self.dyy, imp_to_add.width, self.dyy)
        imp_old.setRoi(roi_old)
        
        self.stitch_approx(imp_to_add, self.dxx, self.dyy)

    def add_right(self, imp_to_add):
        imp_old = self.imp_stitched
        # ROI on the left of new image
        roi_add = Roi(0, 0, self.dxx, imp_to_add.height)
        imp_to_add.setRoi(roi_add)

        # ROI on the right of old image
        roi_old = Roi(imp_old.width - self.dxx, imp_old.height - imp_to_add.height, 
                      self.dxx, imp_to_add.height)
        imp_old.setRoi(roi_old)

        # Stitch images
        self.stitch_approx(imp_to_add, self.dxx, self.dyy)


###############################################################################

class ZeissSeries(StitchableGrid):
    def __init__(self, nx=1, ny=1, dxx=0, dyy=0, dxy=0, dyx=0, dirname=''):
        StitchableGrid.__init__(self, nx, ny, dxx, dyy, dxy, dyx)
        if os.path.isdir(dirname):
		    self.set_dir(dirname)
    
    def set_dir(self, dirname):
        self.dirname = dirname
        basename = os.path.basename(os.path.normpath(dirname))
        self.base_filename = basename[:-len('.tif_Files')]

    def get_filename(self, x=-1, y=-1, cycle=0):
        if x >= 0 and y >= 0:
            # x and y (if provided) override cycle number
            cycle = self.xy2cycle(x, y)
        filename = self.base_filename + '_p%03.f.tif' % cycle
        return os.path.join(self.dirname, filename)
        
    def get_patch(self, x=-1, y=-1, cycle=0):
        return IJ.openImage(self.get_filename(x, y, cycle))
        
    def xy2cycle(self, x, y):
        if x >= self.nx:
            raise IndexError('x too high')
        if y >= self.ny:
            raise IndexError('y too high')
        return y * self.nx + x

class PrairieSeries(StitchableGrid):
    def __init__(self, nx=1, ny=1, dxx=0, dyy=0, dxy=0, dyx=0, dirname=''):
        StitchableGrid.__init__(self, nx, ny, dxx, dyy, dxy, dyx)
        if os.path.isdir(dirname):
		    self.set_dir(dirname)
        self.get_patch = self.patch_function(0)
    
    def set_dir(self, dirname):
        # get the name of one tif file
        allfiles = os.listdir(dirname)
        # ZSeries-08212012-1940-226_Cycle001_CurrentSettings_Ch1_000011.tif
        m = None
        try:
            while m is not None
                filename = allfiles.pop()
                m = re.match('(.+)_Cycle(\d+)(.+)(\d+).tif', filename)
        except:
            print 'Unknown filename format'
            raise
        
        # make filename templtae
        cyc = '%0' + len(m.group(2)) + '.f' # replace cycle with field
        z   = '%0' + len(m.group(4)) + '.f' # replace z with field
        self.fn_tmpl = m.group(1) + '_Cycle' + cyc + m.group(3) + z + '.tif'
        
    
    def get_filename(self, x=-1, y=-1, cycle=0, z=0):
        if x >= 0 and y >= 0:
            # x and y (if provided) override cycle number
            cycle = self.xy2cycle(x, y)
        # function arguments are zero-based indexed but files are indexed starting at 1
        fn = self.fn_tmpl % (cycle + 1, z + 1)
        return os.path.join(self.dirname, fn)
        
    def stitch_grid():
        # override parent to stitch each z
        # parent will call self.get_patch(x, y, cycle) to get each image. 
        # Create a function that returns the proper image in the current z.
        self.stitched_zstack = None
        for z in range(self.nz):
            self.get_patch = self.patch_function(z)
            StitchableGrid.stitch_grid()
            if self.stitched_zstack is None:
                self.imp_stitched_zstack = self.imp_stitched.createEmptyStack()
            self.stitched_zstack.addSlice(z, self.imp_stitched.getProcessor())
        self.imp_stitched = ImagePlus('Stitched Image', self.stitched_zstack)
        
    def patch_function(self, z):
        def get_patch(self, x=-1, y=-1, cycle=0):
            return IJ.openImage(self.get_filename(x, y, cycle, z))
        return get_patch
        
    def xy2cycle(self, x, y):
        if x >= self.nx:
            raise IndexError('x too high')
        if y >= self.ny:
            raise IndexError('y too high')
        return y * self.nx + x
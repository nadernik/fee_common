import Approximate_Grid_Stitching as AGS
import os.path
reload(AGS)

#zs = AGS.ZeissSeries(nx=9, ny=12, dxx=500, dyy=500, 
#                     dirname='D:\\mes059-R2col4row2.tif_Files')
"""
print "base file name is " + zs.base_filename
print "file name for x=9 y=2 is " + zs.get_filename(x=9, y=2)


print "Cycles, should be in order from 1 to 50"
c = 0
for y in range(5):
    for x in range(10):
        cycle = zs.xy2cycle(x, y)
        assert c == cycle
        print cycle
        c = c + 1
        
print zs.get_filename(x=10, y=2)
"""

#zs.stitch_grid()
#zs.imp_stitched.show()

mydir = os.path.join('c:\\stetner', 'data', 'tracing', '1807-hvcx', 'right2col1row2')
print mydir
ps = AGS.PrairieSeries(dirname=mydir)
print ps.fn_tmpl
print ps.get_filename(cycle=1)
print ps.get_filename(cycle=2, z=1)
ps.set_z(30)
imp = ps.get_patch(cycle=44)
imp.show()

function vcdb = apply_polygon_file(vcdb, polygon_file)

load(polygon_file)
if ~exist('c', 'var')
    error('Invalid polygon file.')
end

vcdb.c = c;

vcdb = refresh_clusters(vcdb);
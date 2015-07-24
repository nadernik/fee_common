function callbackIfEnabled(fcnname, obj, varargin)
if strcmp('on', get(obj, 'Enable'))
    egm_Sorted_rasters(fcnname, obj, varargin{:})
else
    error('Object not enabled')
end

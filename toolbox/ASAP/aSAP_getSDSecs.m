function lengthSec = aSAP_getSDSecs(m_spec_deriv, param)
lengthSec = size(m_spec_deriv,1)*(param.winstep/param.fs);
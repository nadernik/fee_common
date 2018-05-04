function fScale = aSAP_getSDAutoscale(m_spec_deriv)
fScale = prctile(abs(m_spec_deriv(1:end)), 85);
function aSAP_displaySyll(sylls,num)

[sd, params] = aSAP_getSyllSD(sylls,num);
aSAP_displaySpectralDerivative(sd, params, 0, 0, -Inf, false, 0);


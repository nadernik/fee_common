function y = deglitch(x, varargin)
% removes single sample glitches from a signal

P.bDebug = 0;
P.threshB = 60;
P.threshT = 200;
P = parseargs(P,varargin{:});

dx = diff(x);
bounce = dx(1:end-1) + dx(2:end);

idx = abs(bounce) < P.threshB & abs(dx(2:end)) > P.threshT;

y = x;
y([false idx false]) = x([idx false false]);

if P.bDebug
    figure(4823)
    ah(1) = subplot(2,1,1);
    plot(x);
    ah(2) = subplot(2,1,2);
    plot(y)
    linkaxes(ah,'x')
    pause
end

    
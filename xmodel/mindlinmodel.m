function mindlinmodel
% This is an implementation of the model of vocal production from:
% Reconstruction of physiological instructions from Zebra finch song
% Perl, Arneodo, Amador, Goller, and Mindlin
% Physical Review E 85, 051909 (2011)

% This function numerically integrates the "Normal Form" of the equations 
% for the movement of the syringeal labia. It does not include the 
% helmholtz resonator model of the vocal tract yet.

gamma = 24000; % This parameter was determined by Perl et al. to be the same for all birds tested, so we use their value
y0 = [1 1]';
dxdt = @(t,x,y) y;
dydt = @(t,x,y) alpha(t)*gamma^2 - beta(t)*gamma^2*x - gamma^2*x^3 - gamma*x^2*y + gamma^2*x^2 - gamma*x*y;

odefun = @(t,y) [dxdt(t,y(1),y(2)); dydt(t,y(1),y(2))];

fs = 40e3; % 40 kHz sampling rate
tspan = 0:(1/fs):200e-3; % 200 ms
[T,Y] = ode45(odefun, tspan, y0);


subplot(4,2,1:2)
plot(T,Y(:,2))
% there are large transients whenever the parameters change suddenly (120ms, 140ms, 160ms, 180ms)

subplot(4,2,3:4)
displaySpecgramQuick(Y(:,2),fs)
% These transients are very short, but they dominate the spectrogram.

subplot(4,2,5)
ndx = T > .122 & T < .139;
plot(T(ndx), Y(ndx,2))
subplot(4,2,7)
displaySpecgramQuick(Y(ndx,2),fs)
subplot(4,2,6)
ndx = T > .142 & T < .159;
plot(T(ndx), Y(ndx,2))
subplot(4,2,8)
displaySpecgramQuick(Y(ndx,2),fs)
% In between the transients, the model has some steady state behavior with 
% harmonic stacks.

    function a = alpha(t)
        % Keep the same parameters for the first 120 ms to let the initial
        % conditions settle, then change the parameters every 20 ms.
        if     t < 120e-3
            a = -0.02;
        elseif t < 140e-3
            a = -0.12;
        elseif t < 160e-3
            a = -0.04;
        elseif t < 180e-3
            a = -0.08;
        else
            a = -0.06;
        end
    end

    function b = beta(t)
        % Keep the same parameters for the first 120 ms to let the initial
        % conditions settle, then change the parameters every 20 ms.
        if     t < 120e-3
            b = -0.15;
        elseif t < 140e-3
            b = -0.08;
        elseif t < 160e-3
            b = -0.20;
        elseif t < 180e-3
            b = -0.15;
        else
            b = -0.15;
        end
    end

end

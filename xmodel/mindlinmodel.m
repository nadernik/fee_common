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

subplot(4,2,3:4)
displaySpecgramQuick(Y(:,2),fs)

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
% There are some wierd very low freq components. What is going on??

    function a = alpha(t)
        % Represents air sac pressure
        
        % Keep constant for the first 100 ms to let things stabilize, then
        % linearly ramp the value up
        a = -.1;
    end

    function b = beta(t)
        % Represents tension
        
        % Keep the same parameters for the first 120 ms to let the initial
        % conditions settle, then change the parameters every 20 ms.
        if t > .1
            b = interp1([.1, .2], [-.25, -.1], t);
        else
            b = -0.25;
        end
    end

end

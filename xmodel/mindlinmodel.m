function mindlinmodel
% This is an implementation of the model of vocal production from:
% Reconstruction of physiological instructions from Zebra finch song
% Perl, Arneodo, Amador, Goller, and Mindlin
% Physical Review E 85, 051909 (2011)

% This function numerically integrates the "Normal Form" of the equations 
% for the movement of the syringeal labia. It does not include the 
% helmholtz resonator model of the vocal tract yet.

% NOTE: There is a sign mistake in the equation in the paper by Perl et al.
% See Amador et al. 2013 Figure 1 for the correct equation and Figure 2d to
% see where zebra finch songs fall in the parameter space.

alpha = 0.1; % represents air sac pressure
beta  = 0.2; % represents tension of the ventral syringeal muscle
gamma = 24000; % This parameter was determined by Perl et al. to be the same for all birds tested, so we use their value
y0 = [0;0]; % initial condition
dxdt = @(t,x,y) y;
dydt = @(t,x,y) -alpha*gamma^2 - beta*gamma^2*x - gamma^2*x^3 - gamma*x^2*y + gamma^2*x^2 - gamma*x*y;
% Here the parameters alpha and beta are constant in time, but to make a
% song they would change as a function of time.

odefun = @(t,y) [dxdt(t,y(1),y(2)); dydt(t,y(1),y(2))];

fs = 40e3; % 40 kHz sampling rate
tspan = 0:(1/fs):200e-3; % 200 ms
[T,Y] = ode23(odefun, tspan, y0);

subplot(2,1,1)
plot(T,Y(:,1))
title(sprintf('\\alpha = %g \n\\beta = %g', alpha, beta))
ax1 = gca;

subplot(2,1,2)
displaySpecgramQuick(Y(:,1),fs)
ax2 = gca;

linkaxes([ax1, ax2], 'x')
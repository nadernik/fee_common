dt = .001;
t = -1:dt:1; 
On = normpdf(t, -.01, .005);
%Off = zeros(1,length(t)); Off(t>0&t<.5) = 1/(.5);
Off = normpdf(t, -.05, .05);
%On = On/max(On);
%Off = Off/max(Off);



Filter = On-Off; 
dur = .5;
ns = ceil(dur/dt);
Input = [zeros(1, ns) ones(1,ns) zeros(1,ns)];
m = length(Input); 
n = length(Filter);
Output = conv(Input, Filter);

figure; k = subplot(3,1,1); plot(t, On-Off); 
h = subplot(3,1,2); plot(dt:dt:m*dt, Input)
g = subplot(3,1,3); plot((dt:dt:(m+n-1)*dt)- (n-1)*dt/2, Output);
linkaxes([h g], 'x')
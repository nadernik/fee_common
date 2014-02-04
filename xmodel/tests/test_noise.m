%%
% Changed sn.noise to be just the noise, not including offset. Offset
% should now be added in when calculating LMAN output. This tests to make
% sure that LMAN output still looks the same after this change. 

%% Run this once with old code and again with new code, save results!
clear all

sn = SparseNet();

sn.nhvc  =  100;
sn.nmsn  =  300;
sn.niter =   10;

maxtemplate   = 1;   % maximum template value (this is arbitrary)

% Derived parameters
sn.lmanstd    = 0.05 * maxtemplate; % Standard deviation of LMAN noise
sn.lmanoffset = 2    * sn.lmanstd;  % Mean of LMAN noise

% HVC-MSN weights start at zero and do not change
sn.winit    = 0;
sn.latinhib = 0;
sn.LTPrate  = 0;
sn.LTDrate  = 0;
sn.pinhib   = 0;

sn.init()
sn.simulate()


%% Plots results from old (black) and new (red) code. Should look the same.

% Results from old code
clear sn
load c:\stetner\data\sparsenet\noisepre.mat
subplot(1,2,1)
plot(sn.lmanout, 'k')
hold on
subplot(1,2,2)
[n,x] = hist(sn.lmanout(:));
stairs(x,n,'k')
hold on

% Results from new code
clear sn
load c:\stetner\data\sparsenet\noisepost.mat
subplot(1,2,1)
plot(sn.lmanout, 'r')
xlabel('Time')
ylabel('LMAN otuput')
hold off
subplot(1,2,2)
[n,x] = hist(sn.lmanout(:));
stairs(x,n,'r')
xlabel('LMAN output')
ylabel('Count')
hold off
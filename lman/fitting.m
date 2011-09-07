function fitting(freq,freqmag)
%FITTING    Create plot of datasets and fits
%   FITTING(FREQ,FREQMAG)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  2

 
% Data from dataset "freqmag vs. freq":
%    X = freq:
%    Y = freqmag:
%    Unweighted
%
% This function was automatically generated on 08-Jul-2011 16:34:46

% Set up figure to receive datasets and fits
f_ = clf;
figure(f_);
set(f_,'Units','Pixels','Position',[815 244 680 484]);
legh_ = []; legt_ = {};   % handles and text for legend
xlim_ = [Inf -Inf];       % limits of x axis
ax_ = axes;
set(ax_,'Units','normalized','OuterPosition',[0 0 1 1]);
set(ax_,'Box','on');
axes(ax_); hold on;

 
% --- Plot data originally in dataset "freqmag vs. freq"
freq = freq(:);
freqmag = freqmag(:);
h_ = line(freq,freqmag,'Parent',ax_,'Color',[0.333333 0 0.666667],...
     'LineStyle','none', 'LineWidth',1,...
     'Marker','.', 'MarkerSize',12);
xlim_(1) = min(xlim_(1),min(freq));
xlim_(2) = max(xlim_(2),max(freq));
legh_(end+1) = h_;
legt_{end+1} = 'freqmag vs. freq';

% Nudge axis limits beyond data limits
if all(isfinite(xlim_))
   xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
   set(ax_,'XLim',xlim_)
end


% --- Create fit "double exponential"
ok_ = isfinite(freq) & isfinite(freqmag);
st_ = [26.44773176177 -0.02616078276467 1.406734553569 -0.002276949940806 ];
ft_ = fittype('exp2');

% Fit this model using new data
cf_ = fit(freq(ok_),freqmag(ok_),ft_,'Startpoint',st_);

% Or use coefficients from the original fit:
if 0
   cv_ = { 24.36429480642, -0.02433143696318, 1.14793979098, -0.001712272286111};
   cf_ = cfit(ft_,cv_{:});
end

% Plot this fit
h_ = plot(cf_,'fit',0.95);
legend off;  % turn off legend from plot method call
set(h_(1),'Color',[1 0 0],...
     'LineStyle','-', 'LineWidth',2,...
     'Marker','none', 'MarkerSize',6);
legh_(end+1) = h_(1);
legt_{end+1} = 'double exponential';

% --- Create fit "exp with offset"
ok_ = isfinite(freq) & isfinite(freqmag);
st_ = [24 0.02 1 ];
ft_ = fittype('a*exp(-b*x)+c',...
     'dependent',{'y'},'independent',{'x'},...
     'coefficients',{'a', 'b', 'c'});

% Fit this model using new data
cf_ = fit(freq(ok_),freqmag(ok_),ft_,'Startpoint',st_);

% Or use coefficients from the original fit:
if 0
   cv_ = { 21.96290476176, 0.02153125006754, 0.620998990448};
   cf_ = cfit(ft_,cv_{:});
end

% Plot this fit
h_ = plot(cf_,'fit',0.95);
legend off;  % turn off legend from plot method call
set(h_(1),'Color',[0 0 1],...
     'LineStyle','-', 'LineWidth',2,...
     'Marker','none', 'MarkerSize',6);
legh_(end+1) = h_(1);
legt_{end+1} = 'exp with offset';

% Done plotting data and fits.  Now finish up loose ends.
hold off;
leginfo_ = {'Orientation', 'vertical', 'Location', 'NorthEast'}; 
h_ = legend(ax_,legh_,legt_,leginfo_{:});  % create legend
set(h_,'Interpreter','none');
xlabel(ax_,'');               % remove x label
ylabel(ax_,'');               % remove y label

function updated_specgram_quick(signal, Fs, varargin)
%UPDATED_SPECGRAM_QUICK create interactive spectrogram
%   UPDATED_SPECGRAM_QUICK(signal, Fs) creates an interactive spectrogram
%   plot of the signal with sampling rate Fs that is calculated to fit the
%   resolution of the plot. Left clicking zooms, dragging boxes sets the
%   plot limits, double clicking zooms out. Based entirely on
%   DISPLAYSPECGRAMQUICK.M by Aaron Andalman. Differences include: named
%   optional arguments, correct redisplay of spectrogram when the figure is
%   resized, does not destroy other plots in the same axes when resized,
%   ability to freeze the colormap so that subsequent changes of the
%   figure's colormap do not change the plot colors.
%
%   UPDATED_SPECGRAM_QUICK(signal, Fs,...) where signal and Fs are followed
%   by any of the named parameters as folows:
%   'freqRange': default [500 7500], bounds the frequencies included in the
%       spectrogram
%   'startTime': default 0, sets the time of the first index in signal
%   'nCourse': default 1, allows for alteration of the plot resolution
%   'cLimits': default [], changes the colormap range to fill [min, max].
%       if empty then the min and max is calculated from the data.
%   'windowSize': default 512, changes the FFT window size
%   'NFFT': default 1024, changes the number of FFT points used in the
%       spectrogram
%   'ax': default current axes, the axes to put the spectrogram in
%   'backgroundColor': default [0 0 0], the color of the bottom of the
%       colormap
%   'colorMap': default jet(256), colormap to use for spectrogram
%   See also DISPLAYSPECGRAMQUICK, ELECTRO_SONOGRAM_CLONER
%   
%   REQUIRES (If Matlab 2014a or lower): FreezeColors:
%   http://www.mathworks.com/matlabcentral/fileexchange/7943-freezecolors---unfreezecolors
%   getParentFigure
%   Galen Lynch, 8/22/2014
persistent p;
if isempty(p)
    p = inputParser();
    addParameter(p, 'freqRange', [500 7500]);
    addParameter(p, 'startTime', 0);
    addParameter(p, 'nCourse', 1);
    addParameter(p, 'cLimits', []);
    addParameter(p, 'windowSize', 512);
    addParameter(p, 'NFFT', 1024);
    addParameter(p, 'ax', []);
    addParameter(p, 'backgroundColor', [0, 0 0]);
    addParameter(p, 'colorMap', jet(256));
    addParameter(p, 'frequencyUnits', 'Hz');
end
parse(p, varargin{:});
Options = p.Results;
assert(numel(signal) > 0, 'Received empty signal');
freqRange = Options.freqRange;
startTime = Options.startTime;
nCourse = Options.nCourse;
cLimits = Options.cLimits;
windowSize = Options.windowSize;
NFFT = Options.NFFT;
if isempty(Options.ax)
    Options.ax = gca;
end
cMap = Options.colorMap;
cMap(1,:) = Options.backgroundColor;%set background to black
hFig = getParentFigure(Options.ax);
%Determine the size of the axis... to determine the
ud.ax = Options.ax;
ud.nCourse = nCourse; %sets the resolution I believe
ud.windowSize = windowSize;
ud.NFFT = NFFT;
ud.signal = signal;
ud.Fs = Fs;
ud.startTime = startTime;
ud.freqRange = freqRange;
ud.cLimits = cLimits;
ud.startndx = 1;
ud.endndx = length(signal);
ud.cMap = cMap;
ud.hIm = [];
ud.hFig = hFig;
ud.freqUnits = Options.frequencyUnits;

set(ud.ax, 'UserData', ud);
set(ud.ax, 'ButtonDownFcn', @buttondown_updatedspecgram);

set(hFig, 'ResizeFcn', @(hObject, event) helper_updatedspecgram(get(ud.ax, 'UserData')));
ud.xlh = addlistener(ud.ax, 'XLim', 'PostSet', @(src, evnt) xlim_updatedspecgram(ud.ax));
helper_updatedspecgram(ud);
xlabel(ud.ax, 'Time (s)');
ylabel(ud.ax, sprintf('Frequency [%s]', ud.freqUnits));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function helper_updatedspecgram(ud)
persistent e;
windowSize = ud.windowSize;%FFT window size
windowSize = min(windowSize, ud.endndx - ud.startndx);%must be at least as long as the signal
NFFT = ud.NFFT;  %greater freq precision can be achieved by increasing this.
delete(ud.xlh);
rszFn = get(ud.hFig, 'ResizeFcn');
set(ud.hFig, 'ResizeFcn', '');%empty resize function to avoid callback loops
axCache = gca();%Store the current axes to put focus back on it later
axes(ud.ax);%Bring this spectrogram's axis into focus (imagesc doesn't have an ax argument)
%determine size of axis relative to size of the signal,
%use this to adapt the window overlap and downsampling of the signal.
%no need to worry about size of fftwindow, this doesn't effect speed.
set(ud.ax,'Units','pixels')
pixSize = get(ud.ax,'Position');
numPixels = pixSize(3) / ud.nCourse;
numWindows = (ud.endndx - ud.startndx) / windowSize;
if(numWindows < numPixels)
    %If we have more pixels, then ffts, then increase the overlap
    %of fft windows accordingly.
    ratio = ceil(numPixels/numWindows);
    windowOverlap = min(.999, 1 - (1/ratio));
    windowOverlap = floor(windowOverlap*windowSize);
    sss = ud.signal(ud.startndx:ud.endndx);
    Fs = ud.Fs;
else
    %If we have more ffts then pixels, then we can do things, we can
    %downsample the signal, or we can skip signal between ffts.
    %Skipping signal mean we may miss bits of song altogether.
    %Decimating throws away high frequency information.
    ratio = floor(numWindows/numPixels);
    windowOverlap = -1*ratio;
    windowOverlap = floor(windowOverlap*windowSize);
    sss = ud.signal(ud.startndx:ud.endndx);
    Fs = ud.Fs;
    %windowOverlap = 0;
    %sss = decimate or downsample(ud.signal(ud.startndx:ud.endndx), ratio);
    %Fs = ud.Fs / ratio;
end
%Compute the spectrogram
if(size(e,1) ~= windowSize)
    if(windowSize>2)
        [e] = dpss(windowSize,1);
    else
        warning('updated_specgram_quick is bailing: windowSize is too small to make new window taper');
        return;
    end
end
[S,F,T] = spectrogram(sss,e(:,1),windowOverlap,NFFT,Fs);
%[J1,F,T,P] = spectrogram(sss,e(:,1),windowOverlap,NFFT,Fs);
%[J2,F,T,P] = spectrogram(sss,e(:,2),windowOverlap,NFFT,Fs);
%m_time_deriv=-1*(real(J1).*real(J2)+imag(J1).*imag(J2));
%m_freq_deriv=((imag(J1).*real(J2)-real(J1).*imag(J2)));
%m_time_deriv_max=max(m_time_deriv.^2,[],2);
%m_freq_deriv_max=max(m_freq_deriv.^2,[],2);
%m_FM=atan(m_time_deriv_max./(m_freq_deriv_max+eps));
%cFM=cos(m_FM);
%sFM=sin(m_FM);
%m_spec_deriv=m_time_deriv(:,:).*(sFM*ones(1,size(m_time_deriv,2)))+m_freq_
%deriv(:,:).*(cFM*ones(1,size(m_freq_deriv,2)));

ndx = find((F>=ud.freqRange(1)) & (F<=ud.freqRange(2)));
delete(ud.hIm);%Get rid of the outdated spectrogram
%Draw the spectrogram
holdState = ishold(ud.ax);%Cache existing hold status
hold(ud.ax, 'on');
times = T + ud.startTime + (ud.startndx-1)/ud.Fs;
freqs = F(ndx);
if strcmpi(ud.freqUnits, 'Hz')
    %do nothing
elseif strcmpi(ud.freqUnits, 'KHz')
    freqs = freqs./1000;
else
    error('Unrecognized frequency units');
end
powers = 10*log10(abs(S(ndx,:)) + .02);
if(isempty(ud.cLimits))
    img = imagesc(times,freqs,powers); axis xy;
else
    img = imagesc(times,freqs,powers, ud.cLimits); axis xy;
end
if ~holdState %Restore hold state at call
    hold(ud.ax, 'off');
end
if numel(times) > 1
    xlim(ud.ax, [times(1), times(end)]);
else
    xlim(ud.ax, [times(1)-eps, times(end)+eps]);
end
ylim(ud.ax, [freqs(1), freqs(end)]);
axis xy;
if verLessThan('matlab','8.4.0')
    cmapCache = colormap();
    colormap(ud.ax, ud.cMap);
    freezeColors(ud.ax);%Stop colormap from interacting with others
    colormap(ud.ax, cmapCache);
else
    colormap(ud.ax, ud.cMap);
end

set(img,'HitTest', 'off');
set(ud.ax,'children',flipud(get(ud.ax,'children')));%Reorder plots on this axis to place the spectrogram on the bottom (won't cover up other plots)
ud.hIm = img;
set(ud.ax,'Units','normalized')
ud.xlh = addlistener(ud.ax, 'XLim', 'PostSet', @(src, evnt) xlim_updatedspecgram(ud.ax));
set(ud.ax, 'UserData', ud);
set(ud.ax, 'ButtonDownFcn', @buttondown_updatedspecgram);
axes(axCache);%Restore axis focus at call time
set(ud.hFig, 'ResizeFcn', rszFn);%Restore resize function now that we're clear of callback loops
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xlim_updatedspecgram(hAx)
ud = get(hAx, 'UserData');
axes(ud.ax);
xbnds = xlim(ud.ax);
p1 = xbnds(1);              % extract x and y
p2 = xbnds(2);
p1 = min(p1,p2);             % calculate locations
ud.startndx = max(round((p1 - ud.startTime)*ud.Fs + 1),1);
ud.endndx = min(round((p2 - ud.startTime)*ud.Fs + 1),length(ud.signal));
set(ud.ax,'UserData',ud);
helper_updatedspecgram(ud);
end

function buttondown_updatedspecgram(src, evnt)
ud = get(src, 'UserData');
axes(ud.ax);
mouseMode = get(gcf, 'SelectionType');
clickLocation = get(ud.ax, 'CurrentPoint');
if(strcmp(mouseMode, 'alt'))
    rbbox();
    endPoint = get(gca,'CurrentPoint');
    point1 = clickLocation(1,1:2);              % extract x and y
    point2 = endPoint(1,1:2);
    shiftTime = point1(1) - point2(1);
    shiftNdx = round((shiftTime * ud.Fs) + 1);
    shiftNdx = shiftNdx - max(0, ud.endndx + shiftNdx - length(ud.signal));
    shiftNdx = shiftNdx - min(0, ud.startndx + shiftNdx -1);
    ud.startndx = ud.startndx + shiftNdx;
    ud.endndx = ud.endndx + shiftNdx;
elseif(strcmp(mouseMode, 'open') || strcmp(mouseMode, 'extend'))
    %double click to zoom out
    ud.startndx = 1;
    ud.endndx = length(ud.signal);
elseif(strcmp(mouseMode, 'normal'))
    %left click to zoom in.
    rbbox();
    endPoint = get(gca,'CurrentPoint');
    point1 = clickLocation(1,1:2);              % extract x and y
    point2 = endPoint(1,1:2);
    p1 = min(point1,point2);             % calculate locations
    offset = abs(point1-point2);         % and dimensions
    if(offset(1)/diff(xlim) < .001) %Very small selection
        quarter = round((ud.endndx - ud.startndx) / 4);
        midndx = round((p1(1) - ud.startTime)*ud.Fs + 1);
        ud.startndx = max(1,midndx - quarter);
        ud.endndx = min(length(ud.signal), midndx + quarter);
    else
        fprintf('mouse click1 : %.4f, click2: %.4f \n', point1, point2);
        fprintf('x offset %.4f \n', offset(1));
        ud.startndx = max(round((p1(1) - ud.startTime)*ud.Fs + 1),1);
        ud.endndx = min(round((p1(1) + offset(1) - ud.startTime)*ud.Fs + 1),length(ud.signal));
    end
end
set(ud.ax,'UserData',ud);
helper_updatedspecgram(ud);
end


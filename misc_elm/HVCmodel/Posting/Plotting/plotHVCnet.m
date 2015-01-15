function plotHVCnet(w, xdyn, m, trainingNeurons, PlottingParams)
% Makes network diagram for alternating differentiation
% w: weight matrix
% xdyn: activity of network
% m: duration of one syllable, in timesteps
% trainingNeurons: cell array of structures containing neuron and time indices for each training neuron type
% PlottingParams: sets linewidth, etc. 
%
% Emily Mackevicius 1/14/2015, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo.

msize = PlottingParams.msize;
linewidth = PlottingParams.linewidth;
Syl1Color = PlottingParams.Syl1Color;
Syl2Color = PlottingParams.Syl2Color;
ProtoSylColor = PlottingParams.ProtoSylColor;

Latency = findLatency(xdyn, trainingNeurons);

% first exclude all neurons that don't fire at a consistent phase
cla; hold on
x = zeros(1,size(w,1));
y = zeros(1,size(w,1));
for ni = 1:size(w,1)
    if Latency{1}.FireDur(ni)|Latency{2}.FireDur(ni) % if it fired during either syll
        if (Latency{1}.FireDur(ni)&Latency{2}.FireDur(ni)) % if it fired during both sylls
            if (Latency{1}.mode(ni)==Latency{2}.mode(ni)) % if fired during both sylls at same phase
                x(ni) = Latency{1}.mode(ni);
            else % exclude from plot if different phases for both sylls
                x(ni) = NaN;
            end
        elseif Latency{1}.FireDur(ni) % if it fired during syll 1 
            x(ni) = Latency{1}.mode(ni);
        else % fired during syll 2 only
            x(ni) = Latency{2}.mode(ni);
        end
    else % if it fired during neither syll
        x(ni) = NaN;
    end
end
indkeep = ~isnan(x); 
y = y(indkeep); 
w = w(indkeep,indkeep); 
xdyn = xdyn(indkeep,:); 
x = x(indkeep); 
ux = unique(x); 

% keep track of training neuron and syl time indices
trainingset1 = trainingNeurons{1}.nIDs;
trainingset2 = trainingNeurons{2}.nIDs; 
x(trainingset1) = 1; 
x(trainingset2) = 1; 
tind1 = find(trainingNeurons{1}.tind);
tind2 = find(trainingNeurons{2}.tind);

% keep track of which neurons participated in each syllable
FireDur1 = Latency{1}.FireDur(indkeep); 
FireDur2= Latency{2}.FireDur(indkeep); 

% classify neurons as specific or shared
Specific1 = FireDur1&~FireDur2;
Specific2 = FireDur2&~FireDur1; 
Shared = (FireDur1&FireDur2); 
indshared = find(Shared);

% calculate the incoming weights from specific neurons of each type, to
% determine sorting in y axis and color
c1 = zeros(1,length(x));
c2 = zeros(1,length(x));
for ni = 1:size(w,1)
    tmp = find(xdyn(ni,:)); 
    if sum(w(ni,:))>0
        c1(ni) = sum(w(ni,Specific1))/sum(w(ni,:));
        c2(ni) = sum(w(ni,Specific2))/sum(w(ni,:));
    end
    y(ni) = c1(ni)-c2(ni);
end

% for each latency (x), sort along y, with small gap between shared and
% specific neurons
y1 = zeros(1,size(w,1)); 
for ui = 1:length(ux)
    indshared = (x==ux(ui))&Shared;
    ind1 = (x==ux(ui))&Specific1; 
    ind2 = (x==ux(ui))&Specific2;
    [~,y1(indshared)] = sort(y(indshared));
    tocentershared = 1+(numel(find(indshared))-1)/2;
    y1(indshared) = y1(indshared)-tocentershared;
    [~,y1(ind1)] = sort(y(ind1));
    y1(ind1) = y1(ind1) + (numel(find(indshared)))/2;
    [~,y1(ind2)] = sort(y(ind2));
    y1(ind2) = y1(ind2) -numel(find(ind2))-1- (numel(find(indshared)))/2;
end

cla; hold on
%%
% keep only feedforward part of weight matrix
wplot = w; 
n = size(wplot,1); 
for i = 1:n
    for j = 1:n
        ff = x(i)<x(j);
        longrange = abs(x(i)-x(j))>2; 
        if (~ff) | longrange
            wplot(j,i) = 0; 
        end
    end
end

% Color weights white to black between wplotmin and wplotmax
%wplot = w; 
wplot = wplot-PlottingParams.wplotmin; 
wplot(wplot<0) = 0;
wplot = wplot/(PlottingParams.wplotmax-PlottingParams.wplotmin);
wplot(wplot<prctile(wplot(:), PlottingParams.wprctile)) = 0; 
wplotold = wplot; 
n = size(wplot,1); 
for i = 1:n
    [~,ind] = sort(wplot(:,i), 'descend'); 
    indplot = zeros(n,1); 
    indplot(ind(1:min(PlottingParams.wperneuron,length(ind)))) = 1;   
    wplot(~indplot,i) = 0; 
end
for i = 1:n 
    if sum(wplot(i,:)>0)<PlottingParams.wperneuronIn
        [~,ind] = sort(wplotold(i,:), 'descend'); 
        wplot(i,ind(1:min(PlottingParams.wperneuron,length(ind)))) = wplotold(i,ind(1:min(PlottingParams.wperneuron,length(ind))));
    end
end
% wplot = wplot/max(wplot(:)); 

% jitter a little in x and y, so it doesn't look like a grid
jitter = .1; 
% fixed seed for plotting jitter, so it doesn't interact with seed for
% running network (Seed0 = randn(1,300);)
Seed0 = [0.787227342873926,0.582020317127063,0.609451156625749,0.606716952986031,0.636033998929646,-0.180677935561397,-0.528598940098242,0.0527792389000901,0.625259801148290,-1.29401656967592,-1.38214101671354,-0.527020492640055,1.88949789173520,-1.66460403857905,0.392441321047685,-0.185100420988186,-0.0491105945890874,0.676594027804329,-0.892907848970331,-0.107433700471497,-0.567072027878358,0.109206763669442,0.165781722351181,0.409057024885786,0.774776349292590,-0.895378738580725,0.537342583913690,0.370467006121032,0.719497656309941,0.528151370224869,-1.10167573694434,-0.561936874999666,-1.18494410656232,-1.48226343339092,0.924435867255282,0.457772049704195,0.722443800208248,-0.780439344094326,1.33109650351398,-0.128163306487074,1.44007898863166,-0.775776079110923,1.46585351198940,-0.815656797877283,-0.580978019305495,-0.322715100345543,0.387115072103298,1.50687828877152,-0.653479685798222,0.525578517305029,-0.224345150666085,0.546742204142798,-0.0449331184183505,1.22925908998109,0.665630760132672,-0.743727465517391,-0.131670176806624,-0.314703221002156,-0.501532971918642,0.707484810035259,-0.383167367508713,-0.444485992885313,1.07575694223181,-0.500994017953851,-0.573729221275665,0.468006127596914,1.27746274826588,-0.226621603287908,1.04526740305244,-0.235219083997117,-0.202663681744057,-0.0976508378110226,0.652110555659137,-0.406454869798839,0.817275457980248,1.39619639207451,1.04798981354096,-1.09028993418959,2.37432607827585,-2.33807826874712,-0.884118147218346,0.225926069697654,1.01437191039869,-0.282789422137885,1.28335550268037,-2.22299884205250,0.251037379397618,-0.0319382738213859,-2.31778346062632,-0.138859063584631,0.153610383632614,2.13259742778756,-0.850247201040447,-0.936958877411799,0.832488411497530,0.320270667585895,0.495689125654322,-0.418014267172913,1.44611060269629,1.49755880098486,0.799222567412105,-1.09093293777289,2.22876926927426,-1.57915675197872,0.0512228335621377,0.425047238953383,-1.14087756627568,2.01994638451377,-0.247182124362878,-1.30507996322016,0.485779972147726,0.691546151729402,-0.577310935029243,-0.664179695881542,-0.611807186999427,0.653873257011614,1.18087533804512,-0.0671005647363848,-1.39767521769405,0.857159406350474,0.723909263699562,0.652207811533946,-2.57519325660479,-0.470715336250203,0.232693213530116,-0.905005244747429,0.935322950593016,0.740083790666141,0.464332995576203,-0.199351251118719,0.0118456380476624,0.537035607863629,-0.0550238908166535,0.790444023701938,-0.674048107472408,-1.03291427322399,-1.37092399647562,0.312202104291431,-0.313258661446583,0.515320583670777,0.295217425503368,1.70024729058588,1.38543562616153,-0.271237772754076,-0.521570692021585,-1.62312895689050,1.65130302978555,-0.314297549536972,-0.0996811225823316,-0.0698408895905527,-0.185097577125899,-1.26448113342300,0.0837178944474668,1.51106029873843,0.621383331884015,-1.20184089197598,-1.37197504090090,-2.52792227679227,0.313904763851149,-0.187941471217405,-0.0922643729897364,-0.823283457434690,0.897277967393770,1.22959970698861,0.193686738913393,1.34230450948986,0.473399320602648,-0.368751408058405,-0.713937895164327,-0.630301507393117,0.224971119389846,-0.642741628567258,1.51074526945378,-1.71446984619675,-1.94469896424780,0.650061432634882,0.762082298977728,0.293287215298717,1.89115779976656,1.90006083886865,0.789387220390268,0.0320195180060890,1.13966296070105,-0.0522778648965224,0.0647112329001591,-0.0505115559722169,0.558965204596858,-0.778912335398709,-0.397257352701195,1.04941353653532,-0.776450432050183,-0.209780639145976,-0.481553590153523,0.565261415520321,0.300529849573453,-1.61868509567113,-1.77133200775913,1.04635150162447,0.180294092470067,-0.625710047037258,-0.159173717981469,-0.872400852275364,0.908534545448914,-0.443116065578627,-0.0619066325204393,0.731466232195416,0.846502752688978,-0.582900935422468,-0.730830937950119,-0.102352101726490,-0.929267237473749,-0.884513186752139,2.09431934268283,-0.272528670959468,-0.948460205960554,-0.672493237646287,-0.0915650645779812,-2.45274309171764,1.14865196985871,0.569234062926912,0.953153758399660,-0.191202025087393,1.48905407626348,-1.19615033686194,0.699220990931759,0.223488853944770,-1.43799140637017,-0.479948082793021,-0.585803853063381,0.393828527041560,-0.0596700887277437,-0.964124292998487,-0.647773058311208,0.614906382407182,-0.754845965587004,-0.683115321644919,0.0701327821338252,1.30612093702267,-0.398714734670494,-1.35408449756808,0.537482769019812,-0.247180165082439,-1.37947620508263,-1.66550447499220,-0.0227517341220266,1.17742124892974,-1.25706881982197,0.763564496963918,0.254258623494365,-0.00350860776966252,-1.05846873611944,-1.97605154261224,-0.284409648239202,1.17713841398511,-1.43782930798421,0.181488852157821,0.198351139166652,1.00181785550635,-0.532668875318506,1.27823086558483,-0.261290858116610,1.54052648933189,-0.289908206951020,0.657286081335124,-1.21273485864092,-0.678831702872453,-0.0404071660561130,0.0628865607203705,1.73217732025661,-2.00914146911656,-1.54415209247912,-0.185023883667805,1.12654142600838,0.938763089693390,0.865709911033973,0.355246100898934,-2.05022147461973,-0.707250211978576,-0.644071764111564,0.148298666914450,-0.128984026938764,1.65722358445806,-0.657317037888850,-1.80247407321684,-0.703157964710770,-0.749877193371465,0.976444986133920,0.0180590859305232,-2.27651735315054,0.113843065565426,0.487083411921801,-0.430230646595828,0.200719186159448,2.24506273760118,-0.826528852638568,0.476911382495761,2.48443982130249,-0.266553046760370,-1.21612815158640,0.903785909480337];
x = x+jitter*Seed0(1:length(x));
y1 = y1+jitter*Seed0((length(x)+1):(2*length(x))); 

% plot w in order from weakest to strongest, so darker lines are on top

js = repmat((1:n)',1,n); 
is = repmat((1:n),n,1); 
isVec = is(:);
jsVec = js(:); 
wVec = wplot(:); 
[wSort,indSort] = sort(wVec, 'ascend'); 
nplotted = zeros(1,n); 
for k = 1:length(wSort)
    i = isVec(indSort(k)); 
    j = jsVec(indSort(k)); 
    if wplot(j,i)>0
        ff = x(i)<=x(j); 
        longrange = abs(x(i)-x(j))>2; 
        loopback = (round(x(i))==round(max(x)))&(round(x(j))==round(min(x)));
        if (ff & ~longrange)%|loopback
            C = ones(1,3)-wplot(j,i)*ones(1,3);
            plot([x(i), x(j)], [y1(i),y1(j)], 'color', C, 'linewidth', linewidth)
        end
    end
end

% color each neuron based on its relative input from each syllable type
for pli = 1:length(x)
    tmpC = c1(pli)'/(max(c1)+eps)*Syl1Color+c2(pli)'/(max(c2)+eps)*Syl2Color; 
    tmpC = tmpC/(max(tmpC)+eps); % normalize so colors are bright
    if Shared(pli)
        tmpC = zeros(1,3); 
    end
    if Specific1(pli)
        tmpC = Syl1Color; 
    end
    if Specific2(pli)
        tmpC = Syl2Color; 
    end
    plot(x(pli),y1(pli), 'marker', '.', 'color', tmpC, 'markersize', msize)
end

% plot training neurons in given colors
if sum(Specific1)>0
    plot(x(trainingset1),y1(trainingset1), '.', 'markersize', msize, 'color', Syl1Color)
    plot(x(trainingset2),y1(trainingset2), '.', 'markersize', msize, 'color', Syl2Color)
else
    plot(x([trainingset1 trainingset2]),y1([trainingset1 trainingset2]), '.', 'markersize', msize, 'color', ProtoSylColor)
end


axis tight; axis off; 
xlim([-.5 m+.5]);
ylim([min(y1)-1 max(y1)+1])
set(gca, 'color', 'none')
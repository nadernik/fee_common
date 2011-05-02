%% 2011-03-08

annotate_exper('white342', '2010-12-11')
annotate_exper('white342', '2010-12-12')
annotate_exper('white342', '2010-12-14')
annotate_exper('white342', '2010-12-15')
annotate_exper('white342', '2010-12-16')
annotate_exper('white342', '2010-12-17')

%% 2011-03-09

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 4.5e-3;
Drug.TimeIn        = datenum([2010 12 11 12 00 00]);
Drug.TimeOut       = datenum([2010 12 11 22 51 00]); 
annodrugs('white342', '2010-12-11', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0.01;
Drug.TimeIn        = datenum([2010 12 12 14 25 00]);
Drug.TimeOut       = Inf; 
annodrugs('white342', '2010-12-12', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 2.25e-3;
Drug.TimeIn        = datenum([2010 12 13 13 50 00]);
Drug.TimeOut       = datenum([2010 12 13 22 24 00]); 
annodrugs('white342', '2010-12-13', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 3.38e-3;
Drug.TimeIn        = datenum([2010 12 16 17 17 00]);
Drug.TimeOut       = datenum([2010 12 17 00 21 00]); 
annodrugs('white342', '2010-12-16', Drug)

expernames = {'2010-12-11', '2010-12-12', '2010-12-13', '2010-12-14', ...
    '2010-12-15', '2010-12-16', '2010-12-17'};
[conc, N] = singingwithdrugs('white342', expernames, 19, 22);
scatter(conc, N)

N = singingwithdrugs2('white342', expernames);
plot(N)
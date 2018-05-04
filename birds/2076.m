%% 2011-03-08

annotate_exper('2076', '2011-01-17')
annotate_exper('2076', '2011-01-18')
annotate_exper('2076', '2011-01-20')
annotate_exper('2076', '2011-01-21')
annotate_exper('2076', '2011-01-22')
annotate_exper('2076', '2011-01-23')
annotate_exper('2076', '2011-01-24')
annotate_exper('2076', '2011-01-25')
annotate_exper('2076', '2011-01-26')
annotate_exper('2076', '2011-01-27')

%% 2011-03-09
Drug.Name          = 'CNQX + APV';
Drug.Concentration = 4.5e-3;
Drug.TimeIn        = datenum([2011 01 18 15 45 00]);
Drug.TimeOut       = datenum([2011 01 18 23 45 00]); 
annodrugs('2076', '2011-01-18', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 1.13e-3;
Drug.TimeIn        = datenum([2011 01 19 15 30 00]);
Drug.TimeOut       = datenum([2011 01 20 00 30 00]); 
annodrugs('2076', '2011-01-19b', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 3.38e-3;
Drug.TimeIn        = datenum([2011 01 20 14 15 00]);
Drug.TimeOut       = datenum([2011 01 21 01 20 00]); 
annodrugs('2076', '2011-01-20', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 2.25e-3;
Drug.TimeIn        = datenum([2011 01 21 12 00 00]);
Drug.TimeOut       = Inf; 
annodrugs('2076', '2011-01-21', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 4.5e-3;
Drug.TimeIn        = datenum([2011 01 22 12 40 00]);
Drug.TimeOut       = datenum([2011 01 22 20 50 00]); 
annodrugs('2076', '2011-01-22', Drug)

Drug.Name          = 'PBS'; % actually water, but bird was handled
Drug.Concentration = 0;
Drug.TimeIn        = datenum([2011 01 23 13 18 00]);
Drug.TimeOut       = Inf; 
annodrugs('2076', '2011-01-23', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 3.38e-3;
Drug.TimeIn        = -Inf;
Drug.TimeOut       = datenum([2011 01 24 23 55 00]); 
annodrugs('2076', '2011-01-24', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0;
Drug.TimeIn        = datenum([2011 01 25 13 39 00]);
Drug.TimeOut       = datenum([2011 01 25 22 10 00]); 
annodrugs('2076', '2011-01-25', Drug)

Drug.Name          = 'PBS';
Drug.Concentration = 0;
Drug.TimeIn        = datenum([2011 01 26 13 00 00]);
Drug.TimeOut       = Inf; 
annodrugs('2076', '2011-01-26', Drug)

expernames = {'2011-01-18', '2011-01-19b', '2011-01-20', '2011-01-21', '2011-01-22', '2011-01-23', '2011-01-24', '2011-01-25', '2011-01-26'} ;
N = singingwithdrugs2('2076', expernames)
figure
hold on
c = [0 0 0; 1 .75 .75; 1 .5 .5; 1 .25 .25; 1 0 0];
for ii = 1:5
    plot(N(1:end-1, ii),'Color',c(ii,:), 'LineWidth', 3)
end
xlabel('Hours after drug infusion')
ylabel('Files recorded')
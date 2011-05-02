Drug.Name          = 'CNQX + APV';
Drug.Concentration = 2.25e-3;
Drug.TimeIn        = datenum([2010 12 13 13 38 00]);
Drug.TimeOut       = datenum([2010 12 13 22 14 00]);
annodrugs('white343', '2010-12-13', Drug)

Drug.Name          = 'CNQX + APV';
Drug.Concentration = 3e-3;
Drug.TimeIn        = datenum([2010 12 16 18 05 00]);
Drug.TimeOut       = Inf;
annodrugs('white343', '2010-12-16', Drug)
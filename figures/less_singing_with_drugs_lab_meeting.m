% figure for lab meeting

%% mes003
expernames = {};
for d = datenum('2/19/2011'):datenum('2/26/2011')
    expernames{end+1} = datestr(d, 'yyyy-mm-dd');
end
expernames{end+1} = '2011-03-02';
expernames{end+1} = '2011-03-03';
% expernames{end+1} = '2011-03-04';
[N, days] = singingwithdrugs2('mes003', expernames);
N = sum(N);
N = N ./ N(1);

%% 2089
expernames = {};
for d = datenum('2/15/2011'):datenum('3/3/2011')
    expernames{end+1} = datestr(d, 'yyyy-mm-dd');
end
[newN, newdays] = singingwithdrugs2('2089', expernames);
newN = sum(newN);
newN = newN ./ newN(1);
N = N .* days ./ (days + newdays) + newN .* newdays ./ (days + newdays);
days = days + newdays;

%% 2076
expernames = {'2011-01-18', '2011-01-19b', '2011-01-20', '2011-01-21', '2011-01-22', '2011-01-23', '2011-01-24', '2011-01-25', '2011-01-26'} ;
[newN, newdays] = singingwithdrugs2('2076', expernames);
newN = sum(newN);
newN = newN ./ newN(1);
N = N .* days ./ (days + newdays) + newN .* newdays ./ (days + newdays);
days = days + newdays;

%%
bar(N)
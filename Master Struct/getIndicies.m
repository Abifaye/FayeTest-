function [indicies] = getIndicies(trials);
% Written by Faye 220928
% This function fetches the trial outcomes from session data "trials"
% makes a struct called indicies
% indices.hits
% indicies.miss
% indicies.fa
% return indicies
% look up how to initialize a struct with field names in place  
field1 = 'hits'
value1 = [trials.trialEnd] == 0
field2 = 'miss'
value2 = [trials.trialEnd] == 2
field3 = 'fa'
value3 = [trials.trialEnd] == 1
indicies = struct(field1,value1,field2,value2,field3,value3)

end


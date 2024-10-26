function [aveC] = getAveC(T);

%Get average criterion
stimC = [T.stimC];
unStimC = [T.noStimC];
aveC = (stimC + unStimC)/2;

end
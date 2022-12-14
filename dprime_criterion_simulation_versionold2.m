
%% d' and criterion simulation
hits = [trials.trialEnd]==0;
FA = [trials.trialEnd]==1;
miss = [trials.trialEnd]==2;
visualStim30 = floor([trials.visualStimValue])==30;
meanPowerPresent = [trials.meanPowerMW]~=0;

%Draw a random number from a normal distribution of signal with m = 3 s = 1
NDsignal_rnd = normrnd(10,1)

%Draw a random number from a normal distribution of noise with m = 3 s =1
NDnoise_rnd = normrnd(3,1)

%state criterion
c = 0.5

%index into the variable that created random numbers for numbers that are
%greater than the criterion and set it to equal hits
randomdraw = zeros(1,20)
for i = 1:10
    NDsignal_rnd(i)
    if NDsignal_rnd(i)> c
        randomdraw = 'hit'
    else
        continue
    end
end


    

    






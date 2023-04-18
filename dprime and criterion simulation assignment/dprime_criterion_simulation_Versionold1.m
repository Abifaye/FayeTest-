
%% d' and criterion simulation
%Draw a random number from a normal distribution of signal with m = 3 s = 1
NDsignal_rnd = normrnd(10,1)

%Draw a random number from a normal distribution of noise with m = 3 s =1
NDnoise_rnd = normrnd(3,1)

%state criterion
c = 7

%create for loop for 10 trials  so that when random value drawn from noise
%and signal distribution are greater than criterion, it is a hit
NDsignal_rnd(NDsignal_rnd>7) = 'hit'
NDsignal_rnd(NDsignal_rnd<7) = 'miss'
NDnoise_rnd(NDnoise_rnd>7) = 'fa'
NDnoise_rnd(NDnoise_rnd<7) = 'correct rejection'


%% coding thoughts for actual trials on a specific visual stim value
hits = [trials.trialEnd]==0;
FA = [trials.trialEnd]==1;
miss = [trials.trialEnd]==2;
visualStim30 = floor([trials.visualStimValue])==30;
meanPowerPresent = [trials.meanPowerMW]~=0;
%create a distribution for signal (hits) and set mean to be different from
%FA
hits_doubles = double(hits & ~visualStim30 & ~meanPowerPresent)
NDhits = fitdist(hits_30(:),'normal')
%create a distribution for noise (FA) and set mean to be different from
%hits
FA_doubles = double(FA)
NDfa = fitdist(FA_doubles(:),'normal')
%set a criterion

%create a for loop for assigning hits, misses, and FAs based on criterion

random(NDhits)%pulls random value from distribution of hits
random (NDfa)%pulls random value from distribution of fa



    

    






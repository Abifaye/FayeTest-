dprimes = [0, 1, 2]
cs = [0, 1, 2]

masterOutcomes

for dprimes
    for cs
    outcomes = simulationfnc(dprimes(i), c(j), catch trial, trialsToSim)
    end
    output to outcomes to masterOutcomes 
end

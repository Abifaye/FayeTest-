%%Project
clear all; %Emptying workspace
close all; %closing all figures
temp = uint8(zeros(400,400,3)); %create a dark stimulus matrix
temp1 = cell(10,1); %Create a cell that can hold 10 matirces
for i = 1:10 %temp1
    temp(200,200,:) = 255 %Inserting a fixation point
    temp(200,240,:) = (i-1)*10; %Inserting a test point 40 pixels righ of it. Brightness range from 0 - 90.
    temp1{i} = temp; %Putting the respective modified matrix in cell 
end %Done doing that
h = figure %creating a figure with a handle h
stimulusorder = randperm(200); %Creating a random order from 1 to 200. For the 200 trials. Allows to have a precisely equal number per condition.
stimulusorder = mod(stimulusorder,10); %Using the modulus function to create a range from 0 to 9. 20 each.
stimulusorder = stimulusorder + 1; %Now, the range is from 1 to 10, as desired
score = zeros(10,1); %Keeping score. How many stimuli were reported seen
for i = 1:200 %200 trials, 20 per condition 
    image(temp1{stimulusorder(1,i)})%Image the respective matrix. As designated by stimulusorder
   i %Give subject feedback about which trial we are in. No other feedback
    pause; %Get the keypress
    temp2 = get(h, 'CurrentCharacter'); %Get the keypress "." for present, "," for absent
    temp3 = strcmp('.',temp2); %Compare strings. If . (present), temp3 = 1, otherwise 0
    score(stimulusorder(1,i)) = score(stimulusorder(1,i)) + temp3; %ADd up. In the respective score sheet
end %End the presentation of trials after 200 have lapsed

    
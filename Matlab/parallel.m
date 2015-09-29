tic; clear; clc; close all

no_of_iterations = 1;

parfor i = 1:no_of_iterations
    main();
end

toc;

%% HOW TO USE:
%Before using the script, you need to enable the parallel process toolbox.
%This can be done by running the command 'parpool'. There is no need to
%reactivate the parallel pool after each simulation (Unless you haven't
%used it in a while, in which case it goes on idle.

%Enter the number of iterations, and inside the parfor loop add your main
%function. Nothing else.

%PS: IF YOU WANT TO EVALUATE DIFFERENT FILES, use if statements to
%determine at which iteration the new file is going to start processing.
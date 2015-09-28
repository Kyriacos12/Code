tic; clear; clc; close all
%% Define the path where files are located
mydir = 'C:\Kyriacos\Matlab';                              %   Set Directoty
%% Settings
no_feeders = 6
no_customers = 351
no_customers_per_feeder = [49 21 30 100 68 83]

t_day = 1
t_month = 1
network = 'Landgate'

%% ********************************************************************************************************
%                                        Initialize OpenDSS
% *********************************************************************************************************
% [DSSStartOK, DSSObj, DSSText] = dss_startup(mydir);
% if ~DSSStartOK
%     disp('Unable to start the OpenDSS Engine')
%     return
% end    
% DSSText = DSSObj.Text;                                                      %   Set up the Text
% DSSText.Command = 'clear';                                                  %   Clear text command
% DSSText.Command = ...
%     sprintf('Compile (%s%sNetworks\Landgate\Main.dss)',mydir,'\');
% DSSCircuit = DSSObj.ActiveCircuit;                                          %   Set up the Circuit
% DSSSolution = DSSCircuit.Solution;                                          %   Set up the Solution
% ControlQueue = DSSCircuit.CtrlQueue;                                        %   Set up the Control
% DSSObj.AllowForms = 0;                                                      %   no "solution progress" window
% 
% DSSText.Command = 'Set ControlMode = time';
% DSSText.Command = 'Reset';                                                  %    resetting all energy meters and monitors
% DSSText.Command = ['Set Mode = daily stepsize = 1m number = 1'];

assign_house_profiles(mydir, DSSText, t_month, t_day, network, no_feeders, ...
    no_customers_per_feeder)


tic; clear; clc; close all
%% User Input
t_day = 1;
t_month = 1;
network = 'Landgate';

iteration = 10; %to be changed

%% Obtain settings
[no_customers, no_feeders, customers_per_feeder, mydir] = setup(network);

%% ********************************************************************************************************
%                                       Initialize OpenDSS
%*********************************************************************************************************
[DSSStartOK, DSSObj, DSSText] = dss_startup(mydir);
if ~DSSStartOK
    disp('Unable to start the OpenDSS Engine')
    return
end    
DSSText = DSSObj.Text;                                                      %   Set up the Text
DSSText.Command = 'clear';                                                  %   Clear text command
DSSText.Command = ...
    sprintf('Compile (%s\\Input\\Networks\\%s\\Main.dss)',mydir,network);
DSSCircuit = DSSObj.ActiveCircuit;                                          %   Set up the Circuit
DSSSolution = DSSCircuit.Solution;                                          %   Set up the Solution
ControlQueue = DSSCircuit.CtrlQueue;                                        %   Set up the Control
DSSObj.AllowForms = 0;                                                      %   no "solution progress" window

DSSText.Command = 'Set ControlMode = time';
DSSText.Command = 'Reset';                                                  %    resetting all energy meters and monitors
DSSText.Command = ['Set Mode = daily stepsize = 1m number = 1'];

%% Setup the Network

net_function = str2func(network);               
net_function(DSSText, mydir, iteration, 'init');


assign_house_profiles(mydir, DSSText, t_month, t_day, network, no_feeders, ...
     customers_per_feeder);
 
 
net_function(DSSText, mydir, iteration, 'export_monitors');


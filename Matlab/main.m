function main
    tic; clear; clc; close all
    global d;
    d = containers.Map;
    
    %% Network Settings
    %General Settings
    d('t_day') = 1;
    d('month') = 1;
    d('network') = 'Landgate';
    
    %PV Settings
    d('pv_penetration') = 0.90; %Percentage

    %% Obtain settings
    setup();
    assign_pv();    
    %% ********************************************************************************************************
    %                                       Initialize OpenDSS
    %*********************************************************************************************************
    DSSStartOK = dss_startup();
    if ~DSSStartOK
        disp('Unable to start the OpenDSS Engine')
        return
    end
    DSSObj = d('DSSObj');
    DSSText = DSSObj.Text;%   Set up the Text
    d('DSSText') = DSSText;
    DSSText.Command = 'clear';                                                  %   Clear text command
    DSSText.Command = ...
        sprintf('Compile (%s\\Input\\Networks\\%s\\Main.dss)',...
        d('mydir'),d('network'));
    DSSCircuit = DSSObj.ActiveCircuit;                                          %   Set up the Circuit
    DSSSolution = DSSCircuit.Solution;                                          %   Set up the Solution
    ControlQueue = DSSCircuit.CtrlQueue;                                        %   Set up the Control
    DSSObj.AllowForms = 1;                                                      %   no "solution progress" window

    DSSText.Command = 'Set ControlMode=time';
    DSSText.Command = 'Reset';                                                  %    resetting all energy meters and monitors
    DSSText.Command = ['Set Mode=daily stepsize=1m number=1'];

    %% Setup the Network
    net_function = str2func(d('network'));               
    net_function('init');
    assign_house_profiles();
    
    %% Run the Simulation
    for i = 1:1440
        DSSSolution.Solve;
    end
    
    %% Post-Simulation
    net_function('export_monitors');
end

    tic; clear; clc; close all
    global d;
    d = containers.Map;
    
    %% Network Settings
    %General Settings
    d('t_day') = 1;
    d('month') = 6;
    d('network') = 'Landgate';
    
    %PV Settings
    d('pv_penetration') = 1; %Percentage

    %% Obtain settings
    setup();
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
    %net_function = str2func(d('network'));               
    %net_function('init');
    %assign_house_profiles();
    %assign_pv();
    net_name = feval(d('network'));                                             %Assign which class to instantiate
    net_class = net_name;                                                       %Instantiate the class
    net_class.init;                                                             %Run the init function
    
    profiles = assign_profiles;
    profiles.house;
    profiles.pv;
   
    %% Run the Simulation
    DSSCircuit.SetActiveElement('storage.battery1');
    for i = 1:1440
        DSSSolution.Solve;
        
        
        if i == 500
            for j = 1:351
                chargerate = sprintf('Storage.battery1.kWrated=%u', i-500);
                DSSCircuit.CktElements(sprintf('storage.battery%u',j)).Properties('State').Val = 'CHARGING';
                DSSCircuit.CktElements(sprintf('storage.battery%u',j)).Properties('kWrated').Val = '2';
            end
        end
        
        
        DSSCircuit.SetActiveElement('transformer.TR1');
        whatever = DSSCircuit.ActiveElement.Powers;
        whatever2(i,1) = whatever(1)+whatever(3)+whatever(5);
        DSSCircuit.SetActiveElement('generator.pv1');
        whatever = DSSCircuit.ActiveElement.Powers;
        whatever2(i,2) = whatever(1);%+whatever(3)+whatever(5);
        %whatever2(i,2) = whatever(2)+whatever(4)+whatever(6);
    end
    plot(whatever2);
    %% Post-Simulation
    %net_function('export_monitors');
    net_class.export_monitors
    toc;
    
%% What to add next:
% 1) Need to add an identifier to which house the PV is connected (need
% this to change the loadshape of the storage to 'night' mode.

% 2) see what I can do about optimisation based on tarrifs. 


%% Start of the Software
    tic; clear; clc; close all
    global d;
    d = containers.Map;
    
    %% Network Settings
    %General Settings
    d('t_day') = 1;
    d('month') = 2;
    d('network') = 'Landgate';
    
    %PV Settings
    d('pv_penetration') = 0.2; %Percentage
    sunlight(:,1) = [507;462;394;380;318;289;306;353;407;462;460;506];
    sunlight(:,2)=[973;1028;1086;1202;1256;1292;1286;1237;1165;1090;970;944];
    d('sunlight') = sunlight;

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
    store = manage_storage;
   
    %% Run the Simulation
    DSSCircuit.SetActiveElement('storage.battery1');
    for i = 1:1440
        store.iteration_management(i);
        
        DSSSolution.Solve;
                
%         if i == 1000  
%                 DSSCircuit.CktElements('storage.battery1').Properties('daily').Val = 'Houseload1';
%                 DSSCircuit.CktElements('storage.battery1').Properties('kWhstored').Val
%                                 DSSCircuit.CktElements('storage.battery2').Properties('daily').Val = 'Houseload1';
%                 DSSCircuit.CktElements('storage.battery1').Properties('kWhstored').Val
%                                 DSSCircuit.CktElements('storage.battery3').Properties('daily').Val = 'Houseload1';
%                 DSSCircuit.CktElements('storage.battery1').Properties('kWhstored').Val
%                                 DSSCircuit.CktElements('storage.battery4').Properties('daily').Val = 'Houseload1';
%                 DSSCircuit.CktElements('storage.battery1').Properties('kWhstored').Val
%         end
        
        
        DSSCircuit.SetActiveElement('transformer.TR1');
        lele = DSSCircuit.ActiveElement.Powers;
        lele2(i)= lele(1)+lele(3)+lele(5);
        
        DSSCircuit.SetActiveElement('storage.battery2');
        whatever = DSSCircuit.ActiveElement.Powers;
        whatever2(i,1) = whatever(1);%+whatever(3)+whatever(5);
        DSSCircuit.SetActiveElement('load.house2');
        whatever = DSSCircuit.ActiveElement.Powers;
        whatever2(i,2) = whatever(1);%+whatever(3)+whatever(5);
        DSSCircuit.SetActiveElement('generator.PV2');
        whatever = DSSCircuit.ActiveElement.Powers;
        whatever2(i,3) = -whatever(1);%+whatever(3)+whatever(5);
%         DSSCircuit.SetActiveElement('storage.battery4');
%         whatever = DSSCircuit.ActiveElement.Powers;
%         whatever2(i,4) = whatever(1);%+whatever(3)+whatever(5);
        
%         DSSCircuit.SetActiveElement('generator.pv1');
%         whatever = DSSCircuit.ActiveElement.Powers;
%         whatever2(i,2) = whatever(1);%+whatever(3)+whatever(5);
%         %whatever2(i,2) = whatever(2)+whatever(4)+whatever(6);
    end
    plot(whatever2);
    %plot(lele2);
    %% Post-Simulation
    %net_function('export_monitors');
    net_class.export_monitors
    toc;
    
function [Start] = dss_startup()% Function for starting up the DSS
    
    global d;
    %instantiate the DSS Object
    Obj = actxserver('OpenDSSengine.DSS');
    d('DSSObj') = Obj;
    
    %Start the DSS. Only needs to be executed the first time within a %Matlab session
    Start = Obj.Start(0);

    % Define the text interface
    d('DSSText') = Obj.Text;
end

function [Start,Obj,Text] = dss_startup(mydir)% Function for starting up the DSS

    %instantiate the DSS Object
    Obj = actxserver('OpenDSSengine.DSS');

    %Start the DSS. Only needs to be executed the first time within a %Matlab session
    Start = Obj.Start(0);

    % Define the text interface
    Text = Obj.Text;
end

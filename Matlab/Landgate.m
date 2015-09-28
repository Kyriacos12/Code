function [] = Landgate(DSSText, directory, caller)
    
    fnc = str2func(caller);
    fnc()
    
    function [] = init()
        %% Redirect the Master Files from all Feeders
        starting_feeder = 63057169;
        for i = 1:6

            current_feeder = starting_feeder + i - 1;
            filename = sprintf('%s\\Input\\Networks\\Landgate\\%u',...
                directory, current_feeder);
            DSSText.Command = sprintf('set datapath=%s', filename);
            DSSText.Command = 'redirect Master.txt';

        end
        %% Setup the monitors in the network
        DSSText.Command = 'new monitor.PQtrans element=transformer.TR1 terminal=1 mode=1 ppolar=no';
        DSSText.Command = 'new monitor.VI1 element=line.line169_616 terminal=2 mode=0';
        DSSText.Command = 'new monitor.VI2 element=line.line170_338 terminal=2 mode=0';
        DSSText.Command = 'new monitor.VI3 element=line.line171_484 terminal=2 mode=0';
        DSSText.Command = 'new monitor.VI4 element=line.line172_1255 terminal=2 mode=0';
        DSSText.Command = 'new monitor.VI5 element=line.line173_904 terminal=2 mode=0';
        DSSText.Command = 'new monitor.VI6 element=line.line174_1164 terminal=2 mode=0';
        DSSText.Command = 'new monitor.VI1s element=line.line169_1 terminal=2 mode=0';
        DSSText.Command = 'new monitor.VI2s element=line.line170_1 terminal=2 mode=0';
        DSSText.Command = 'new monitor.VI3s element=line.line171_1 terminal=2 mode=0';
        DSSText.Command = 'new monitor.VI4s element=line.line172_1 terminal=2 mode=0';
        DSSText.Command = 'new monitor.VI5s element=line.line173_1 terminal=2 mode=0';
        DSSText.Command = 'new monitor.VI6s element=line.line174_1 terminal=2 mode=0';
    end
    
    function [] = export_monitors()
    
    end

end


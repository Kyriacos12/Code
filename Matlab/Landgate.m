classdef Landgate
    properties
        no_customers
        no_feeders
        customers_per_feeder
        DSSText
        starting_feeder
        directory
    end
    methods
        function obj = Landgate()
            global d;
            obj.no_customers = d('no_customers');
            obj.no_feeders = d('no_feeders');
            obj.customers_per_feeder = d('customers_per_feeder');
            obj.DSSText = d('DSSText');
            obj.starting_feeder = d('starting_feeder');
            obj.directory = d('mydir');
        end
        
        function init(obj)
            for i = 1:6
                current_feeder = obj.starting_feeder + i - 1;
                filename = sprintf('%s\\Input\\Networks\\Landgate\\%u\\',...
                    obj.directory, current_feeder);
                obj.DSSText.Command = sprintf('set datapath=(%s)', filename);
                obj.DSSText.Command = 'redirect Master.txt';
                
            end
            %% Setup the monitors in the network
            obj.DSSText.Command = 'new monitor.PQtrans element=transformer.TR1 terminal=1 mode=1 ppolar=no';
            obj.DSSText.Command = 'new monitor.VI1 element=line.line169_616 terminal=2 mode=0';
            obj.DSSText.Command = 'new monitor.VI2 element=line.line170_338 terminal=2 mode=0';
            obj.DSSText.Command = 'new monitor.VI3 element=line.line171_484 terminal=2 mode=0';
            obj.DSSText.Command = 'new monitor.VI4 element=line.line172_1255 terminal=2 mode=0';
            obj.DSSText.Command = 'new monitor.VI5 element=line.line173_904 terminal=2 mode=0';
            obj.DSSText.Command = 'new monitor.VI6 element=line.line174_1164 terminal=2 mode=0';
            obj.DSSText.Command = 'new monitor.VI1s element=line.line169_1 terminal=2 mode=0';
            obj.DSSText.Command = 'new monitor.VI2s element=line.line170_1 terminal=2 mode=0';
            obj.DSSText.Command = 'new monitor.VI3s element=line.line171_1 terminal=2 mode=0';
            obj.DSSText.Command = 'new monitor.VI4s element=line.line172_1 terminal=2 mode=0';
            obj.DSSText.Command = 'new monitor.VI5s element=line.line173_1 terminal=2 mode=0';
            obj.DSSText.Command = 'new monitor.VI6s element=line.line174_1 terminal=2 mode=0';
        end
        
        function [] = export_monitors(obj)
            %% Export of Monitors
            direct = strcat(obj.directory, '\Input\Output\Landgate\');
            direc = strcat(direct, num2str(0));
            val = exist(direc, 'dir');
            i = 0;
            while val == 7
                i = i+1;
                direc = strcat(direct, num2str(i));
                val = exist(direc, 'dir');
            end
            mkdir(direc);
            obj.DSSText.Command = sprintf('set datapath=%s',direc);
            obj.DSSText.Command = 'Export Monitors PQtrans';
            for i = 1:6
                obj.DSSText.Command = sprintf('Export Monitors VI%u', i);
                obj.DSSText.Command = sprintf('Export Monitors VI%us', i);
            end
        end
    end
end

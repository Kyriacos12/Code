classdef assign_profiles
    properties
       DSSText
       customers_per_feeder
    end
    methods
        function obj = assign_profiles
        end
        
        function house(obj)
            global d;
            DSSText = d('DSSText');
            customers_per_feeder = d('customers_per_feeder');
            house = 0;
            bus = obj.extract_bus_info();
            px = [1 2 3 4 5];
            p = [0.3 0.35 0.15 0.13 0.07];
            DSSText.command = sprintf('set datapath=%s\\Input\\Profiles\\House\\', d('mydir'));
            
            for i = 1:d('no_feeders')
                for y = 1:customers_per_feeder(i)
                    
                    house = house + 1;
                    loadshape = randi(500);
                    occupants = randsample(px,1,true,p);
                    
                    DSSText.Command = sprintf('new loadshape.Houseload%u npts=1440 minterval=1.0 csvfile=House%u_%u_%u_%u.txt',...
                        house, d('month'), d('t_day'), occupants, loadshape);
                    DSSText.Command = sprintf('new load.House%u %s Phases=1 kV=0.23 kW=10 PF=0.97 Daily=Houseload%u',...
                        house, bus{i,y}, house);
                    
                end
            end
        end
        function pv(obj)
            global d;
            DSSText = d('DSSText');
            customers_per_feeder = d('customers_per_feeder');
            for i = 1:d('no_feeders')
                pv_per_feeder(i) = obj.penetration_per_feeder(customers_per_feeder(i));
            end
            bus = obj.extract_bus_info;
            DSSText.command = sprintf('set datapath=%s\\Input\\Profiles\\PV\\Iterations\\', d('mydir'));
            iteration = randi(100);
            house = 0;
            
            for i = 1:d('no_feeders')
                tempA = bus(i,1:customers_per_feeder(i));
                idx = randperm(length(tempA));
                bus(i,1:customers_per_feeder(i)) = tempA(idx);
                for y = 1:customers_per_feeder(i)
                    house = house + 1;
                    pvsize = randi(4);
                    pvefficiency = randi(2);
                    DSSText.Command = sprintf('new loadshape.PVload%u npts=1440 minterval=1.0 csvfile=PViter_%u_%u_%u_%u.txt',...
                        house, d('month'), iteration, pvsize, pvefficiency);
                    DSSText.Command = sprintf('new generator.PV%u %s Phases=1 kV=0.23 kW=10 PF=1 Daily=PVload%u',...
                        house, bus{i,y}, house);
                end
            end
        end
        function [number] = penetration_per_feeder(obj,customers)
            global d;
            import assign_house_profiles.*
            
            pene_double = d('pv_penetration') * customers;
            pene_int = int8(d('pv_penetration') * customers);
            pene_percentage = pene_double - double(pene_int);
            
            if pene_percentage == 0
                number = pene_int;
            elseif pene_percentage > 0
                number = randsample([pene_int pene_int+1], 1, true,...
                    [1.0 - pene_percentage pene_percentage]);
            else
                number = randsample([pene_int-1 pene_int], 1, true,...
                    [-pene_percentage 1+pene_percentage]);
            end
            
        end
        function [buses] = extract_bus_info(obj)
            global d;
            
            for i = 1:d('no_feeders')
                current_feeder = d('starting_feeder') + i - 1;
                mydir = sprintf('%s//Input//Networks//%s//%u//Loads.txt',...
                    d('mydir'), d('network'), current_feeder);
                fid = fopen(mydir);
                tline = fgets(fid);
                y = 1;
                
                while ischar(tline)
                    new_line = regexp(tline, ' ', 'split');
                    buses(i,y) = new_line(4);
                    y = y +1;
                    tline = fgets(fid);
                end
                fclose(fid);
            end
            
        end
    end
end

    
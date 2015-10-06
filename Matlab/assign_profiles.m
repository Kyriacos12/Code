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
            DSSObj = d('DSSObj');
            DSSCircuit = DSSObj.ActiveCircuit;
            customers_per_feeder = d('customers_per_feeder');
            house = 0;
            bus = obj.extract_bus_info();
            px = [1 2 3 4 5];
            p = [0.3 0.35 0.15 0.13 0.07];      
            %Import the house profiles
            house_profiles = matfile([d('mydir'), '\Input\Profiles\House_profiles.mat']);
            temp_house = house_profiles.house(d('month'),d('t_day'),:,:,:);
            %Power Factor
            pf = 0.97;
            reactive_power_mult = tan(acos(pf));
            
            for i = 1:d('no_feeders')
                for y = 1:customers_per_feeder(i)
                    
                    house = house + 1;
                    loadshape = randi(500);
                    occupants = randsample(px,1,true,p);
                    
                    temp_array = squeeze(temp_house(1,1,occupants,loadshape,:));
                    DSSCircuit.Loadshapes.New(sprintf('Houseload%u', house));
                    DSSCircuit.Loadshapes.name=sprintf('Houseload%u', house);
                    DSSCircuit.Loadshapes.npts=1440;
                    DSSCircuit.Loadshapes.MinInterval=1;
                    DSSCircuit.Loadshapes.UseActual=1;
                    feature('COM_SafeArraySingleDim',1);
                    DSSCircuit.Loadshapes.Pmult=temp_array;
                    DSSCircuit.Loadshapes.Qmult=(temp_array*reactive_power_mult);
                    feature('COM_SafeArraySingleDim',0);              
                                                          
                    DSSText.Command = sprintf('new load.House%u %s Phases=1 kV=0.23 kW=1 PF=%u Daily=Houseload%u',...
                        house, bus{i,y},pf, house);
                    
                end
            end
            clear temp_house;
        end
        
        function pv(obj)
            global d;
            DSSText = d('DSSText');
            DSSObj = d('DSSObj');
            DSSCircuit = DSSObj.ActiveCircuit;
            customers_per_feeder = d('customers_per_feeder');
            for i = 1:d('no_feeders')
                pv_per_feeder(i) = obj.penetration_per_feeder(customers_per_feeder(i));
            end
            bus = obj.extract_bus_info;
            iteration = randi(100);
            iteration = 2; %CHANGE THIS LATER, FOR DEBUGGING REASONS
            house = 0;
            
            pv_profiles = matfile([d('mydir'), '\Input\Profiles\PV_profiles.mat']);
            temp_pv = pv_profiles.PV(d('month'), :, :, :, :);
            
            for i = 1:d('no_feeders')
                tempA = bus(i,1:customers_per_feeder(i));
                idx = randperm(length(tempA));
                bus(i,1:customers_per_feeder(i)) = tempA(idx);
                
                for y = 1:pv_per_feeder(i)
                    house = house + 1;
                    pvsize = randi(4);
                    pvefficiency = randi(2);
                    
                    temp_array = squeeze(temp_pv(1,iteration,pvsize,pvefficiency,:));
                    DSSCircuit.Loadshapes.New(sprintf('PVload%u', house));
                    DSSCircuit.Loadshapes.name=sprintf('PVload%u', house);
                    DSSCircuit.Loadshapes.npts=1440;
                    DSSCircuit.Loadshapes.MinInterval=1;
                    DSSCircuit.Loadshapes.UseActual=0;
                    feature('COM_SafeArraySingleDim',1);
                    DSSCircuit.Loadshapes.Pmult=temp_array;
                    feature('COM_SafeArraySingleDim',0);
                    
                    DSSText.Command = sprintf('new generator.PV%u %s Phases=1 kV=0.23 kW =1 PF=1 Daily=PVload%u',...
                        house, bus{i,y}, house);
                    obj.storage(house,bus{i,y});
                end
            end
            clear temp_pv;
        end
        
        function storage(obj, house, bus)
            
            global d;
            DSSText = d('DSSText');
            DSSObj = d('DSSObj');
            DSSCircuit = DSSObj.ActiveCircuit;
            
            DSSText.Command = sprintf('new storage.battery%u phases=1 %s kV=0.23 kWrated=3 kWhrated=7 %%stored=0 State=Discharging',...
                house, bus);
            
            %kWrated = charging rate
            %kW = discharging rate
            

        
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

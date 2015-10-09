classdef manage_storage
    
    properties
        pv_profiles;
        no_customers;
        pv_data;   
        DSSCircuit;
        set_night;
        set_day;
        sunlight;
        month;
        house_profiles;
        night;
        house_data;
        max_output;
        
    end
    
    methods
        function obj = manage_storage()
            global d;
            profiles = matfile([d('mydir'), '\Input\Profiles\PV_profiles.mat']);
            hprofiles = matfile([d('mydir'), '\Input\Profiles\House_profiles.mat']);
            obj.house_profiles = hprofiles.house(d('month'),d('t_day'),:,:,:);
            obj.pv_profiles = profiles.PV(d('month'), :, :, :, :);
            obj.no_customers = d('no_customers');
            obj.pv_data = d('pv_data');
            DSSObj = d('DSSObj');
            obj.DSSCircuit = DSSObj.ActiveCircuit;
            obj.set_day = 0;
            obj.set_night = 0;
            obj.sunlight = d('sunlight');
            obj.month = d('month');
            obj.night = 0;
            obj.house_data = d('house_data');
            
            %Things that might need to be changed
            obj.max_output = 2;
            
            
        end
        
        function iteration_management(obj,iteration)
            
            for i = 1:obj.no_customers
                if obj.pv_data(i,4) ==1
                    if iteration >= obj.sunlight(obj.month,1) && iteration <= obj.sunlight(obj.month,2)
                        val = obj.pv_profiles(1, obj.pv_data(i,1),obj.pv_data(i,2),...
                            obj.pv_data(i,3),iteration);
                        if val > 2
                            numb = num2str(2/val);
                            obj.DSSCircuit.CktElements(sprintf('storage.battery%u',i)).Properties('kWrated').Val=numb;
                            obj.set_day=1;
                        elseif obj.set_day==1
                            obj.DSSCircuit.CktElements(sprintf('storage.battery%u',i)).Properties('kWrated').Val='1';
                            obj.set_day = 0;
                        end
                    elseif iteration >= obj.sunlight(obj.month,2)
                        if obj.night == 0
                            for j = 1:obj.no_customers
                                if obj.pv_data(j,4)==1
                                    obj.night = 1;
                                    obj.DSSCircuit.CktElements(sprintf('storage.battery%u',j)).Properties('daily').Val=...
                                        sprintf('houseload%u',j);
                                end
                            end
                        end
                        val = obj.house_profiles(1,1,obj.house_data(i,1),obj.house_data(i,2),iteration);
                        if val > 2
                            numb = num2str(2/val);
                            obj.DSSCircuit.CktElements(sprintf('storage.battery%u',i)).Properties('kWrated').Val=numb;
                            obj.set_night = 1;
                        elseif obj.set_night==1
                            obj.DSSCircuit.CktElements(sprintf('storage.battery%u',i)).Properties('kWrated').Val='1';
                            obj.set_night=0;
                        end
                    end
                end
            end
      
        end
    end 
end

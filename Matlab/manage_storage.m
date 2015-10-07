classdef manage_storage
    
    properties
        pv_profiles;
        no_customers;
        pv_data;   
        DSSCircuit;
        set;
        pv_max;
    end
    
    methods
        function obj = manage_storage()
            global d;
            profiles = matfile([d('mydir'), '\Input\Profiles\PV_profiles.mat']);
            obj.pv_profiles = profiles.PV(d('month'), :, :, :, :);
            obj.no_customers = d('no_customers');
            obj.pv_data = d('pv_data');
            obj.pv_max = d('pv_max');
            DSSObj = d('DSSObj');
            obj.DSSCircuit = DSSObj.ActiveCircuit;
            obj.set = 0;
            
            
        end
        
        function iteration_management(obj,iteration)
            
            for i = 1:obj.pv_max
                
                val = obj.pv_profiles(1, obj.pv_data(i,1),obj.pv_data(i,2),...
                        obj.pv_data(i,3),iteration);
                if val > 2
                    numb = num2str(2/val);
                    obj.DSSCircuit.CktElements(sprintf('storage.battery%u',i)).Properties('kWrated').Val=numb;
                    obj.set=1;
                elseif obj.set==1
                    obj.DSSCircuit.CktElements(sprintf('storage.battery%u',i)).Properties('kWrated').Val='1';
                    obj.set = 0;
                end
            end
            
        end
    end 
end

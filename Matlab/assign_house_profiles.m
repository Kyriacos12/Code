function [] = assign_house_profiles()
    global d;
    DSSText = d('DSSText');
    customers_per_feeder = d('customers_per_feeder');
    house = 0;
    bus = extract_bus_info();
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
            something = sprintf('new loadshape.Houseload%u npts=1440 minterval=1.0 csvfile=House%u_%u_%u_%u.txt',...
                house, d('month'), d('t_day'), occupants, loadshape);
            DSSText.Command = sprintf('new load.House%u %s Phases=1 kV=0.23 kW=10 PF=0.97 Daily=Houseload%u',...
                house, bus{i,y}, house);
            something2 = sprintf('new load.House%u %s Phases=1 kV=0.23 kW=10 PF=0.97 Daily=Houseload%u',...
                house, bus{i,y}, house);
        end
    end    
end

function [buses] = extract_bus_info()
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

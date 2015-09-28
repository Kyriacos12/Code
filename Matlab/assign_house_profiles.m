function [] = assign_house_profiles(dir,DSSText, t_month, t_day, network, no_feeders, customers_per_feeder)

    house = 0
    buses = 1%extract customer busses function
    px = [1 2 3 4 5]
    p = [0.3 0.35 0.15 0.13 0.07]
    
    DSSText.command = sprintf('set datapath=%s\Profiles\House\', dir)
    
    for i = 1:no_feeders
        for y = 1:customers_per_feeder(i)
            
            house = house + 1
            loadshape = randi(500)
            occupants = randsample(px,1,true,p)
            
            DSSText.Command = sprintf('new loadshape.Houseload%s npts=1440 minterval=1.0 csvfile=House%s_%s_%s_%s.txt',...
                house, t_month, t_day, occupants, loadshape)
            DSSText.Command = sprintf('new load.House%s %s Phases=1 kV=0.23 kW=10 PF=0.97 Daily=Houseload%s',...
                house, buses(i,y), house)
            
        end
    end    
end

function [] = extract_bus_info(network, no_feeders)

    if network == 'Landgate'
        starting_feeder = 63057169      
    end
    

end

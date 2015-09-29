function assign_pv
    global d;
    %DSSText = d('DSSText');
    customers_per_feeder = d('customers_per_feeder');
    for i = 1:d('no_feeders')
        pv_per_feeder(i) = penetration_per_feeder(customers_per_feeder(i));
    end
end

function [pv_number] = penetration_per_feeder(customers)
    global d;
    pene_double = d('pv_penetration') * customers;
    pene_int = int8(d('pv_penetration') * customers);
    pene_percentage = pene_double - double(pene_int);
    
    if pene_percentage == 0
        pv_number = pene_int;
    elseif pene_percentage > 0
        pv_number = randsample([pene_int pene_int+1], 1, true,...
            [1.0 - pene_percentage pene_percentage]);
    else
        pv_number = randsample([pene_int-1 pene_int], 1, true,...
            [-pene_percentage 1+pene_percentage]);
    end
        

end
function [] = setup()

    %Obtain Settings
    %directory = fullfile(cd,'..\..'); %PC at Uni
    global d;
    
    d('mydir') = fullfile(mfilename('fullpath'),'..\..\..');
    settings_dir = sprintf('%s\\Input\\Networks\\%s\\settings.txt',...
        d('mydir'), d('network'));
    fid = fopen(settings_dir);

    d('no_customers') = str2num(fgets(fid));
    d('no_feeders') = str2num(fgets(fid));

    for i = 1:d('no_feeders')
        customers_per_feeder(i) = str2num(fgets(fid));
    end
    
    fclose(fid);
    d('customers_per_feeder') = customers_per_feeder;
    
    if strcmpi(d('network'),'Landgate')
        d('starting_feeder') = 63057169;     
    end
    
end

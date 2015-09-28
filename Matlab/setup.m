function [no_customers, no_feeders, customers_per_feeder, directory] = setup(network)

    %Obtain Settings
    %directory = fullfile(cd,'..\..'); %PC at Uni
    directory = fullfile(mfilename('fullpath'),'..\..\..');
    settings_dir = sprintf('%s\\Input\\Networks\\%s\\settings.txt',...
        directory, network);
    fid = fopen(settings_dir);

    no_customers = str2num(fgets(fid));
    no_feeders = str2num(fgets(fid));

    for i = 1:no_feeders
        customers_per_feeder(i) = str2num(fgets(fid));
    end

    fclose(fid);

end

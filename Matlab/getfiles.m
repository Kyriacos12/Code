mydir = 'C:\Users\Kyriacos\Desktop\PhD\Input\Profiles\PV\Iterations';
my_array = zeros(12,100,4,2,1440);
tic;
parfor i = 1:12
    for y = 1:100
        for z=1:4
            for j = 1:2
                mydir2 = sprintf('%s\\PViter_%u_%u_%u_%u.txt', mydir,...
                    i, y, z, j);
                fid = fopen(mydir2);
                for k =1:1440
                    my_array(i,y,z,j,k) = str2double(fgets(fid));
                end
                fclose(fid);
            end
        end
    end
end
toc;
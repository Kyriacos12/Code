tic;
hi = matfile('C:\Users\Kyriacos\Desktop\PhD\Input\Profiles\house_profiles.mat');

something = hi.house(:,:,:,:,:);

parfor i = 1:12
    for y = 1:2
        for z = 1:5
            for j=1:500
                for k = 1:1440
                
                    something(i,y,z,j,k) = something(i,y,z,j,k) * 10
                    
                end
            end
        end
    end

end
toc;
%clear something
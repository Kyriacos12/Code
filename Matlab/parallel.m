tic; clear; clc; close all
warning('off','all');
p = containers.Map;
for i = 1:9
name = sprintf('Job%u',i);
p(name) = batch('main', 'Profile', 'local','matlabpool',0,'CaptureDiary',true,'AutoAttachFiles', true); 

end
for i = 1:9
 name = sprintf('Job%u',i);
 wait(p(name), 'finished');
end

toc;
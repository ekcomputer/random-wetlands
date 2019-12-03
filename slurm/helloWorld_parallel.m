%#! /opt/matlab/bin/matlab
% test script 
tic
n=16; % number of workers
pth=getenv('SLURMLOG');


try
    parpool(n)
catch
    disp('parpool already open.')
end
i=1; % just in case 
fprintf('--------------------------------------\n');
parfor i=1:n
    fid=fopen([pth, 'helloWorld.log'], 'a');
    fprintf(fid, '\n--------------------------------------\n');
    fprintf('Starting test script.  Iteration: %d. Time: %s\n', i, datetime);
%     fprintf('Iteration: %d\n', i);
%     fprintf(fid, 'Iteration: %d\n', i);
    fprintf(fid, 'Starting test script.  Iteration: %d. Time: %s\n', i, datetime);

    A=rand(5000,5000);
    B=A^12;
    fprintf('Computation answer: %d\n\n', B(1467));


    fprintf(fid, 'Computation answer: %d\n', B(1467));
    fprintf(fid, 'Ending test script.  Iteration: %d. Time: %s\n', i, datetime);

    fprintf('--------------------------------------\n');
    fprintf('Ending test script.  Iteration: %d. Time: %s\n', i, datetime);
    fclose(fid);
end
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
unix('free -h')
toc

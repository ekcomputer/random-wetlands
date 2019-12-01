%#! /opt/matlab/bin/matlab
% test script 
tic
n=6; % number of workers
pth=getenv('SLURMLOG');


try
    parpool(n)
catch
    disp('parpool already open.')
end
i=1; % just in case 
parfor i=1:n
    fid=fopen([pth, 'helloWorld.log'], 'a');
    fprintf('--------------------------------------\n');
    fprintf(fid, '\n--------------------------------------\n');
    fprintf('Starting test script.  Time: %s\n', datetime);
    fprintf('Iteration: %d\n', i);
    fprintf(fid, 'Iteration: %d\n', i);
    fprintf(fid, 'Starting test script.  Time: %s\n', datetime);

    A=rand(5000,5000);
    B=A^12;
    fprintf('Computation answer: %d\n\n', B(1467));


    fprintf(fid, 'Computation answer: %d\n', B(1467));
    fprintf(fid, 'Ending test script.  Time: %s\n', datetime);

    fprintf('--------------------------------------\n');
    fprintf('Ending test script.  Time: %s\n', datetime);
    fclose(fid);
end
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
unix('free -h')
toc

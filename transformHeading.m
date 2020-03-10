function heading_projected = transformHeading(head, R, info)
% takes flight heading and converts it into heading in a local coordinate
% I use head to refer to orthogonals of actual flight heading
% system (by default Canada Albers Equal Area Conic)
% 
% Inputs:     head                =   heading in radians (can be vector)
%                                     if two entries: first is < pi, second
%                                     >= pi
%             R                   =   map cells ref  
%             info                 =   mapcells ref projection
% 
% Outputs:    head_transformed    =   heading in radians in local coord syst
% 
% Ethan Kyzivat, March 2020

%% make column vector
head=head(:);
%% calculate BB and center coords
% figure;
latBB=[min(info.CornerCoords.Lat), max(info.CornerCoords.Lat)];
lonBB=[min(info.CornerCoords.Lon), max(info.CornerCoords.Lon)];
pseudocenter.geog=[mean(latBB),mean(lonBB)]; % Y,X


%% forward project center and BB to mercator
proj=defaultm('mercator'); % get mstruct in mercator

[pseudocenter.x,pseudocenter.y] = projfwd(proj,pseudocenter.geog(1),pseudocenter.geog(2)); % x, y
[bb.x,bb.y] = projfwd(proj,latBB,lonBB); % gives botoom left and top right coords
bb.x=flip(bb.x)'; bb.y=flip(bb.y)';

%% NEW, using vfwtran (didn't know this existed)

mstruct = geotiff2mstruct(info);
longs=pseudocenter.geog(2)*ones(size(head), 'like', head);
lats=pseudocenter.geog(1)*ones(size(head), 'like', head);
angles=round(rad2deg(head));
heading_projected = deg2rad(mod(360-vfwdtran(mstruct, lats, longs,angles)+90, 360)); 
% heading_projected=zeros(size(head), 'like', head); % set output
%% NEW plot (doesn't work completely)

% axesm(mstruct,'maplatlim',latBB,'maplonlim',lonBB)
% gridm; framem; mlabel; plabel
% 
% quiverm(pseudocenter.geog(1), pseudocenter.geog(2), 500*cos(angles(1)), 500*sin(angles(1)))
% quiverm(pseudocenter.geog(1), pseudocenter.geog(2), 500*cos(angles(1)), 500*sin(angles(1)))
% %% projinv and then inverse functinos to get slopes in Albers
%     % get center point in image coords
% [pseudocenter.xProj,pseudocenter.yProj]= worldToIntrinsic(R, pseudocenter.geog(2), pseudocenter.geog(1));
% b_transformed= pseudocenter.yProj - m* pseudocenter.xProj;
% m_transformed=(endpoint.y-b)/endpoint.x;
% % head_transformed % <<================================STOPPED HERE 
%     % unnesss...
% [endpoint.Lat, endpoint.Lon]= projinv(proj,endpoint.x,endpoint.y);
% 

% %% find points along line of constant heading (aka rhumb lines) using line equation
% m=-tan(head-pi/2); % convert heading to angle from x axis
% b= pseudocenter.y - m* pseudocenter.x;
% 
%     % just take Y-intercepts, even if they are very high or low- angle will
%     % still be correct
%     % QI or Q II
% if any(isinf(m)) 
%     error('Heading slope is infinity.')
% end
% endpoint.x=bb.x;
% endpoint.y=m.*bb.x+b;
% 
% 
% %% plot BB in mercator with directions
% h=axesm('Mapprojection','mercator','Grid','on','Frame','on', 'MlabelParallel',0,'PlabelMeridian',0,'mlabellocation',60, 'meridianlabel','on','parallellabel','on', 'MapLatLimit', latBB, 'MapLonLimit', lonBB)
% 
% 
% h=axesm('Mapprojection','mercator','Grid','on','Frame','on', 'MlabelParallel',0,'PlabelMeridian',0,'mlabellocation',60, 'meridianlabel','on','parallellabel','on', 'MapLatLimit', R.YWorldLimits, 'MapLonLimit', R.XWorldLimits)
function [p2d, t2d, ct2d, e2d, iKit] = f_make_mesh_xy2(meshopt,varargin)

%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------
%tic;
%fprintf('Making mesh ...')
%----------------------------------------------------------------------
if isfield(meshopt,'flog')
    flog = meshopt.flog;
else
    flog = 1.05;
end
%----------------------------------------------------------------------
xDom    = [];
id_xdom = [];
yDom  = [];
id_ydom = [];
xmax = 0;
ymax = 0;
p2d = [];
iElem = 0;
t2d = [];
for ix = 1:length(meshopt.x)
    if strcmpi(meshopt.x{ix}.lt,'regular')
        x = f_line('d',meshopt.x{ix}.d,'ns',meshopt.x{ix}.ns,'st',meshopt.x{ix}.st);
        xDom = [xDom x];
        id_xdom = [id_xdom    ix.*ones(1,length(x))];
        xMesh = [xmax cumsum(xDom)];
        for iy = 1:length(meshopt.y)
            if strcmpi(meshopt.y{iy}.lt,'regular')
                y = f_line('d',meshopt.y{iy}.d,'ns',meshopt.y{iy}.ns,'st',meshopt.y{iy}.st);
                yDom = [yDom y];
                id_ydom = [id_ydom    iy.*ones(1,length(y))];
                %---
                yMesh = [ymax cumsum(yDom)];
                %-------------- meshing -----------------------------------
                [x1,y1] = meshgrid(xMesh,yMesh);
                x2=[]; y2=[];
                for ik = 1:size(x1,1)
                    x2 = [x2 x1(ik,:)];
                end
                for ik = 1:size(y1,1)
                    y2 = [y2 y1(ik,:)];
                end
                p2d = [p2d [x2;y2]];
                %---
                for iy = 1:size(x1,1)-1      % number of layer y
                    for ix = 1:size(x1,2)-1  % number of layer x
                        iElem = iElem+1;
                        t2d(1:4,iElem) = [size(x1,2)*(iy-1)+ix; ...
                                          size(x1,2)*(iy-1)+ix+1; ...
                                          size(x1,2)*iy+ix+1; ...
                                          size(x1,2)*iy+ix];
                        t2d(5,iElem) = id_xdom(ix); % id_xdom
                        t2d(6,iElem) = id_ydom(iy); % id_ydom
                    end
                end
                xmax = max(x2);
                ymax = max(y2);
            end
        end
    end
end



%%
iKit = f_intkitquad(p2d,t2d);
%%
nb_p = size(p2d,2);
nb_t = size(t2d,2);
ct2d = zeros(2,nb_t);
ct2d(1,:) = 1/4 .* (p2d(1,t2d(1,:))+p2d(1,t2d(2,:))+p2d(1,t2d(3,:))+p2d(1,t2d(4,:)));
ct2d(2,:) = 1/4 .* (p2d(2,t2d(1,:))+p2d(2,t2d(2,:))+p2d(2,t2d(3,:))+p2d(2,t2d(4,:)));

%%
e         = zeros(4,2,nb_t);
EdNo_inEl = [1 2; 1 4; 2 3; 3 4];
siEd_inEl = [1; -1; 1; 1];
si_ed     = zeros(4,nb_t);
for i = 1:4
    e(i,:,:) = [t2d(EdNo_inEl(i,1),:); t2d(EdNo_inEl(i,2),:)];
    [e(i,:,:), ie] = sort(squeeze(e(i,:,:)));
    si_ed(i,:) = siEd_inEl(i) .* diff(ie);
end
%----------------------------------
e2d = [];
for i = 1:4
    e2d = [e2d squeeze(e(i,:,:))];
end
e2d     = f_unique(e2d,'urow');
nbEdge  = length(e2d(1,:));

ed_in_el = zeros(4,nb_t);
for i = 1:4
    ed_in_el(i,:) = f_findvec(squeeze(e(i,:,:)),e2d);
end

eL_of_ed = zeros(1,nbEdge);
for i = 1:4
    eL_of_ed(ed_in_el(i,si_ed(i,:) > 0)) = find(si_ed(i,:) > 0);
end
dL_of_ed = zeros(1,nbEdge);
dL_of_ed(eL_of_ed > 0) = t2d(5,eL_of_ed(eL_of_ed > 0));

eR_of_ed = zeros(1,nbEdge);
for i = 1:4
    eR_of_ed(ed_in_el(i,si_ed(i,:) < 0)) = find(si_ed(i,:) < 0);
end
dR_of_ed = zeros(1,nbEdge);
dR_of_ed(eR_of_ed > 0) = t2d(5,eR_of_ed(eR_of_ed > 0));

%----------------------
e2d(3,:) = dL_of_ed;
e2d(4,:) = dR_of_ed;
%----------------------------------------------------------------------
%mesh2d.p2d  = p2d;
%mesh2d.t2d  = t2d;
%mesh2d.ct2d = ct2d;
%mesh2d.e2d  = e2d;
%----------------------------------------------------------------------
%mesh2d.iKit = iKit;
%----------------------------------------------------------------------
%fprintf('done ----- in %.2f s \n',toc);
%----------------------------------------------------------------------



function [p2d, t2d, ct2d, e2d, iKit] = f_make_mesh_xy(meshOpt,varargin)
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
if isfield(meshOpt,'flog')
    flog = meshOpt.flog;
else
    flog = 1.05;
end
%----------------------------------------------------------------------
xDom    = [];
id_xdom = []; 
for ix = 1:length(meshOpt.x)
    d     = meshOpt.x{ix}{1};
    dnum  = meshOpt.x{ix}{2};
    dtype = meshOpt.x{ix}{3};
    if strcmpi(dtype,'lin')
        ratio = dnum;
        x = d/ratio .* ones(1,ratio);
    end
    if strcmpi(meshOpt.x{ix}{3},'log+')
        ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
        x = d .* ratio;
    end
    if strcmpi(meshOpt.x{ix}{3},'log-')
        ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
        x = d .* ratio;
        x = x(end:-1:1);
    end
    if strcmpi(meshOpt.x{ix}{3},'log+-') || strcmpi(meshOpt.x{ix}{3},'log=')
        dnum  = dnum * 2;
        ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
        x = d/2 .* ratio;
        x = [x, x(end:-1:1)];
    end
    xDom = [xDom x];
    id_xdom = [id_xdom    ix.*ones(1,length(x))];
end
xMesh = [0 cumsum(xDom)];
%----------------------------------------------------------------------
yDom  = [];
id_ydom = []; 
for ix = 1:length(meshOpt.y)
    d     = meshOpt.y{ix}{1};
    dnum  = meshOpt.y{ix}{2};
    dtype = meshOpt.y{ix}{3};
    if strcmpi(dtype,'lin')
        ratio = dnum;
        x = d/ratio .* ones(1,ratio);
    end
    if strcmpi(dtype,'log+')
        ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
        x = d .* ratio;
    end
    if strcmpi(dtype,'log-')
        ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
        x = d .* ratio;
        x = x(end:-1:1);
    end
    if strcmpi(dtype,'log+-')
        dnum  = dnum * 2;
        ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
        x = d/2 .* ratio;
        x = [x, x(end:-1:1)];
    end
    yDom = [yDom x];
    id_ydom = [id_ydom    ix.*ones(1,length(x))];
end
yMesh = [0 cumsum(yDom)];
%-------------- meshing -----------------------------------------------
[x1,y1] = meshgrid(xMesh,yMesh);
x2=[]; y2=[];

for ik = 1:size(x1,1)
    x2 = [x2 x1(ik,:)];
end

for ik = 1:size(y1,1)
    y2 = [y2 y1(ik,:)];
end
%----- centering

% x2 = x2 - (max(x2) - min(x2))/2;
% y2 = y2 - (max(y2) - min(y2))/2;

%-----
p2d = [x2;y2];
%-----
t2d = zeros(7,(size(x1,1)-1)*(size(x1,2)-1));
iElem = 0;
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



function mesh2d = f_mesh2dgeo1d(geo1d,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'flog','id_x','id_y'};

% --- default input value
flog = 1.05; % log factor when making log mesh
id_x = [];
id_y = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

% -------------------------------------------------------------------------
if isempty(id_x)
    id_x = fieldnames(geo1d.x);
end
%--------------------------------------------------------------------------
if isempty(id_y)
    id_y = fieldnames(geo1d.y);
end
% -------------------------------------------------------------------------

tic;
fprintf('Making mesh2d from geo1d ...')

% -------------------------------------------------------------------------
xDom    = [];
id_xdom = [];
lenx    = numel(id_x);
for ilay = 1:lenx
    d     = geo1d.x.(id_x{ilay}).d;
    dnum  = geo1d.x.(id_x{ilay}).dnum;
    dtype = geo1d.x.(id_x{ilay}).dtype;
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
    if strcmpi(dtype,'log+-') || strcmpi(dtype,'log=')
        dnum  = dnum * 2;
        ratio = logspace(0,flog,dnum)./sum(logspace(0,flog,dnum));
        x = d/2 .* ratio;
        x = [x, x(end:-1:1)];
    end
    xDom = [xDom x];
    id_xdom = [id_xdom    ilay.*ones(1,length(x))];
end
xMesh = [0 cumsum(xDom)];
% -------------------------------------------------------------------------
yDom    = [];
id_ydom = []; 
leny    = numel(id_y);
for ilay = 1:leny
    d     = geo1d.y.(id_y{ilay}).d;
    dnum  = geo1d.y.(id_y{ilay}).dnum;
    dtype = geo1d.y.(id_y{ilay}).dtype;
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
    id_ydom = [id_ydom    ilay.*ones(1,length(x))];
end
yMesh = [0 cumsum(yDom)];

% -------------- meshing --------------------------------------------------

[x1, y1] = meshgrid(xMesh, yMesh);
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
node = [x2; y2];

%-----
nblayx = size(x1,2) - 1; % number of layers x
nblayy = size(x1,1) - 1; % number of layers y
elem   = zeros(4, nblayx * nblayy);
iElem  = 0;
idx_elem = zeros(1, nblayx * nblayy);
idy_elem = zeros(1, nblayx * nblayy);
all_id_elem = 1:nblayx * nblayy;

for iy = 1 : nblayy      
    for ix = 1 : nblayx  
        iElem = iElem+1;
        elem(1:4,iElem) = [size(x1,2) * (iy-1) + ix; ...
                           size(x1,2) * (iy-1) + ix+1; ...
                           size(x1,2) *  iy    + ix+1; ...
                           size(x1,2) *  iy    + ix];
        idx_elem(iElem) = id_xdom(ix); % id_xdom
        idy_elem(iElem) = id_ydom(iy); % id_ydom
    end
end

nb_node = size(node,2);
nb_elem = size(elem,2);
%--------------------------------------------------------------------------
% --- Output
mesh2d.node = node;
mesh2d.nb_node = nb_node;
mesh2d.elem = elem;
mesh2d.nb_elem = nb_elem;
mesh2d.elem_type = 'quad';
for i = 1:lenx
    mesh2d.(id_x{i}).id_elem = all_id_elem(idx_elem == i);
end
for i = 1:leny
    mesh2d.(id_y{i}).id_elem = all_id_elem(idy_elem == i);
end
mesh2d.cnode(1,:) = mean(reshape(node(1,elem(1:4,:)),4,nb_elem));
mesh2d.cnode(2,:) = mean(reshape(node(2,elem(1:4,:)),4,nb_elem));
% --- Log message
fprintf('done ----- in %.2f s \n',toc);




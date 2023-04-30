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
    % ---
    x     = f_div1d(geo1d.x.(id_x{ilay}));
    xDom  = [xDom x];
    % ---
    id = [];
    for j = 1:length(x)
        id{j} = id_x{ilay};
    end
    % ---
    id_xdom = [id_xdom id];
    %id_xdom = [id_xdom    ilay.*ones(1,length(x))];
end
xMesh = [0 cumsum(xDom)];
codeidx = f_str2code(id_xdom);

% -------------------------------------------------------------------------
yDom    = [];
id_ydom = []; 
leny    = numel(id_y);
for ilay = 1:leny
    y     = f_div1d(geo1d.y.(id_y{ilay}));
    yDom = [yDom y];
    % ---
    id = [];
    for j = 1:length(y)
        id{j} = id_y{ilay};
    end
    % ---
    id_ydom = [id_ydom id];
    %id_ydom = [id_ydom    ilay.*ones(1,length(y))];
end
yMesh = [0 cumsum(yDom)];
codeidy = f_str2code(id_ydom);

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
elem_code = zeros(1, nblayx * nblayy);
idy_elem = zeros(1, nblayx * nblayy);
all_id_elem = 1:nblayx * nblayy;

for iy = 1 : nblayy      
    for ix = 1 : nblayx  
        iElem = iElem+1;
        elem(1:4,iElem)  = [size(x1,2) * (iy-1) + ix; ...
                            size(x1,2) * (iy-1) + ix+1; ...
                            size(x1,2) *  iy    + ix+1; ...
                            size(x1,2) *  iy    + ix];
        elem_code(iElem) = codeidx(ix) * codeidy(iy); % id_xdom * id_ydom
    end
end

nb_node = size(node,2);
nb_elem = size(elem,2);
%--------------------------------------------------------------------------
% --- Output
mesh2d.mesher = 'mesh2dgeo1d';
mesh2d.node = node;
mesh2d.nb_node = nb_node;
mesh2d.elem = elem;
mesh2d.nb_elem = nb_elem;
mesh2d.elem_code = elem_code;
mesh2d.elem_type = 'quad';
% ---
% for i = 1:lenx
%     mesh2d.(id_x{i}).id_elem = all_id_elem(elem_code == i);
% end
% for i = 1:leny
%     mesh2d.(id_y{i}).id_elem = all_id_elem(idy_elem == i);
% end
% ---
mesh2d.cnode(1,:) = mean(reshape(node(1,elem(1:4,:)),4,nb_elem));
mesh2d.cnode(2,:) = mean(reshape(node(2,elem(1:4,:)),4,nb_elem));
% ---
mesh2d.id_elemdom = -1; % <-- old t4 from femm, t5 from quad
% --- Log message
fprintf('done ----- in %.2f s \n',toc);




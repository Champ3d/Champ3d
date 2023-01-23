function [node,elem,varargout] = f_qmesh_regvo(node,elem,line2d,zone2d,varargin)
% Original version of regular mesh for a homogenous region
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

% --- valid argument list (to be updated each time modifying function)
arglist = {'idzone'};

% --- default input value
idzone = 0;


% --- check and update input
for i = 1:(nargin-4)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
iElem = size(elem,2);
%---
if ~isnumeric(idzone)
    idzone = f_str2code(idzone);
end
%--------------------------------------------------------------------------
linenames = {'ibline','itline','illine','irline'};
for iln = 1:length(linenames)
    theline = linenames{iln};
    if strcmpi(theline,'ibline') || strcmpi(theline,'itline')
        coor = 1;
    else
        coor = 2;
    end
    %-bline
    iline = zone2d.(theline);
    nline = length(iline);
    %--sorted by x or y
    ddiv = [];
    idnglobal = [];
    idlines = {};
    itolineid = [];
    for il = 1:nline
        ddiv = [ddiv line2d(iline(il)).divline(coor,:)];
        idnglobal = [idnglobal line2d(iline(il)).idnglobal];
        idlines   = [idlines line2d(iline(il)).id];
        itolineid = [itolineid repmat(il,1,length(line2d(iline(il)).idnglobal))];
    end
    [ddiv,ing] = f_realunique(ddiv);
    idnglobal  = idnglobal(ing);
    itolineid  = itolineid(ing);
    [ddiv,ing] = sort(ddiv);
    idnglobal  = idnglobal(ing);
    itolineid  = itolineid(ing);
    zone.(theline).ddiv = ddiv;
    zone.(theline).idnglobal = idnglobal;
    zone.(theline).itolineid = itolineid;
    zone.(theline).idlines   = idlines;
end
%-------------- meshing -------------------------------------------
nx = length(zone.ibline.ddiv);
ny = length(zone.illine.ddiv);
xmat = zeros(ny,nx);
ymat = zeros(ny,nx);
for inx = 1:nx
    xmat(:,inx) = linspace(zone.ibline.ddiv(inx),zone.itline.ddiv(inx),ny);
end
for iny = 1:ny
    ymat(iny,:) = linspace(zone.illine.ddiv(iny),zone.irline.ddiv(iny),nx);
end
%[xmat,ymat] = meshgrid(zone.ibline.ddiv,zone.illine.ddiv);
%--- global id of node
nbn = size(node,2);
idnew = zeros(ny,nx);
idnew(1,:)   = zone.ibline.idnglobal;
idnew(end,:) = zone.itline.idnglobal;
idnew(:,1)   = zone.illine.idnglobal;
idnew(:,end) = zone.irline.idnglobal;
%--- node coordinates
xnew = [];
ynew = [];
lenn = nx - 2; % 2 known nodes
for i = 2:ny-1 % number of layer y
    xnew = [xnew xmat(i,2:end-1)];
    ynew = [ynew ymat(i,2:end-1)];
    idnew(i,2:end-1) = nbn + ((lenn*(i-2)+1) : lenn*(i-1));
end
%--- update node
node = [node [xnew;ynew]];
%--- make elem
el = zeros(5,(ny-1)*(nx-1));
for iy = 1:ny-1      % number of layer y
    for ix = 1:nx-1  % number of layer x
        iElem = iElem+1;
        el(1,iElem) = idnew(iy,ix);
        el(2,iElem) = idnew(iy,ix+1);
        el(3,iElem) = idnew(iy+1,ix+1);
        el(4,iElem) = idnew(iy+1,ix);
        el(5,iElem) = idzone;
        %idbl{iElem} = ;
    end
end
elem = [elem el];
%idbline = [idbline idbl];
%idtline = [idtline idtl];
%idlline = [idlline idll];
%idrline = [idrline idrl];


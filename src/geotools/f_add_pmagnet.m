function c3dobj = f_add_pmagnet(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_design3d','id_dom3d','mur','br_value','br_ori','id_bcon'};

% --- default input value
id_design3d = [];
id_dom3d = [];
br_value = 0;
br_ori   = [];
id_bcon  = [];
id_pmagnet = [];
mur = 1;
%--------------------------------------------------------------------------
if ~isfield(c3dobj,'pmagnet')
    c3dobj.pmagnet = [];
end
%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No permanent magnet to add!']);
end
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------

if isempty(id_design3d)
    id_design3d = fieldnames(c3dobj.design3d);
    id_design3d = id_design3d{1};
end

if isempty(id_pmagnet)
    error([mfilename ': id_pmagnet must be defined !'])
end

if isempty(id_dom3d)
    error([mfilename ': id_dom3d must be given !'])
end

%--------------------------------------------------------------------------
c3dobj.design3d.(id_design3d).pmagnet.(id_pmagnet).id_dom3d = id_dom3d;
c3dobj.design3d.(id_design3d).pmagnet.(id_pmagnet).id_elem  = id_elem;
c3dobj.design3d.(id_design3d).pmagnet.(id_pmagnet).mur      = mur;
c3dobj.design3d.(id_design3d).pmagnet.(id_pmagnet).br_value = br_value;
c3dobj.design3d.(id_design3d).pmagnet.(id_pmagnet).br_ori   = br_ori;
c3dobj.design3d.(id_design3d).pmagnet.(id_pmagnet).id_bcon  = id_bcon;
% --- info message
fprintf(['Add pmagnet #' id_pmagnet ' to design3d #' id_design3d '\n']);




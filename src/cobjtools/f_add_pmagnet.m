function c3dobj = f_add_pmagnet(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_dom3d','id_pmagnet','br_value','br_dir',...
           'br_array','id_bcon'};

% --- default input value
id_emdesign3d = [];
id_dom3d      = [];
br_value      = 0;
br_dir        = [];
br_array      = [];
id_bcon       = [];
id_pmagnet    = [];
%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No permanent magnet to add!']);
end
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_emdesign3d)
    id_emdesign3d = fieldnames(c3dobj.emdesign3d);
    id_emdesign3d = id_emdesign3d{1};
end
%--------------------------------------------------------------------------
if isempty(id_pmagnet)
    error([mfilename ': id_pmagnet must be defined !'])
end
%--------------------------------------------------------------------------
if isempty(id_dom3d)
    error([mfilename ': id_dom3d must be given !'])
end
%--------------------------------------------------------------------------
c3dobj.emdesign3d.(id_emdesign3d).pmagnet.(id_pmagnet).id_emdesign3d = id_emdesign3d;
c3dobj.emdesign3d.(id_emdesign3d).pmagnet.(id_pmagnet).id_dom3d = id_dom3d;
c3dobj.emdesign3d.(id_emdesign3d).pmagnet.(id_pmagnet).br_value = br_value;
c3dobj.emdesign3d.(id_emdesign3d).pmagnet.(id_pmagnet).br_dir   = br_dir;
c3dobj.emdesign3d.(id_emdesign3d).pmagnet.(id_pmagnet).id_bcon  = id_bcon;
% --- status
c3dobj.emdesign3d.(id_emdesign3d).pmagnet.(id_pmagnet).to_be_rebuilt = 1;
% --- info message
fprintf(['Add pmagnet #' id_pmagnet ' to emdesign3d #' id_emdesign3d '\n']);




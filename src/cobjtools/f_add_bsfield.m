function c3dobj = f_add_bsfield(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_bsfield','id_mesh3d','id_dom3d','bs'};

% --- default input value
id_emdesign3d = [];
id_mesh3d     = [];
id_dom3d      = [];
bs            = 0;
id_bsfield    = [];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No bsfield to add!']);
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

if isempty(id_mesh3d)
    id_mesh3d = c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d;
    id_mesh3d = id_mesh3d{1};
end

if isempty(id_bsfield)
    error([mfilename ': id_bsfield must be defined !'])
end

if isempty(id_dom3d)
    error([mfilename ': id_dom3d must be given !'])
end

%--------------------------------------------------------------------------
% --- Output
c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_bsfield).id_mesh3d = id_mesh3d;
c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_bsfield).id_dom3d = id_dom3d;
c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_bsfield).bs = bs;
% --- info message
fprintf(['Add bsfield #' id_bsfield ' to emdesign3d #' id_emdesign3d ' in mesh3d #' id_mesh3d '\n']);




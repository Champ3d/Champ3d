function c3dobj = f_add_thdesign3d(c3dobj,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_mesh3d','id_thdesign'};

% --- default input value
id_mesh3d = [];
id_thdesign = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if isempty(id_mesh3d)
    id_mesh3d = fieldnames(c3dobj.mesh3d);
    id_mesh3d = id_mesh3d{1};
end
%--------------------------------------------------------------------------
if iscell(id_mesh3d)
    if length(id_mesh3d) > 1
        error([mfilename ' : only one mesh3d allowed !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_thdesign)
    id_thdesign = 'thdesign_01';
end
%--------------------------------------------------------------------------
c3dobj.thdesign.(id_thdesign).id_mesh3d = id_mesh3d;
c3dobj.emdesign.(id_emdesign).dimension = 3;
% ---
c3dobj.thdesign.(id_thdesign).fields.tempv = [];
c3dobj.thdesign.(id_thdesign).fields.temps = [];
%--------------------------------------------------------------------------
% --- Log message
if iscell(id_mesh3d)
    f_fprintf(0,'Add #thdesign',1,id_thdesign,0,'with #mesh3d',1,id_mesh3d,0,'\n');
elseif ischar(id_mesh3d)
    f_fprintf(0,'Add #thdesign',1,id_thdesign,0,'with #mesh3d',1,id_mesh3d,0,'\n');
else
    f_fprintf(0,'Add #thdesign',1,id_thdesign,0,'\n');
end





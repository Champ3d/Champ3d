function c3dobj = f_add_nomesh(c3dobj,varargin)
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
arglist = {'id_emdesign','id_dom3d','id_dom2d','id_nomesh'};

% --- default input value
id_emdesign = [];
id_nomesh   = [];
id_dom3d    = [];
id_dom2d    = [];

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
if isempty(id_emdesign)
    id_emdesign = fieldnames(c3dobj.emdesign);
    id_emdesign = id_emdesign{1};
end
%--------------------------------------------------------------------------
if isempty(id_nomesh)
    error([mfilename ': id_nomesh must be defined !'])
end
%--------------------------------------------------------------------------
if isempty(id_dom3d) && isempty(id_dom2d)
    error([mfilename ': id_dom3d/id_dom2d must be defined !'])
end
%--------------------------------------------------------------------------
% --- Output
c3dobj.emdesign.(id_emdesign).nomesh.(id_nomesh).id_emdesign = id_emdesign;
c3dobj.emdesign.(id_emdesign).nomesh.(id_nomesh).id_dom3d = id_dom3d;
c3dobj.emdesign.(id_emdesign).nomesh.(id_nomesh).id_dom2d = id_dom2d;
% --- status
c3dobj.emdesign.(id_emdesign).nomesh.(id_nomesh).to_be_rebuilt = 1;
% --- info message
f_fprintf(0,'Add #nomesh',1,id_nomesh,0,'to #emdesign',1,id_emdesign,0,'\n');


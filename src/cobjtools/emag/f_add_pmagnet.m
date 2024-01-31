function c3dobj = f_add_pmagnet(c3dobj,varargin)
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
arglist = {'id_emdesign','id_dom3d','id_dom2d','id_pmagnet',...
           'br_value','br_dir',...
           'br'};

% --- default input value
id_emdesign = [];
id_dom3d    = [];
id_dom2d    = [];
br_value    = 0;
br_dir      = [];
br          = [];
mu_r        = 1;
id_pmagnet  = [];
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
if isempty(id_emdesign)
    id_emdesign = fieldnames(c3dobj.emdesign);
    id_emdesign = id_emdesign{1};
end
%--------------------------------------------------------------------------
if isempty(id_pmagnet)
    error([mfilename ': id_pmagnet must be defined !'])
end
%--------------------------------------------------------------------------
if isempty(id_dom3d) && isempty(id_dom2d)
    error([mfilename ': id_dom3d/id_dom2d must be given !'])
end
%--------------------------------------------------------------------------
c3dobj.emdesign.(id_emdesign).pmagnet.(id_pmagnet).id_emdesign = id_emdesign;
c3dobj.emdesign.(id_emdesign).pmagnet.(id_pmagnet).id_dom3d = id_dom3d;
c3dobj.emdesign.(id_emdesign).pmagnet.(id_pmagnet).id_dom2d = id_dom2d;
c3dobj.emdesign.(id_emdesign).pmagnet.(id_pmagnet).br_value = br_value;
c3dobj.emdesign.(id_emdesign).pmagnet.(id_pmagnet).br_dir   = br_dir;
c3dobj.emdesign.(id_emdesign).pmagnet.(id_pmagnet).br       = br;
c3dobj.emdesign.(id_emdesign).pmagnet.(id_pmagnet).mu_r     = mu_r;
% --- status
c3dobj.emdesign.(id_emdesign).pmagnet.(id_pmagnet).to_be_rebuilt = 1;
% --- info message
f_fprintf(0,'Add #pmagnet',1,id_pmagnet,0,'to #emdesign',1,id_emdesign,0,'\n');




function c3dobj = f_add_embc(c3dobj,varargin)
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
arglist = {'id_emdesign','id_bc','id_dom3d','id_dom2d',...
           'bc_type','bc_value','bs', ...
           'sigma','mu_r','r_ht','r_et'};

% --- default input value
id_emdesign = [];
id_dom3d    = [];
id_dom2d    = [];
bc_type     = []; % 'fixed', 'bsfield', 'neumann', 'sibc'
bc_value    = 0 ; % for 'fixed'
bs          = []; % for 'bsfield'
sigma       = 0 ; % for 'sibc'
mu_r        = 0 ; % for 'sibc'
r_ht        = []; % for 'sibc'
r_et        = []; % for 'sibc'
id_bc = [];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No #bc to add!']);
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
if isempty(id_bc)
    error([mfilename ': id_bc must be defined !'])
end
%--------------------------------------------------------------------------
if isempty(id_dom3d) && isempty(id_dom2d)
    error([mfilename ': id_dom3d/id_dom2d must be given !'])
end
%--------------------------------------------------------------------------
if isempty(bc_type)
    bc_type = 'fixed';
end
%--------------------------------------------------------------------------
% --- Output
c3dobj.emdesign.(id_emdesign).bc.(id_bc).id_emdesign = id_emdesign;
c3dobj.emdesign.(id_emdesign).bc.(id_bc).id_dom3d = id_dom3d;
c3dobj.emdesign.(id_emdesign).bc.(id_bc).id_dom2d = id_dom2d;
c3dobj.emdesign.(id_emdesign).bc.(id_bc).bc_type  = bc_type;
c3dobj.emdesign.(id_emdesign).bc.(id_bc).bc_value = bc_value;
c3dobj.emdesign.(id_emdesign).bc.(id_bc).bs       = bs;        % for 'bsfield'
c3dobj.emdesign.(id_emdesign).bc.(id_bc).sigma    = sigma ; % for 'sibc'
c3dobj.emdesign.(id_emdesign).bc.(id_bc).mu_r     = mu_r ; % for 'sibc'
c3dobj.emdesign.(id_emdesign).bc.(id_bc).r_ht     = r_ht; % for 'sibc'
c3dobj.emdesign.(id_emdesign).bc.(id_bc).r_et     = r_et; % for 'sibc'
% --- status
c3dobj.emdesign.(id_emdesign).bc.(id_bc).to_be_rebuilt = 1;
% --- info message
f_fprintf(0,'Add #bc',1,id_bc,0,'to #emdesign',1,id_emdesign,0,'\n');
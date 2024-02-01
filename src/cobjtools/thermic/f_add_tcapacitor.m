function c3dobj = f_add_tcapacitor(c3dobj,varargin)
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
arglist = {'id_thdesign','id_tcapacitor','id_dom3d','id_dom2d','id_elem',...
           'rho','cp'};

% --- default input value
id_thdesign = [];
id_dom3d = [];
id_dom2d = [];
rho      = [];
cp       = [];
id_tcapacitor = [];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No tcapacitor to add!']);
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
if isempty(id_thdesign)
    id_thdesign = fieldnames(c3dobj.thdesign);
    id_thdesign = id_thdesign{1};
end
%--------------------------------------------------------------------------
if isempty(id_tcapacitor)
    error([mfilename ': id_tcapacitor must be defined !'])
end
%--------------------------------------------------------------------------
if isempty(id_dom3d) && isempty(id_dom2d)
    error([mfilename ': id_dom3d/id_dom2d must be given !'])
end
%--------------------------------------------------------------------------
% --- Output
c3dobj.thdesign.(id_thdesign).tcapacitor.(id_tcapacitor).id_thdesign = id_thdesign;
c3dobj.thdesign.(id_thdesign).tcapacitor.(id_tcapacitor).id_dom3d = id_dom3d;
c3dobj.thdesign.(id_thdesign).tcapacitor.(id_tcapacitor).id_dom2d = id_dom2d;
c3dobj.thdesign.(id_thdesign).tcapacitor.(id_tcapacitor).rho = rho;
c3dobj.thdesign.(id_thdesign).tcapacitor.(id_tcapacitor).cp = cp;
% --- status
c3dobj.thdesign.(id_thdesign).tcapacitor.(id_tcapacitor).to_be_rebuilt = 1;
% --- info message
f_fprintf(0,'Add #tcapacitor',1,id_tcapacitor,0,'to #thdesign',1,id_thdesign,0,'\n');




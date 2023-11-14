function c3dobj = f_add_airbox(c3dobj,varargin)
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
arglist = {'id_emdesign','id_airbox','id_dom3d','id_dom2d'};

% --- default input value
id_emdesign = [];
id_dom3d    = [];
id_dom2d    = [];
id_airbox   = [];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No airbox to add!']);
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
if isempty(id_airbox)
    error([mfilename ': id_airbox must be defined !'])
end
if isempty(id_dom3d) && isempty(id_dom2d)
    id_dom3d = 'all_domain';
    id_dom2d = 'all_domain';
end
%--------------------------------------------------------------------------
% --- Output
c3dobj.emdesign.(id_emdesign).airbox.(id_airbox).id_emdesign = id_emdesign;
c3dobj.emdesign.(id_emdesign).airbox.(id_airbox).id_dom3d = id_dom3d;
c3dobj.emdesign.(id_emdesign).airbox.(id_airbox).id_dom2d = id_dom2d;
c3dobj.emdesign.(id_emdesign).airbox.(id_airbox).mu_r = 1;
% --- status
c3dobj.emdesign.(id_emdesign).airbox.(id_airbox).to_be_rebuilt = 1;
% --- info message
f_fprintf(0,'Add #airbox',1,id_airbox,0,'to #emdesign',1,id_emdesign,0,'\n');

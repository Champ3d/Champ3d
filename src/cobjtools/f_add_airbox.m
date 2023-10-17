function c3dobj = f_add_airbox(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_airbox','id_dom3d','a_value'};

% --- default input value
id_emdesign3d = [];
id_dom3d      = [];
a_value       = 0;
id_airbox     = [];

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
if isempty(id_emdesign3d)
    id_emdesign3d = fieldnames(c3dobj.emdesign3d);
    id_emdesign3d = id_emdesign3d{1};
end
%--------------------------------------------------------------------------
if isempty(id_airbox)
    error([mfilename ': id_airbox must be defined !'])
end
if isempty(id_dom3d)
    id_dom3d = 'all_domain';
end
%--------------------------------------------------------------------------
% --- Output
c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox).id_emdesign3d = id_emdesign3d;
c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox).id_dom3d = id_dom3d;
c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox).mu_r = 1;
c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox).a_value = a_value;
% --- status
c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox).to_be_rebuilt = 1;
% --- info message
fprintf(['Add airbox #' id_airbox ' to emdesign3d #' id_emdesign3d '\n']);

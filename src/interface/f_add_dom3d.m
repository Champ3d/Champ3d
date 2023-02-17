function design3d = f_add_dom3d(design3d,varargin)
% XXX 
%--------------------------------------------------------------------------
% FIXED INPUT
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%--------------------------------------------------------------------------
% OUTPUT
%--------------------------------------------------------------------------
% EXAMPLE
% design3d = F_ADD_DOM3D(design3d,'id','D1','id_dom3d',1);
% design3d = F_ADD_DOM3D(design3d,'id','D2','id_dom2d',[2 3 4 5 6 7 8 9 10 11],...
%                                 'id_layer',{'layer_1','layer_2'});
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------


% --- valid argument list (to be updated each time modifying function)
arglist = {'design3d','id_dom3d','defined_on','id_dom2d','id_layer','id','id_elem'};

% --- default input value
if isfield(design3d,'dom3d')
    if isfield(design3d.dom3d,'nbDom')
        design3d.dom3d.nbDom = design3d.dom3d.nbDom + 1;
    else
        design3d.dom3d.nbDom = 1;
    end
else
    design3d.dom3d.nbDom = 1;
end

id_dom3d = ['d3d' num2str(design3d.dom3d.nbDom)];
id_dom2d = [];
id_layer = [];
id = []; % id in the imported meshes
id_elem = [];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

% --- clean id (remove spaces)
id_dom3d = strrep(id_dom3d,' ','');


%--------------------------------------------------------------------------
design3d.dom3d.(id_dom3d) = [];
if ~isempty(id_dom2d) && ~isempty(id_layer)
    design3d.dom3d.(id_dom3d).id_elem = f_findelem(design3d.mesh,...
                                             'id_dom2d',id_dom2d,...
                                             'id_layer',id_layer);
elseif ~isempty(id)
    design3d.dom3d.(id_dom3d).id_elem = f_findelem(design3d.mesh,...
                                             'id_dom3d',id);
else
    design3d.dom3d.(id_dom3d).id_elem = id_elem;
end














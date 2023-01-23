%=========================================================================%
% Conductors properties:
% dom2D
% sigma (tensor 3x3)
% orientation (?)
% 
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

function dom3d = f_add_sfield(dom3d,varargin)

%--------------------------------------------------------------------------
if isempty(dom3d)
    dom3d.sfield = [];
end
%--------------------------------------------------------------------------
if ~isfield(dom3d,'sfield')
    iec = 0;
else
    iec = length(dom3d.sfield);
end
%--------------------------------------------------------------------------
if nargin <= 1
    disp('No source field to add!');
    return
end
%--------------------------------------------------------------------------
datin = [];
datin.id_elem = [];
for i = 1:(nargin-1)/2
    datin.(varargin{2*i-1}) = varargin{2*i};
    dom3d.sfield(iec+1).(varargin{2*i-1}) = varargin{2*i};
end

%--------------------------------------------------------------------------
mesher = dom3d.mesh.mesher;
switch mesher
    case {'prism2dto3d','hexa2dto3d'}
        if strcmpi(datin.defined_on,'elem')
            if strcmpi(datin.id_elem, ':')
                dom3d.sfield(iec+1).id_elem = 1:dom3d.mesh.nbElem;
            else
                dom3d.sfield(iec+1).id_elem = ...
                    f_findelem(dom3d.mesh,'defined_on','elem',...
                                          'id_dom2d',datin.id_dom2d,...
                                          'id_layer',datin.id_layer);
            end
        end
        if strcmpi(datin.defined_on,'face')
            dom3d.sfield(iec+1).id_elem = ...
                f_findelem(dom3d.mesh,'defined_on','elem',...
                                      'id_dom2d',datin.id_dom2d,...
                                      'id_layer',datin.id_layer);
        end
    case 'xxx'
end






























% %--------------------------------------------------------------------------
% if isempty(dom3d)
%     dom3d.sfield = [];
% end
% %--------------------------------------------------------------------------
% if ~isfield(dom3d,'sfield')
%     iec = 0;
% else
%     iec = length(dom3d.sfield);
% end
% %--------------------------------------------------------------------------
% if nargin <= 1
%     disp('No source field to add!');
%     return
% end
% %--------------------------------------------------------------------------
% datin = [];
% for i = 1:(nargin-1)/2
%     datin.(varargin{2*i-1}) = varargin{2*i};
%     dom3d.sfield(iec+1).(varargin{2*i-1}) = varargin{2*i};
% end
% 
% end




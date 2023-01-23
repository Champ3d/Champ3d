function dom3D = f_add_bound(dom3D,varargin)
% F_ADD_BCON ...
%--------------------------------------------------------------------------
% dom3D = F_ADD_BCON(dom3D,'defined_on','face','id_elem',':','bc_type','fixed','bc_value',0);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

if isempty(dom3D)
    dom3D.bound = [];
end

if ~isfield(dom3D,'bound')
    iec = 0;
else
    iec = length(dom3D.bound);
end

if nargin <= 1
    disp('No conductor to add!');
else
    datin = [];
    for i = 1:(nargin-1)/2
        datin.(varargin{2*i-1}) = varargin{2*i};
        dom3D.bound(iec+1).(varargin{2*i-1}) = varargin{2*i};
    end
    
    mesher = dom3D.mesh.mesher;
    
    switch mesher
        case 'prism2D3DMatlab'
            if strcmpi(datin.defined_on,'elem')
                dom3D.bound(iec+1).id_elem = ...
                    f_findelem(dom3D.mesh,'defined_on','elem',...
                    'IDdom2D',datin.IDdom2D,'IDLayer',datin.IDLayer);
            end
            if strcmpi(datin.defined_on,'bound')
                if isfield(datin,'IDFace')
                    dom3D.bound(iec+1).IDFace = datin.IDFace;
                else
                    dom3D.bound(iec+1).id_elem = ...
                        f_findelem(dom3D.mesh,'defined_on','bound',...
                        'IDdom2D',datin.IDdom2D,'IDLayer',datin.IDLayer);
                end
            end
        case 'xxx'
    end
end




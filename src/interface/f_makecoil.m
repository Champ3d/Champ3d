function [dom3d,varargout] = f_makecoil(dom3d,varargin)
% F_MAKECOIL returns the r.h.s matrix related to the source coil.
%--------------------------------------------------------------------------
% cRHS = F_MAKECOIL(dom3D);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% for i = 1:(nargin-1)/2
%     eval([varargin{2*i-1} '= varargin{2*i};']);
% end

%--------------------------------------------------------------------------
nb_coil = length(dom3d.coil);
dom3d.APhi.coilRHS = zeros(dom3d.mesh.nbEdge,1);
for i = 1:nb_coil
    coil_model = lower(dom3d.coil(i).coil_model);
    switch coil_model
        case 't1'
            cfield = f_makecoilt1(dom3d.mesh,dom3d.coil(i),dom3d.bcon(dom3d.coil(i).id_bcon));
            dom3d.coil(i).N  = cfield.N;
            if strcmpi(dom3d.coil(i).coil_mode,'transmitter')
                dom3d.coil(i).Js = cfield.Js;
                dom3d.APhi.coilRHS = dom3d.APhi.coilRHS + cfield.cRHS;
            end
        case 't2'
            cfield = f_makecoilt2(dom3d.mesh,dom3d.coil(i),dom3d.bcon(dom3d.coil(i).id_bcon));
            dom3d.coil(i).N  = cfield.N;
            if strcmpi(dom3d.coil(i).coil_mode,'transmitter')
                dom3d.coil(i).Js = cfield.Js;
                dom3d.APhi.coilRHS = dom3d.APhi.coilRHS + cfield.cRHS;
            end
        case 't3'
        case 't4'
            cfield = f_makecoilt4(dom3d.mesh,dom3d.coil(i),dom3d.bcon(dom3d.coil(i).id_bcon));
            dom3d.coil(i).N  = cfield.N;
            if strcmpi(dom3d.coil(i).coil_mode,'transmitter')
                dom3d.coil(i).Js = cfield.Js;
                dom3d.APhi.coilRHS = dom3d.APhi.coilRHS + cfield.cRHS;
            end
        otherwise
    end
end
end
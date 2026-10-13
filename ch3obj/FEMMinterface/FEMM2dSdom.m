%--------------------------------------------------------------------------
% Interface to FEMM
% FEMM (c) David Meeker 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FEMM2dSdom < Xhandle
    properties
        % ---
        parent_model
    end
    % --- Constructor
    methods
        function obj = FEMM2dSdom()
            obj@Xhandle
        end
    end
    % --- Methods/public
    methods (Access = public)
        function choose(obj)
            % choose the dom
        end
        function get(obj,quantity_name)
            % get point quantities
            arguments
                obj
                quantity_name
            end
            A vector potential A or flux φ
            B1 flux density Bx if planar, Br if axisymmetric
            B2 flux density By if planar, Bz if axisymmetric
            Sig electrical conductivity σ
            E stored energy density
            H1 field intensity Hx if planar, Hr if axisymmetric
            H2 field intensity Hy if planar, Hz if axisymmetric
            Je eddy current density
            Js source current density
            Mu1 relative permeability µx if planar, µr if axisymmetric
            Mu2 relative permeability µy if planar, µz if axisymmetric
            Pe Power density dissipated through ohmic losses
            Ph Power density dissipated by hysteresis
        end
    end
    % --- Methods/protected
    methods (Access = protected)
    end
    % --- Methods/private
    methods (Access = private)
    end
end
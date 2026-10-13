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

classdef FEMM2dCircuit < Xhandle
    properties
        id_circuit
        i
        turn_connexion
        % ---
        parent_model
    end
    properties (Hidden)
        coil_wire_type;
    end
    properties %(Dependent)
        quantity
    end
    % --- Constructor
    methods
        function obj = FEMM2dCircuit(args)
            arguments
                args.i
                args.turn_connexion {mustBeMember(args.turn_connexion,{'series','parallel'})} = 'series'
            end
            % ---
            obj@Xhandle
            % ---
            obj <= args;
        end
    end
    % --- Methods/get
    methods
        function get_quantity(obj)
            % ---
            try
                mi_loadsolution;
            catch
                obj.parent_model.open;
            end
            % ---
            obj.quantity = [];
            cirpro = mo_getcircuitproperties(obj.id_circuit);
            I = cirpro(1);
            flux_linkage = cirpro(3);
            % ---
            %V = cirpro(2);
            V = +1j*2*pi*obj.parent_model.fr*flux_linkage; % '+' receiver, '-' transmitter
            % --- TODO
            %if any(f_strcmpi(obj.coil_wire_type,{'insulated_round_section','Litz'}))
            %    V = -1j * V;
            %end
            % ---
            phi_I = angle(I);
            phi_V = angle(V);
            cosPhi = cos(phi_V - phi_I);
            % ---
            Irms = abs(I)/sqrt(2);
            Vrms = abs(V)/sqrt(2);
            % ---
            Z = V / I;
            R = real(Z);
            X = imag(Z);
            % ---
            fr = obj.parent_model.fr;
            if fr == 0
                L = real(flux_linkage / I);
            else
                L = X/(2*pi*fr);
            end
            % ---
            P = real(R * Irms^2);
            Q = real(X * Irms^2);
            % ---
            obj.quantity.I = I;
            obj.quantity.V = V;
            obj.quantity.phi_I = phi_I/pi*180;
            obj.quantity.phi_V = phi_V/pi*180;
            obj.quantity.dphi_VI = obj.quantity.phi_V - obj.quantity.phi_I;
            obj.quantity.Irms = Irms;
            obj.quantity.Vrms = Vrms;
            obj.quantity.cosPhi = cosPhi;
            obj.quantity.Z = Z;
            obj.quantity.R = R;
            obj.quantity.X = X;
            obj.quantity.L = L;
            obj.quantity.fr = fr;
            obj.quantity.P = P;
            obj.quantity.Q = Q;
            obj.quantity.flux_linkage = flux_linkage;
        end
    end
    % --- Methods/public
    methods (Access = public)
        function setup(obj)
            % ---
            cirtype = obj.get_circuit_type_femm_id;
            % -------------------------------------------------------------
            mi_deletecircuit(obj.id_circuit);
            mi_addcircprop(obj.id_circuit,obj.i,cirtype);
            % -------------------------------------------------------------
        end
    end
    % --- Methods/protected
    methods (Access = protected)
    end
    % --- Methods/protected
    methods (Access = private)
        function ctype_femm_id = get_circuit_type_femm_id(obj)
            switch obj.turn_connexion
                case 'series'
                    ctype_femm_id = 1;
                case 'parallel'
                    ctype_femm_id = 0;
            end
        end
    end
end
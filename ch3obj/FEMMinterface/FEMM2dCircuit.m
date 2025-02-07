%--------------------------------------------------------------------------
% Interface to FEMM
% FEMM (c) David Meeker 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
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
    properties (Dependent)
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
        function val = get.quantity(obj)
            mi_loadsolution;
            val = [];
            cirpro = mo_getcircuitproperties(obj.id_circuit);
            I = cirpro(1);
            V = cirpro(2);
            flux_linkage = cirpro(3);
            % --- TODO
            %if any(f_strcmpi(obj.coil_wire_type,{'insulated_round_section','Litz'}))
            %    V = -1j * V;
            %end
            % ---
            phi_i = angle(I);
            phi_v = angle(V);
            cosPhi = cos(phi_v - phi_i);
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
            val.I = I;
            val.V = V;
            val.Irms = Irms;
            val.Vrms = Vrms;
            val.cosPhi = cosPhi;
            val.Z = Z;
            val.R = R;
            val.X = X;
            val.L = L;
            val.fr = fr;
            val.P = P;
            val.Q = Q;
            val.flux_linkage = flux_linkage;
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
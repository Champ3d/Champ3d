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
classdef FEMM2dWire < FEMM2dMaterial
    properties
        wire_type
    end
    properties (Hidden)
        id_wire_type
    end
    % --- Constructor
    methods
        function obj = FEMM2dWire(args)
            arguments
                args.wire_type {mustBeMember(args.wire_type,...
                    {'no_loss','massive','insulated_round_section','Litz','stranded_square_section'})}
                args.sigma
                args.nb_strand
                args.wire_diameter
            end
            % ---
            if ~isfield(args,'wire_type')
                error('wire_type must be given');
            end
            % ---
            obj@FEMM2dMaterial;
            obj <= args;
            % ---
        end
    end
    % --- Methods/public
    methods (Access = public)
        function setup(obj,id_material)
            % ---
            obj.get_id_wire_type;
            % ---
            mi_deletematerial(id_material);
            mi_addmaterial(id_material,...
                           1,...
                           1,...
                           0,...
                           0,...
                           obj.sigma/1e6,...
                           0,...
                           0,...
                           0,...
                           obj.id_wire_type,...
                           0,...
                           0,...
                           obj.nb_strand,...
                           obj.wire_diameter);
        end
        % -----------------------------------------------------------------
        function get_id_wire_type(obj)
            switch obj.wire_type
                case 'no_loss'
                    obj.id_wire_type = 0;
                case 'massive'
                    obj.id_wire_type = 0;
                case {'insulated_round_section','Litz'}
                    obj.id_wire_type = 5;
                case 'stranded_square_section'
                    obj.id_wire_type = 6;
            end
        end
    end
    % --- Methods/protected
    methods (Access = protected)
        
    end
end
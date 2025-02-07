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
classdef FEMM2dPMagnet < FEMM2dMaterial
    properties

    end
    % --- Constructor
    methods
        function obj = FEMM2dPMagnet(args)
            arguments
                args.mur      = 1;
                args.mur_x    = [];
                args.mur_y    = [];
                args.br       = 0;
                args.hc       = [];
                % ---
                args.b_data = [];
                args.h_data = [];
            end
            % -------------------------------------------------------------
            if isempty(args.mur_x)
                args.mur_x = args.mur;
            end
            if isempty(args.mur_y)
                args.mur_y = args.mur;
            end
            if isempty(args.hc)
                args.hc = args.br/(4*pi*1e-7 * args.mur);
            end
            if args.hc == 0 || args.br == 0
                warning('hc or br are zero');
            end
            % -------------------------------------------------------------
            obj@FEMM2dMaterial;
            % ---
            obj <= args;
        end
    end
    % --- Methods/public
    methods (Access = public)
        function setup(obj,id_material)
            % -------------------------------------------------------------
            mi_deletematerial(id_material);
            mi_addmaterial(id_material,...
                           obj.mur_x,...
                           obj.mur_y,...
                           obj.hc,...
                           0,...
                           0,...
                           0,...
                           0,...
                           0,...
                           0,...
                           0,...
                           0,...
                           0,...
                           0);
            % -------------------------------------------------------------
            if (~isempty(obj.b_data) && ~isempty(obj.h_data))
                b = f_tocolv(obj.b_data);
                h = f_tocolv(obj.h_data);
                mi_clearbhpoints(id_material);
                mi_addbhpoints(id_material,b,h);
            end
            % -------------------------------------------------------------
        end
    end
end
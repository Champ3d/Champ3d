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
% From FEMM documentation (with minor modifications) :
% - id_material Material name
% - mur x Relative permeability in the x- or r-direction.
% - mur y Relative permeability in the y- or z-direction.
% - Hc Permanent magnet coercivity in Amps/Meter.
% - J Applied source current density in Amps/m2.
% - sigma Electrical conductivity of the material in S/m.
% - Lam_d Lamination thickness in millimeters.
% - Phi_hmax Hysteresis lag angle in degrees, used for nonlinear BH curves.
% - Lam_fill Fraction of the volume occupied per lamination that is actually
%       filled with iron (Note that this parameter defaults to 1 in the 
%       femm preprocessor dialog box because, by default, iron completely 
%       fills the volume)
% - Lamtype Set to
%   + 0 ? Not laminated or laminated in plane
%   + 1 ? laminated x or r
%   + 2 ? laminated y or z
%   + 3 ? magnet wire
%   + 4 ? plain stranded wire
%   + 5 ? Litz wire
%   + 6 ? square wire
% - Phi_hx Hysteresis lag in degrees in the x-direction for linear problems.
% - Phi_hy Hysteresis lag in degrees in the y-direction for linear problems.
% - nb_strand Number of strands in the wire build. Should be 1 for Magnet or Square wire.
% - wire_diameter Diameter of each of the wire?s constituent strand in meters.
%--------------------------------------------------------------------------
classdef FEMM2dMaterial < Xhandle
    properties
        mur = 1
        mur_x = 1
        mur_y = 1
        sigma = 0
        lam_d = 0
        phi_hmax = 0
        lam_fill = 0
        material_type = 'not_laminated'
        phi_hx = 0
        phi_hy = 0
        % --- js-coil
        j = 0
        nb_strand = 0;
        wire_diameter = 0;
        % --- pmagnet
        br = 0
        hc = 0
        % ---
        b_data = [];
        h_data = [];
        % ---
        parent_model
    end
    % --- Constructor
    methods
        function obj = FEMM2dMaterial(args)
            arguments
                args.mur      = 1;
                args.mur_x    = [];
                args.mur_y    = [];
                %args.br       = 0;
                %args.hc       = [];
                %args.j        = 0;
                args.sigma    = 0;
                args.lam_d    = 0;
                args.phi_hmax = 0;
                args.lam_fill = 0;
                %args.material_type {mustBeMember(args.material_type,{'not_laminated','laminated_x','laminated_y','pmagnet','plain_stranded_wire','litz_wire','square_wire'})} = 'not_laminated'
                args.material_type {mustBeMember(args.material_type,{'not_laminated','laminated_x','laminated_y'})} = 'not_laminated'
                args.phi_hx   = 0;
                args.phi_hy   = 0;
                %args.nb_strand = 1;
                %args.wire_diameter = 0;
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
%             if isempty(args.hc)
%                 args.hc = args.br/(4*pi*1e-7 * args.mur);
%             end
%             if args.br ~= 0
%                 args.j = 0;
%             end
            % -------------------------------------------------------------
            obj@Xhandle;
            % ---
            obj <= args;
        end
    end
    % --- Methods/public
    methods (Access = public)
        function setup(obj,id_material)
            % -------------------------------------------------------------
            switch obj.material_type
                case 'not_laminated'
                    mattype = 0;
                case 'laminated_x'
                    mattype = 1;
                case 'laminated_y'
                    mattype = 2;
%                 case 'plain_stranded_wire'
%                     mattype = 4;
%                 case 'litz_wire'
%                     mattype = 5;
%                 case 'square_wire'
%                     mattype = 6;
%                 case 'pmagnet'
%                     mattype = 0;
            end
            % -------------------------------------------------------------
            mi_deletematerial(id_material);
            mi_addmaterial(id_material,obj.mur_x,obj.mur_y,0,...
                           0,obj.sigma/1e6,obj.lam_d,obj.phi_hmax,...
                           obj.lam_fill,mattype,obj.phi_hx,obj.phi_hy,...
                           0,0);
            % -------------------------------------------------------------
            if (~isempty(obj.b_data) && ~isempty(obj.h_data))
                b = f_tocolv(obj.b_data);
                h = f_tocolv(obj.h_data);
                mi_clearbhpoints(id_material);
                for i = 1:length(b)
                    mi_addbhpoints(id_material,b(i),h(i));
                end
            end
            % -------------------------------------------------------------
        end
    end
end
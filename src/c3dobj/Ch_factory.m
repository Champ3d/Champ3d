%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Ch_factory < handle

    % --- Constructors
    methods
        function factory = Ch_factory()
            % Call super class
            factory = factory@handle();
        end
    end

    % --- Methods
    % --- mesh classes
    methods
        % -----------------------------------------------------------------
        function lin = line1d(factory,args)
            arguments
                factory
                % ---
                args.id
                args.len
                args.dtype = 'lin'
                args.dnum = 1
                args.flog = 1.05
            end
            % -------------------------------------------------------------
            lin = Line1d('id',args.id,'dtype',args.dtype,'len',args.len,...
                         'dnum',args.dnum,'flog',args.flog);
        end
        % -----------------------------------------------------------------
        function msh = mesh2d(factory,args)
            arguments
                factory
                % --- mesh_type
                args.mesh_type Mesh_type
                % --- quad_mesh_from_1d
                args.xline
                args.yline
                % --- tri_mesh_from_femm
                args.mesh_file
                % --- tri_mesh_from_shape2d
                args.shape2d
                % --- quad_mesh_from_chquad
                % --- tetra_mesh_from_gmsh
                % --- tetra_mesh_from_shape
                % --- prism_mesh_from_chprism
                % --- hex_mesh_from_chhex
            end
            % -------------------------------------------------------------
            switch args.mesh_type
                case "Quad_mesh_from_1d"
                    msh = Quad_mesh_from_1d('xline',args.xline,'yline',args.yline);
                case "Tri_mesh_from_femm"
                    msh = Tri_mesh_from_femm('mesh_file',args.mesh_file);
            end
            % -------------------------------------------------------------
            
            % -------------------------------------------------------------
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function msh = mesh3d(factory,args)
            arguments
                factory
                % --- mesh_type
                args.mesh_type Mesh_type
                % --- tetra_mesh_from_gmsh
                args.mesh_file
                % --- tetra_mesh_from_shape
                % --- prism_mesh_from_chprism
                % --- hex_mesh_from_chhex
                args.mesh2d
                args.zline
            end
            % -------------------------------------------------------------
            switch args.mesh_type
                case "Hexa_mesh_from_chhexa"
                    msh = Hexa_mesh_from_chhexa('mesh2d',args.mesh2d,'zline',args.zline);
                case "Prism_mesh_from_chprism"
                    msh = Prism_mesh_from_chprism();
            end
            % -------------------------------------------------------------
            
            % -------------------------------------------------------------
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function dom = dom2d(factory,args)
            arguments
                factory
                % ---
                args.parent_mesh
                args.xline = []
                args.yline = []
                args.id_code = []
            end
            % ---
            mesh_type = class(args.parent_mesh);
            % ---
            if f_strcmpi(mesh_type,{'quad_mesh_from_1d','tri_mesh_from_femm'})
                dom = Dom2d('parent_mesh',args.parent_mesh,'xline',args.xline,...
                            'yline',args.yline,'id_code',args.id_code);
            elseif f_strcmpi(mesh_type,'tri_mesh_from_femm')
                
            end
        end
        % -----------------------------------------------------------------
        function dom = dom3d(factory,args)
            arguments
                factory
                % ---
                args.defined_on Defined_on = "elem"
                args.parent_mesh
                args.dom2d = []
                args.zline = []
                args.id_code = []
                % ---
            end
            % ---
            mesh_type = class(args.parent_mesh);
            % ---
            if f_strcmpi(mesh_type,{'hexa_mesh_from_chhexa','prism_mesh_from_chprism'})
                dom = Dom3d('parent_mesh',args.parent_mesh,'dom2d',args.dom2d,...
                            'zline',args.zline,'id_code',args.id_code);
            elseif f_strcmpi(mesh_type,'tetra_mesh_from_gmsh')
                
            end
        end
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end

end
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FEM3dAphi < EmModel
    
    % --- Contructor
    methods
        function obj = FEM3dAphi(args)
            arguments
                args.id = 'no_id'
                % ---
                args.parent_multiphysical_model = []
                args.mesh2d_collection = []
                args.mesh3d_collection = []
                args.dom2d_collection = []
                args.dom3d_collection = []
                args.id_mesh2d = []
                args.id_mesh3d = []
                % ---
                args.parent_mesh = []
            end
            % ---
            args = obj.getargs(args);
            % ---
            obj <= args;
        end
    end

    % --- Methods
    methods
        function build_econductor(obj)
            % ---
            allphydom = fieldnames(obj.econductor);
            % ---
            for i = 1:length(allphydom)
                % ---
                id_phydom = allphydom{iec};
                % ---
                phydom = obj.econductor.(id_phydom);
                dom = phydom.dom;
                parent_mesh = dom.parent_mesh;
                gid_elem    = dom.gid_elem;
                %--------------------------------------------------------------
                elem = parent_mesh.elem(:,gid_elem);
                %--------------------------------------------------------------
                id_node_phi = f_uniquenode(elem);
                %----------------------------------------------------------
                %coef_name  = 'sigma';
                %coef_array = f_callcoefficient(c3dobj,'phydomobj',phydomobj,...
                %    'coefficient',coef_name);
                coef_array = 1;
                %----------------------------------------------------------
                sigmawewe = f_cwewe(c3dobj,'phydomobj',phydomobj,...
                    'coefficient',coef_array);
                %----------------------------------------------------------
                % --- Output
                c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).id_elem = id_elem;
                c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).sigma_array = coef_array;
                c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).sigmawewe = sigmawewe;
                c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).id_node_phi = id_node_phi;
                %----------------------------------------------------------
                coeftype = f_coeftype(phydomobj.(coef_name));
            end
        end
    end
end
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
                args.parent_mesh = []
            end
            % ---
            argu = f_to_namedarg(args);
            obj = obj@EmModel(argu{:});
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
                id_phydom = allphydom{i};
                % ---
                phydom = obj.econductor.(id_phydom);
                dom__ = phydom.dom;
                for j = 1:length(dom__)
                    dom = dom__{i};
                    parent_mesh = dom.parent_mesh;
                    gid_elem    = dom.gid_elem;
                    %------------------------------------------------------
                    elem = parent_mesh.elem(:,gid_elem);
                    %------------------------------------------------------
                    id_node_phi = f_uniquenode(elem);
                    %------------------------------------------------------
                    sigma_array = obj.econductor.(id_phydom).sigma.evaluate_on(dom);
                    %------------------------------------------------------
                    %sigmawewe = parent_mesh.cwewe('id_elem',gid_elem,'coefficient',sigma_array);
                    %------------------------------------------------------
                    % %----------------------------------------------------
                    % sigmawewe = f_cwewe(c3dobj,'phydomobj',phydomobj,...
                    %     'coefficient',coef_array);
                    % %----------------------------------------------------
                    % % --- Output
                    % c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).id_elem = id_elem;
                    % c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).sigma_array = coef_array;
                    % c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).sigmawewe = sigmawewe;
                    % c3dobj.emdesign.(id_emdesign).econductor.(id_phydom).id_node_phi = id_node_phi;
                    % %----------------------------------------------------
                    % coeftype = f_coeftype(phydomobj.(coef_name));
                end
            end
        end
    end
end
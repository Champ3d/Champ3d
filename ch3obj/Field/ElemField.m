%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ElemField < Xhandle
    % --- Contructor
    methods
        function obj = ElemField()
            obj = obj@Xhandle;
        end
    end
    % --- get
    methods
        % -----------------------------------------------------------------
        function val = cnode(obj,id_elem)
            % ---
            if nargin <= 1
                id_elem = 1:obj.parent_model.parent_mesh.nb_elem;
            end
            % ---
            val = obj.parent_model.parent_mesh.celem(:,id_elem);
        end
        % -----------------------------------------------------------------
        function val = inode(obj,id_elem)
            % ---
            if nargin <= 1
                id_elem = 1:obj.parent_model.parent_mesh.nb_elem;
            end
            % ---
            if length(id_elem) == obj.parent_model.parent_mesh.nb_elem
                val = obj.parent_model.parent_mesh.prokit.node;
            else
                for i = 1:length(obj.parent_model.parent_mesh.prokit.node)
                    val{i} = obj.parent_model.parent_mesh.prokit.node{i}(id_elem,:);
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        function val = gnode(obj,id_elem)
            % ---
            if nargin <= 1
                id_elem = 1:obj.parent_model.parent_mesh.nb_elem;
            end
            % ---
            if length(id_elem) == obj.parent_model.parent_mesh.nb_elem
                val = obj.parent_model.parent_mesh.intkit.node;
            else
                for i = 1:length(obj.parent_model.parent_mesh.intkit.node)
                    val{i} = obj.parent_model.parent_mesh.intkit.node{i}(id_elem,:);
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
    end
end
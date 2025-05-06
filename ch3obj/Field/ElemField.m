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
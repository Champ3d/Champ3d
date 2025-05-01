%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef VectorFaceField < Xhandle
    % --- Contructor
    methods
        function obj = VectorFaceField()
            obj = obj@Xhandle;
        end
    end
    % --- get
    methods
        % -----------------------------------------------------------------
        function val = cnode(obj,id_face)
            % ---
            if nargin <= 1
                id_face = 1:obj.parent_model.parent_mesh.nb_face;
            end
            % ---
            val = obj.parent_model.parent_mesh.cface(:,id_face);
        end
        % -----------------------------------------------------------------
        % function val = inode(obj,id_elem)
        % end
        % -----------------------------------------------------------------
        % function val = gnode(obj,id_elem)
        % end
        % -----------------------------------------------------------------
    end
    % --- plot - XTODO
    methods
        % -----------------------------------------------------------------
        function plot(obj,args)
        end
    end
end
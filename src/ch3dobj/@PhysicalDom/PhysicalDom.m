%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef PhysicalDom < Xhandle
    properties
        id
        dom
        matrix
        to_be_rebuild
    end
    % ---
    properties
        parent_model
        parent_mesh
        id_dom2d
        id_dom3d
    end
    % ---
    properties(Access = private, Hidden)

    end
    % ---

    % --- Contructor
    methods
        function obj = PhysicalDom(args)
            obj = obj@Xhandle;
            obj <= args;
            obj.get_geodom;
            obj.to_be_rebuild = 1;
        end
    end

    % --- Methods
    methods
        function get_geodom(obj)
            if ~isempty(obj.parent_model)
                if ~isempty(obj.parent_model.parent_mesh)
                    % ---
                    if ~isempty(obj.id_dom3d)
                        id_dom_ = f_to_scellargin(obj.id_dom3d);
                    elseif ~isempty(obj.id_dom2d)
                        id_dom_ = f_to_scellargin(obj.id_dom2d);
                    end
                    % ---
                    %obj.dom = cell(1,length(id_dom_));
                    %for i = 1:length(id_dom_)
                    %    obj.dom{i} = obj.parent_model.parent_mesh.dom.(id_dom_{i});
                    %end
                    % ---
                    obj.dom = obj.parent_model.parent_mesh.dom.(id_dom_{1});
                    for i = 2:length(id_dom_)
                        obj.dom = obj.dom + obj.parent_model.parent_mesh.dom.(id_dom_{i});
                    end
                end
            end
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
    methods
        function plot(obj,args)
            arguments
                obj
                args.edge_color = [0.4940 0.1840 0.5560]
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
            end
            % ---
            argu = f_to_namedarg(args);
            obj.dom.plot(argu{:});
        end
        % -----------------------------------------------------------------
    end
end
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FaceDof < Xhandle
    properties
        parent_model
        % ---
        value
    end
    % --- Contructor
    methods
        function obj = FaceDof(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.value = []
            end
            % ---
            obj = obj@Xhandle;
            % ---
            if ~isfield(args,'parent_model')
                error('#parent_model must be given');
            end
            % ---
            obj.parent_model = args.parent_model;
            obj.value = args.value;
            % ---
        end
    end
    % --- set/check
    methods
        % -----------------------------------------------------------------
        function set.value(obj,value)
            nb_face = obj.parent_model.parent_mesh.nb_face;
            if isempty(value)
                obj.value = zeros(nb_face,1);
            elseif numel(value) == 1
                obj.value = value .* ones(nb_face,1);
            else
                if numel(value) ~= nb_face
                    error('#value must correspond to mesh face, check size !');
                else
                    obj.value = f_tocolv(value);
                end
            end
        end
    end
end
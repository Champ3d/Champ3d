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

classdef VectorField < Field
    % --- Contructor
    methods
        function obj = VectorField()
            obj = obj@Field;
        end
    end
    % --- Utilily Methods
    methods
        % -----------------------------------------------------------------
        function val = cmultiply(obj,coefficient,gindex)
            arguments
                obj
                coefficient
                gindex = []
            end
            % ---
            if nargin <= 2
                if isa(obj,'ElemField')
                    gindex = 1:obj.parent_model.parent_mesh.nb_elem;
                elseif isa(obj,'FaceField')
                    gindex = 1:obj.parent_model.parent_mesh.nb_face;
                end
            end
            % ---
            if isempty(gindex)
                val = [];
                return
            end
            % ---
            if isa(coefficient,'TensorArray')
                % ---
                if isa(obj,'ElemField')
                    [gindex, ~, lindex] = intersect(gindex,coefficient.parent_dom.gindex);
                elseif isa(obj,'FaceField')
                    [gindex, ~, lindex] = intersect(gindex,coefficient.parent_dom.gindex);
                end
                % ---
                Vin = obj.cvalue(gindex);
                T = coefficient.getvalue(lindex);
                array_type = coefficient.type;
            elseif isnumeric(coefficient)
                Vin = obj.cvalue(gindex);
                [T, array_type] = Array.tensor(coefficient);
            end
            % ---
            if strcmpi(array_type,'scalar')
                val = T .* Vin;
            elseif strcmpi(array_type,'tensor')
                if isa(obj,'ElemField')
                    val(:,1) = T(:,1,1) .* Vin(:,1) + ...
                               T(:,1,2) .* Vin(:,2) + ...
                               T(:,1,3) .* Vin(:,3);
                    val(:,2) = T(:,2,1) .* Vin(:,1) + ...
                               T(:,2,2) .* Vin(:,2) + ...
                               T(:,2,3) .* Vin(:,3);
                    val(:,3) = T(:,3,1) .* Vin(:,1) + ...
                               T(:,3,2) .* Vin(:,2) + ...
                               T(:,3,3) .* Vin(:,3);
                elseif isa(obj,'FaceField')
                    val(:,1) = T(:,1,1) .* Vin(:,1) + ...
                               T(:,1,2) .* Vin(:,2);
                    val(:,2) = T(:,2,1) .* Vin(:,1) + ...
                               T(:,2,2) .* Vin(:,2);
                end
            end
            % ---
        end
        % -----------------------------------------------------------------
        % function val = cdot(obj,vector_field)
        %     arguments
        %         obj
        %         vector_field
        %     end
        %     % ---
        %     if nargin <= 1
        %         if isa(obj,'ElemField')
        %             gindex = 1:obj.parent_model.parent_mesh.nb_elem;
        %         elseif isa(obj,'FaceField')
        %             gindex = 1:obj.parent_model.parent_mesh.nb_face;
        %         end
        %     end
        %     % ---
        %     if isempty(gindex)
        %         val = [];
        %         return
        %     end
        %     % ---
        %     if isa(vector_field,'VectorArray')
        %         % ---
        %         if isa(obj,'ElemField')
        %             [gindex, ~, lindex] = intersect(gindex,vector_field.parent_dom.gindex);
        %         elseif isa(obj,'FaceField')
        %             [gindex, ~, lindex] = intersect(gindex,vector_field.parent_dom.gindex);
        %         end
        %         % ---
        %         Vin = obj.cvalue(gindex);
        %         Vfi = vector_field.getvalue(lindex);
        % 
        %     elseif isa(vector_field,'ElemField') || isa(vector_field,'FaceField')
        %         Vin = obj.cvalue(gindex);
        %         Vfi = vector_field.cvalue(gindex);
        % 
        %     elseif isnumeric(vector_field)
        %         Vin = obj.cvalue(gindex);
        %         Vfi = Array.vector(vector_field);
        %     end
        %     % ---
        %     val = Array.dot(Vin,Vfi);
        % end
        % -----------------------------------------------------------------

        % -----------------------------------------------------------------
    end
end
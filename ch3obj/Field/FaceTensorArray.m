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

classdef FaceTensorArray < TensorArray
    properties
        gid_face = []
    end
    % --- Contructor
    methods
        function obj = FaceTensorArray(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.gid_face
            end
            % ---
            obj = obj@TensorArray;
            % ---
            if nargin >1
                if ~isfield(args,'parent_model')
                    error('#parent_model must be given !');
                end
            end
            % ---
            obj.parent_model = args.parent_model;
            if isfield(args,'gid_face')
                obj.gid_face = args.gid_face;
            end
            % ---
        end
    end
    % ---
    methods
        % -----------------------------------------------------------------
        function set.gid_face(obj,val)
            obj.gid_face = val;
            len = length(val);
            obj.tarray = zeros(len,2,2);
            obj.array_type = zeros(1,len);
        end
        % -----------------------------------------------------------------
        function store(obj,array)
            arguments
                obj
                array
            end
            % ---
            [array, array_type_] = f_column_format(array);
            % ---
            switch array_type_
                case 'scalar'
                    obj.tarray(:,1,1) = array;
                    obj.array_type(:) = 1;
                case 'vector'
                    obj.tarray(:,:,1) = array;
                    obj.array_type(:) = 2;
                case 'tensor'
                    obj.tarray = array;
                    obj.array_type(:) = 3;
            end
            % ---
        end
        % -----------------------------------------------------------------
    end
    % ---
    methods
        % -----------------------------------------------------------------
        function txVf = cmultiply(obj,field_obj,id_face)
            arguments
                obj
                field_obj {mustBeA(field_obj,{'VectorFaceField'})}
                id_face
            end
            % ---
            txVf = cmultiply@TensorArray(obj,field_obj,id_face);
            % ---
        end
        % -----------------------------------------------------------------
    end
end
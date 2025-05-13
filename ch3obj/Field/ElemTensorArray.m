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

classdef ElemTensorArray < TensorArray
    properties
        gid_elem = []
    end
    % --- Contructor
    methods
        function obj = ElemTensorArray(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.gid_elem
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
            if isfield(args,'gid_elem')
                obj.gid_elem = args.gid_elem;
            end
            % ---
        end
    end
    % ---
    methods
        % -----------------------------------------------------------------
        function store(obj,array)
            arguments
                obj
                array
            end
            % ---
            [array, array_type_] = f_column_format(array);
            % ---
            obj.tarray = array;
            % ---
            switch array_type_
                case 'scalar'
                    obj.array_type = 'scalar';
                case 'vector'
                    obj.array_type = 'vector';
                case 'tensor'
                    obj.array_type = 'tensor';
            end
            % ---
        end
        % -----------------------------------------------------------------
    end
    % ---
    methods
        % -----------------------------------------------------------------
        function txVf = cmultiply(obj,field_obj)
            arguments
                obj
                field_obj
            end
            % ---
            tarray = zeros(length(obj.gid_elem),3,3);
            switch obj.array_type
                case 'scalar'
                    tarray(:,1,1) = array;
                case 'vector'
                    tarray(:,:,1) = array;
                case 'tensor'
                    tarray = array;
            end
            % ---
            Vf = field_obj.cvalue(obj.gid_elem);
            switch obj.array_type
                case 'scalar'
                    txVf = tarray(:,1,1) .* Vf;
                case 'vector'
                    txVf = tarray(:,1,1) * Vf(1,:) + ...
                           tarray(:,2,1) * Vf(2,:) + ...
                           tarray(:,3,1) * Vf(3,:);
                case 'tensor'
                    txVf = zeros(3,length(obj.gid_elem));
                    txVf(1,:) = tarray(:,1,1).' .* Vf(1,:) + ...
                                tarray(:,1,2).' .* Vf(2,:) + ...
                                tarray(:,1,3).' .* Vf(3,:);
                    txVf(2,:) = tarray(:,2,1).' .* Vf(1,:) + ...
                                tarray(:,2,2).' .* Vf(2,:) + ...
                                tarray(:,2,3).' .* Vf(3,:);
                    txVf(3,:) = tarray(:,3,1).' .* Vf(1,:) + ...
                                tarray(:,3,2).' .* Vf(2,:) + ...
                                tarray(:,3,3).' .* Vf(3,:);
            end
        end
        % -----------------------------------------------------------------
        function txVf = imultiply(obj,field_obj,id_place)
            % --- XTODO
        end
        % -----------------------------------------------------------------
        function txVf = gmultiply(obj,field_obj,id_place)
            % --- XTODO
        end
        % -----------------------------------------------------------------
    end
end
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
    % --- computed
    properties (Dependent)
        tarray
    end
    % --- Contructor
    methods
        function obj = ElemTensorArray(args)
            arguments
                args.physical_dom {mustBeA(args.physical_dom,'PhysicalDom')}
                args.parameter_array = []
            end
            % ---
            obj = obj@TensorArray;
            % ---
            if nargin >1
                if ~isfield(args,'physical_dom')
                    error('#physical_dom must be given !');
                end
            end
            % ---
            obj <= args;
            % ---
        end
    end
    % --- get
    methods
        % -----------------------------------------------------------------
        function tarray = get.tarray(obj)
            % ---
            if isempty(obj.parameter_array)
                tarray = [];
                return
            end
            % ---
            array_type = f_parraytype(obj.parameter_array);
            % ---
            lent = length(obj.physical_dom.dom.gid_elem);
            % ---
            tarray = zeros(lent,3,3);
            switch array_type
                case 'scalar'
                    tarray(:,1,1) = obj.parameter_array;
                case 'vector'
                    tarray(:,:,1) = obj.parameter_array;
                case 'tensor'
                    tarray = obj.parameter_array;
            end
            % ---
        end
        % -----------------------------------------------------------------
    end
    % ---
    methods
        % -----------------------------------------------------------------
        function txVf = cmultiply(obj,field_obj,gid_elem)
            arguments
                obj
                field_obj
                gid_elem
            end
            % ---

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
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

classdef TensorArray < Xhandle
    properties
        physical_dom
        parameter_array
    end
    % --- Contructor
    methods
        function obj = TensorArray(args)
            arguments
                args.physical_dom {mustBeA(args.physical_dom,'PhysicalDom')}
                args.parameter_array = []
            end
            % ---
            obj = obj@Xhandle;
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
    % --- Utilily Methods
    methods (Static)
        %-------------------------------------------------------------------
        function [sarray, array_type] = scalar(array,args)
            arguments
                array
                args.nb_elem = 1;
            end
            % ---
            nb_elem = args.nb_elem;
            % ---
            if numel(array) == 1
                sarray = repmat(array,[1,nb_elem]);
            else
                sarray = f_torowv(array);
            end
            % ---
            array_type = 'scalar';
        end
        %-------------------------------------------------------------------
        function [varray, array_type] = vector(array,args)
            arguments
                array
                args.nb_elem = 1
            end
            % ---
            nb_elem = args.nb_elem;
            % ---
            s = size(array);
            if length(s) >= 3
                error('#array is not a vector array !');
            end
            % ---
            if isequal(s,[1 2]) || isequal(s,[2 1]) || ...
               isequal(s,[1 3]) || isequal(s,[3 1])
                array = f_tocolv(array);
                varray = repmat(array,[1,nb_elem]);
            elseif isequal(s,[2 2]) || isequal(s,[3 3])
                f_fprintf(1,'/!\\',0,'vector-array input understood as [dim x n] \n');
                varray = array;
            elseif s(1) < s(2) && s(1) <= 3
                varray = array;
            elseif s(2) < s(1) && s(2) <= 3
                f_fprintf(1,'/!\\',0,'vector-array input understood as [n x dim] --> output [dim x n] \n');
                varray = permute(array,[2 1]);
            else
                error('#array is not a vector array !');
            end
            % ---
            array_type = 'vector';
        end
        %-------------------------------------------------------------------
        function [tarray, array_type] = tensor(array,args)
            arguments
                array
                args.nb_elem = 1
            end
            % ---
            nb_elem = args.nb_elem;
            % ---
            s = size(array);
            if length(s) >= 4
                error('#array is not a tensor array !');
            end
            % ---
            if isequal(s,[2 2]) || isequal(s,[3 3])
                tarray = permute(reshape(repmat(array,[1,nb_elem]),[s nb_elem]),[3 1 2]);
            elseif isequal(s,[2 2 2]) || isequal(s,[3 3 3])
                f_fprintf(1,'/!\\',0,'tensor input array understood as [n x dim x dim] \n');
                tarray = array;
            elseif s(1) == s(2)
                f_fprintf(1,'/!\\',0,'tensor input array understood as [dim x dim x n] --> output [n x dim x dim] \n');
                tarray = permute(array,[3 1 2]);
            elseif s(1) == s(3)
                f_fprintf(1,'/!\\',0,'tensor input array understood as [dim x n x dim] --> output [n x dim x dim] \n');
                tarray = permute(array,[2 1 3]);
            elseif s(2) == s(3)
                tarray = array;
            else
                error('#array is not a tensor array !');
            end
            % ---
            array_type = 'tensor';
        end
        %-------------------------------------------------------------------
        function [autoarray, array_type] = autoformat(array,nb_elem)
            arguments
                array
                nb_elem = []
            end
            % ---
            if isempty(nb_elem)
                
            else
                
            end
        end
        %-------------------------------------------------------------------
        function array_type = get_arraytype(array,nb_elem)
            arguments
                array
                nb_elem = []
            end
            % ---
            if isempty(nb_elem)
                
            else
                
            end
        end
        %-------------------------------------------------------------------
        function tarray = fullformat(array,nb_elem)
            arguments
                array
                nb_elem
            end
            % ---
            if mod(nb_elem)

            end
            % ---
            array_type = f_arraytype(array);
            tarray = zeros(lent,3,3);
            switch array_type
                case 'scalar'
                    tarray(:,1,1) = repmat(array,[]);
                case 'vector'
                    tarray(:,:,1) = obj.parameter_array;
                case 'tensor'
                    tarray = obj.parameter_array;
            end
            % ---
        end
        %-------------------------------------------------------------------
    end
end
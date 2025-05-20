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
        function [varray, array_type] = vector(array,args)
            arguments
                array
                args.nb_elem = 1
            end
            % ---
            nb_elem = args.nb_elem;
            array = squeeze(array); % !!!
            % ---
            s = size(array);
            if length(s) >= 3
                error('#array is not a vector array !');
            end
            % ---
            if isequal(s,[1 2]) || isequal(s,[2 1]) || ...
               isequal(s,[1 3]) || isequal(s,[3 1])
                array = f_torowv(array);
                varray = repmat(array,[nb_elem,1]);
            elseif isequal(s,[2 2]) || isequal(s,[3 3])
                f_fprintf(1,'/!\\',0,'vector-array input understood as [n x dim] \n');
                varray = array;
            elseif s(1) < s(2) && s(1) <= 3
                f_fprintf(1,'/!\\',0,'vector-array input understood as [dim x n] --> output [n x dim] \n');
                varray = permute(array,[2 1]);
            elseif s(2) < s(1) && s(2) <= 3
                varray = array;
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
            array = squeeze(array); % !!!
            % ---
            s = size(array);
            if length(s) >= 4
                error('#array is not a scalar/tensor array !');
            end
            % ---
            if length(s) == 2 && min(s) == 1
                if numel(array) == 1
                    tarray = repmat(array,[nb_elem,1]);
                    array_type = 'scalar';
                else
                    tarray = f_tocolv(array);
                    array_type = 'scalar';
                end
            else
                if isequal(s,[2 2]) || isequal(s,[3 3])
                    tarray = permute(reshape(repmat(array,[1,nb_elem]),[s nb_elem]),[3 1 2]);
                    array_type = 'tensor';
                elseif isequal(s,[2 2 2]) || isequal(s,[3 3 3])
                    f_fprintf(1,'/!\\',0,'tensor input array understood as [n x dim x dim] \n');
                    tarray = array;
                    array_type = 'tensor';
                elseif s(1) == s(2) && s(1) <= 3
                    f_fprintf(1,'/!\\',0,'tensor input array understood as [dim x dim x n] --> output [n x dim x dim] \n');
                    tarray = permute(array,[3 1 2]);
                    array_type = 'tensor';
                elseif s(1) == s(3) && s(1) <= 3
                    f_fprintf(1,'/!\\',0,'tensor input array understood as [dim x n x dim] --> output [n x dim x dim] \n');
                    tarray = permute(array,[2 1 3]);
                    array_type = 'tensor';
                elseif s(2) == s(3) && s(2) <= 3
                    tarray = array;
                    array_type = 'tensor';
                else
                    error('#array is not a scalar/tensor array !');
                end
            end
        end
        %-------------------------------------------------------------------
        function varray = normalize(vector_array)
            varray = TensorArray.vector(vector_array);
            % ---
            VM = sqrt(sum(varray.^2, 2)); % 2-position !!
            varray = varray ./ VM;
            varray(:,VM <= eps) = 0;
        end
        %-------------------------------------------------------------------
        function vnorm = norm(vector_array)
            varray = TensorArray.vector(vector_array);
            % ---
            if isreal(varray)
                vnorm = sqrt(sum(varray.^2, 2)); % 2-position !!
                vnorm(abs(vnorm) <= eps) = 0;
            else
                f_fprintf(1,'/!\\',0,'norm undefined for complex vector ! consider max or complex2time \n');
                error('undefined norm for complex vector !');
            end
        end
        %-------------------------------------------------------------------
        function vtime = max(vector_array)
            varray = TensorArray.vector(vector_array);
            % ---
            if isreal(varray)
                vtime = varray;
            end
            % ---
        end
        %-------------------------------------------------------------------
        function vtime = complex2time(vector_array,frequency,t)
            arguments
                vector_array
                frequency = 1
                t = 0
            end
            varray = TensorArray.vector(vector_array);
            % ---
            if isreal(varray)
                vtime = varray;
            else
                mag = abs(varray);
                ang = angle(varray);
                vtime = mag .* cos(2*pi*frequency*t + ang);
            end
            % ---
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
            array_type = TensorArray.arraytype(array);
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
        function array_type = arraytype(array)
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
    end
end
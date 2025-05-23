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

classdef TensorArray < Array
    properties
        parent_dom
        value
        type
    end
    % --- Contructor
    methods
        function obj = TensorArray(args)
            arguments
                args.parent_dom {mustBeA(args.parent_dom,{'PhysicalDom','MeshDom'})}
                args.value = []
            end
            % ---
            obj = obj@Array;
            % ---
            if nargin >1
                if ~isfield(args,'parent_dom')
                    error('#parent_dom must be given !');
                end
            end
            % ---
            obj <= args;
            % ---
        end
    end
    % --- Utilily Methods
    % --- array methods not for obj
    methods (Static)
        %-------------------------------------------------------------------
        function tinv = inverse(tensor_array)
            % ---
            [tensor_array,array_type] = Array.tensor(tensor_array);
            if strcmpi(array_type,'scalar')
                tinv = 1./tensor_array;
            elseif strcmpi(array_type,'tensor')
                sizeg = size(tensor_array);
                dim = sizeg(2);
                % ---
                if dim == 2
                    % --- 
                    tinv = zeros(sizeg(1),2,2);
                    % ---
                    a11(1,:) = tensor_array(:,1,1);
                    a12(1,:) = tensor_array(:,1,2);
                    a21(1,:) = tensor_array(:,2,1);
                    a22(1,:) = tensor_array(:,2,2);
                    d = a11.*a22 - a21.*a12;
                    ix = find(d);
                    tinv(ix,1,1) = +1./d(ix).*a22(ix);
                    tinv(ix,1,2) = -1./d(ix).*a12(ix);
                    tinv(ix,2,1) = -1./d(ix).*a21(ix);
                    tinv(ix,2,2) = +1./d(ix).*a11(ix);
                    % ---
                elseif dim == 3
                    % --- 
                    tinv = zeros(sizeg(1),3,3);
                    % ---
                    a11(1,:) = tensor_array(:,1,1);
                    a12(1,:) = tensor_array(:,1,2);
                    a13(1,:) = tensor_array(:,1,3);
                    a21(1,:) = tensor_array(:,2,1);
                    a22(1,:) = tensor_array(:,2,2);
                    a23(1,:) = tensor_array(:,2,3);
                    a31(1,:) = tensor_array(:,3,1);
                    a32(1,:) = tensor_array(:,3,2);
                    a33(1,:) = tensor_array(:,3,3);
                    A11 = a22.*a33 - a23.*a32;
                    A12 = a32.*a13 - a12.*a33;
                    A13 = a12.*a23 - a13.*a22;
                    A21 = a23.*a31 - a21.*a33;
                    A22 = a33.*a11 - a31.*a13;
                    A23 = a13.*a21 - a23.*a11;
                    A31 = a21.*a32 - a31.*a22;
                    A32 = a31.*a12 - a32.*a11;
                    A33 = a11.*a22 - a12.*a21;
                    d = a11.*a22.*a33 + a21.*a32.*a13 + a31.*a12.*a23 - ...
                        a11.*a32.*a23 - a31.*a22.*a13 - a21.*a12.*a33;
                    ix = find(d);
                    tinv(ix,1,1) = 1./d(ix).*A11(ix);
                    tinv(ix,1,2) = 1./d(ix).*A12(ix);
                    tinv(ix,1,3) = 1./d(ix).*A13(ix);
                    tinv(ix,2,1) = 1./d(ix).*A21(ix);
                    tinv(ix,2,2) = 1./d(ix).*A22(ix);
                    tinv(ix,2,3) = 1./d(ix).*A23(ix);
                    tinv(ix,3,1) = 1./d(ix).*A31(ix);
                    tinv(ix,3,2) = 1./d(ix).*A32(ix);
                    tinv(ix,3,3) = 1./d(ix).*A33(ix);
                end
            end
        end
        %-------------------------------------------------------------------
        function txt = multiply(tarray1,tarray2)
            txt = tarray1 .* tarray2;
        end
        %-------------------------------------------------------------------
        function txt = divide(tarray1,tarray2)
            txt = tarray1 ./ tarray2;
        end
        %-------------------------------------------------------------------
    end
    % --- obj's methods
    methods
        %-------------------------------------------------------------------
        function set.value(obj,val)
            [obj.value, obj.type] = Array.tensor(val);
        end
        %-------------------------------------------------------------------
        function gindex = gindex(obj)
            gindex = obj.parent_dom.gindex;
        end
        %-------------------------------------------------------------------
        function val = getvalue(obj,lindex)
            % ---
            % eq. to : obj(lindex).value
            % ---
            arguments
                obj
                lindex = []
            end
            % ---
            if nargin <= 1
                lindex = 1:size(obj.value,1);
            end
            % ---
            if isempty(lindex)
                val = [];
                return
            end
            % ---
            if numel(obj.value) == 1
                val = obj.value;
            else
                val = obj.value(lindex,:,:);
            end
        end
        %-------------------------------------------------------------------
    end

    % --- obj's operators
    methods
        %-------------------------------------------------------------------
        function value = uplus(obj)
            value = obj.value;
        end
        %-------------------------------------------------------------------
        function taout = subsref(obj,lidstruct)
            % ---
            % taobj([...])
            % taobj([])
            % ---
            switch lidstruct(1).type
                case '()'
                    if isempty(lidstruct(1).subs)
                        lindex = 1:size(obj.value,1);
                    else
                        lindex = lidstruct(1).subs{1};
                    end
                    % ---
                    if isempty(lindex)
                        val = [];
                    else
                        if numel(obj.value) == 1
                            val = obj.value;
                        else
                            val = obj.value(lindex,:,:);
                        end
                    end
                    % ---
                    taout = obj';
                    taout.value = val;
                    % ---
                otherwise
                    % builtin behavior for field. and field{}
                    try
                        taout = builtin('subsref', obj, lidstruct);
                    catch
                        builtin('subsref', obj, lidstruct);
                    end
            end
        end
        %-------------------------------------------------------------------
        function outobj = mtimes(obj,rhs_obj)
            % ---
            % obj([...])
            % use obj([...]).value or =+ obj to getvalue
            % ---
            if isnumeric(rhs_obj)
                T = obj.value;
                % ---
                outobj = VectorArray();
                value_ = rhs_obj .* T;
            elseif isa(rhs_obj,'TensorArray')
                T1 = obj.value;
                T2 = rhs_obj.value;
                % ---
                outobj = TensorArray();
                value_ = TensorArray.multiply(T1,T2);
            elseif isa(rhs_obj,'VectorArray')
                T = obj.value;
                V = rhs_obj.value;
                % ---
                outobj = VectorArray();
                value_ = VectorArray.multiply(V,T);
            elseif isa(rhs_obj,'Field')
                T = obj.value;
                V = rhs_obj.value;
                % ---
                outobj = Field();
                value_ = VectorArray.multiply(V,T);
            end
            % ---
            outobj.value = value_;
            % ---
        end
        %-------------------------------------------------------------------
        function outobj = mrdivide(obj,numerator)
            % ---
            % obj([...])
            % use obj([...]).value or =+ obj to getvalue
            % ---
            if isnumeric(numerator)
                T = obj.value;
                outobj = TensorArray();
                value_ = numerator .* TensorArray.inverse(T);
            elseif isa(numerator,'TensorArray')
                T1 = obj.value;
                T2 = numerator.value;
                % ---
                outobj = TensorArray();
                value_ = TensorArray.divide(T1,T2);
            elseif isa(numerator,'VectorArray')
                T = obj.value;
                V = numerator.value;
                % ---
                outobj = VectorArray();
                value_ = VectorArray.multiply(V,TensorArray.inverse(T));
            elseif isa(numerator,'Field')
                T = obj.value;
                V = numerator.value;
                % ---
                outobj = Field();
                value_ = VectorArray.multiply(V,TensorArray.inverse(T));
            end
            % ---
            outobj.value = value_;
            % ---
        end
        %-------------------------------------------------------------------
    end
end
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
        function obj = TensorArray(value,args)
            arguments
                value = []
                args.parent_dom {mustBeA(args.parent_dom,{'PhysicalDom','MeshDom'})}
            end
            % ---
            obj = obj@Array;
            % ---
            if nargin > 0
                obj.value = value;
                if isfield(args,'parent_dom')
                    obj.parent_dom = args.parent_dom;
                end
            end
            % ---
        end
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
        function outobj = mtimes(lhs_obj,rhs_obj)
            % ---
            % obj([...])
            % use obj([...]).value or =+ obj to getvalue
            % ---
            if isnumeric(rhs_obj)
                T = lhs_obj.value;
                % ---
                outobj = VectorArray();
                value_ = rhs_obj .* T;
            elseif isa(rhs_obj,'TensorArray')
                T1 = lhs_obj.value;
                T2 = rhs_obj.value;
                % ---
                outobj = TensorArray();
                value_ = TensorArray.multiply(T1,T2);
            elseif isa(rhs_obj,'VectorArray')
                T = lhs_obj.value;
                V = rhs_obj.value;
                % ---
                outobj = VectorArray();
                value_ = Array.multiply(V,T);
            elseif isa(rhs_obj,'Field')
                T = lhs_obj.value;
                V = rhs_obj.value;
                % ---
                outobj = Field();
                value_ = Array.multiply(V,T);
            end
            % ---
            outobj.value = value_;
            % ---
        end
        %-------------------------------------------------------------------
        function outobj = mrdivide(numerator,denominator) 
            % ---
            % obj([...])
            % use obj([...]).value or =+ obj to getvalue
            % ---
            if isnumeric(numerator)
                T = denominator.value;
                outobj = TensorArray();
                value_ = numerator .* TensorArray.inverse(T);
            elseif isa(denominator,'TensorArray')
                T1 = numerator.value;
                T2 = denominator.value;
                % ---
                outobj = TensorArray();
                value_ = TensorArray.divide(T1,T2);
            elseif isa(denominator,'VectorArray')
                T = numerator.value;
                V = denominator.value;
                % ---
                outobj = VectorArray();
                value_ = Array.multiply(V,TensorArray.inverse(T));
            elseif isa(denominator,'Field')
                T = numerator.value;
                V = denominator.value;
                % ---
                outobj = Field();
                value_ = Array.multiply(V,TensorArray.inverse(T));
            end
            % ---
            outobj.value = value_;
            % ---
        end
        %-------------------------------------------------------------------
    end
end
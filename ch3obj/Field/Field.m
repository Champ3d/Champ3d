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

classdef Field < Xhandle
    properties (Access = private)
        value
    end
    % --- Contructor
    methods
        function obj = Field()
            obj = obj@Xhandle;
        end
    end
    % --- Utilily Methods
    methods
        % -----------------------------------------------------------------
        function field_obj = subsref(obj,gid)
            % ---
            % applied to subclass !
            % ---
            % field([...]), field({[...]}), field({{[...]}})
            % field([]), field({[]}), field({{[]}})
            % ---
            field_obj = Field();
            % ---
            if iscell(gid)
                gid = gid{1};
                if iscell(gid)
                    % --- gvalue
                    gid = gid{1};
                    value_ = obj.gvalue(gid);
                elseif isnumeric(gid)
                    % --- ivalue
                    value_ = obj.ivalue(gid);
                end
            elseif isnumeric(gid)
                % --- cvalue
                value_ = obj.cvalue(gid);
            end
            % ---
            field_obj.value = value_;
            % ---
        end
        % -----------------------------------------------------------------
        function field_obj = mtimes(obj,rhs_obj)
            % ---
            % obj must be a Field
            % objx may be a Field, a TensorArray, or a VectorArray
            % ---
            X = obj.value;
            Y = rhs_obj.value;
            % ---
            if isa(rhs_obj,'TensorArray')
                % X -> v, Y -> t
                field_obj = Field();
                value_ = VectorArray.multiply(X,Y);
            elseif isa(rhs_obj,'VectorArray')
                % X -> v, Y -> v
                field_obj = TensorArray();
                value_ = VectorArray.dot(X,Y);
            elseif isa(rhs_obj,'Field')
                % X -> v, Y -> v
                field_obj = TensorArray();
                value_ = VectorArray.dot(X,Y);
            end
            % ---
            field_obj.value = value_;
            % ---
        end
        % -----------------------------------------------------------------
    end
end
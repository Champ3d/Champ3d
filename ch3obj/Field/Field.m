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
        function obj = Field(value)
            obj = obj@Xhandle;
            if nargin > 0
                obj.value = value;
            end
        end
    end
    % --- Utilily Methods
    methods
        % -----------------------------------------------------------------
        function fout = subsref(obj,gidstruct)
            % ---
            % applied to subclass !
            % ---
            % field([...]), field({[...]}), field({{[...]}})
            % field([]), field({[]}), field({{[]}})
            % ---
            value_ = [];
            switch gidstruct(1).type
                case '()'
                    if isempty(gidstruct(1).subs)
                        value_ = obj.cvalue;
                    else
                        gindex = gidstruct(1).subs{1};
                        if iscell(gindex)
                            gindex = gindex{1};
                            if iscell(gindex)
                                % --- gvalue
                                gindex = gindex{1};
                                value_ = obj.gvalue(gindex);
                            elseif isnumeric(gindex)
                                % --- ivalue
                                value_ = obj.ivalue(gindex);
                            end
                        elseif isnumeric(gindex)
                            % --- cvalue
                            value_ = obj.cvalue(gindex);
                        end
                    end
                    % ---
                    fout = Field();
                    fout.value = value_;
                    % ---
                otherwise
                    % builtin behavior for field. and field{}
                    try
                        fout = builtin('subsref', obj, gidstruct);
                    catch
                        builtin('subsref', obj, gidstruct);
                    end
            end
        end
        % -----------------------------------------------------------------
        function outobj = mtimes(obj,rhs_obj)
            % ---
            % obj must be a Field
            % objx may be a Field, a TensorArray, or a VectorArray
            % ---
            if isa(rhs_obj,'TensorArray')
                V = obj.value;
                T = rhs_obj.value;
                % ---
                outobj = Field();
                value_ = VectorArray.multiply(V,T);
            elseif isa(rhs_obj,'VectorArray')
                V1 = obj.value;
                V2 = rhs_obj.value;
                % ---
                outobj = TensorArray();
                value_ = VectorArray.dot(V1,V2);
            elseif isa(rhs_obj,'Field')
                V1 = obj.value;
                V2 = rhs_obj.value;
                % ---
                outobj = TensorArray();
                value_ = VectorArray.dot(V1,V2);
            end
            % ---
            outobj.value = value_;
            % ---
        end
        % -----------------------------------------------------------------
    end
end
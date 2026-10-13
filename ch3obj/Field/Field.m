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

classdef Field < Array
    properties
        value
    end
    % --- Contructor
    methods
        function obj = Field(value)
            obj = obj@Array;
            if nargin > 0
                obj.value = value;
            else
                obj.value = [];
            end
        end
    end

    % --- obj's methods - field([...]), field({[...]}), field({{[...]}})
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
                        if ismethod(obj,'cvalue') || isprop(obj,'cvalue')
                            value_ = obj.cvalue;
                        else
                            value_ = obj.value;
                        end
                    else
                        gindex = gidstruct(1).subs{1};
                        if iscell(gindex)
                            gindex = gindex{1};
                            if iscell(gindex)
                                % --- gvalue
                                gindex = gindex{1};
                                if ismethod(obj,'gvalue') || isprop(obj,'gvalue')
                                    value_ = obj.gvalue(gindex);
                                else
                                    if iscell(obj.value)
                                        for ic = 1:length(obj.value)
                                            value_{ic} = obj.value{ic}(gindex,:);
                                        end
                                    else
                                        value_ = obj.value(gindex,:);
                                    end
                                end
                            elseif isnumeric(gindex)
                                % --- ivalue
                                if ismethod(obj,'ivalue') || isprop(obj,'ivalue')
                                    value_ = obj.ivalue(gindex);
                                else
                                    if iscell(obj.value)
                                        for ic = 1:length(obj.value)
                                            value_{ic} = obj.value{ic}(gindex,:);
                                        end
                                    else
                                        value_ = obj.value(gindex,:);
                                    end
                                end
                            end
                        elseif isnumeric(gindex)
                            % --- cvalue
                            if ismethod(obj,'cvalue') || isprop(obj,'cvalue')
                                value_ = obj.cvalue(gindex);
                            else
                                if iscell(obj.value)
                                    for ic = 1:length(obj.value)
                                        value_{ic} = obj.value{ic}(gindex,:);
                                    end
                                else
                                    value_ = obj.value(gindex,:);
                                end
                            end
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
    end
    
    % --- set/get
    methods
        %-------------------------------------------------------------------
        function val = get.value(obj)
            val = obj.value;
        end
        %-------------------------------------------------------------------
        % get : value = obj(gindex).value
        %-------------------------------------------------------------------
        function value = uplus(obj)
            value = obj.value;
        end
        %-------------------------------------------------------------------
    end

    % --- operators (overload)
    methods
        %-------------------------------------------------------------------
        function objout = uminus(obj)
            if iscell(obj.value)
                for i = 1:length(obj.value)
                    val{i} = - obj.value{i};
                end
            else
                val = - obj.value;
            end
            % ---
            objout = Field(val);
        end
        %-------------------------------------------------------------------
        function objout = norm(obj)
            if iscell(obj.value)
                for i = 1:length(obj.value)
                    val{i} = Array.norm(obj.value{i});
                end
            else
                val = Array.norm(obj.value);
            end
            % ---
            objout = Field(val);
        end
        %-------------------------------------------------------------------
        function objout = normalize(obj)
            if iscell(obj.value)
                for i = 1:length(obj.value)
                    val{i} = Array.normalize(obj.value{i});
                end
            else
                val = Array.normalize(obj.value);
            end
            % ---
            objout = Field(val);
        end
        %-------------------------------------------------------------------
        function objout = conj(obj)
            if iscell(obj.value)
                for i = 1:length(obj.value)
                    val{i} = conj(obj.value{i});
                end
            else
                val = conj(obj.value);
            end
            % ---
            objout = Field(val);
        end
        %-------------------------------------------------------------------
        function objout = real(obj)
            if iscell(obj.value)
                for i = 1:length(obj.value)
                    val{i} = real(obj.value{i});
                end
            else
                val = real(obj.value);
            end
            % ---
            objout = Field(val);
        end
        %-------------------------------------------------------------------
        function objout = imag(obj)
            if iscell(obj.value)
                for i = 1:length(obj.value)
                    val{i} = imag(obj.value{i});
                end
            else
                val = imag(obj.value);
            end
            % ---
            objout = Field(val);
        end
        %-------------------------------------------------------------------
        function objout = plus(obj1,obj2)
            if iscell(obj1.value)
                if iscell(obj2.value)
                    for i = 1:length(obj1.value)
                        val{i} = obj1.value{i} + obj2.value{i};
                    end
                else
                    for i = 1:length(obj1.value)
                        val{i} = obj1.value{i} + obj2.value;
                    end
                end
            else
                if iscell(obj2.value)
                    for i = 1:length(obj2.value)
                        val{i} = obj1.value + obj2.value{i};
                    end
                else
                    val = obj1.value + obj2.value;
                end
            end
            % ---
            objout = Field(val);
        end
        %-------------------------------------------------------------------
        function objout = minus(obj1,obj2)
            if iscell(obj1.value)
                if iscell(obj2.value)
                    for i = 1:length(obj1.value)
                        val{i} = obj1.value{i} - obj2.value{i};
                    end
                else
                    for i = 1:length(obj1.value)
                        val{i} = obj1.value{i} - obj2.value;
                    end
                end
            else
                if iscell(obj2.value)
                    for i = 1:length(obj2.value)
                        val{i} = obj1.value - obj2.value{i};
                    end
                else
                    val = obj1.value - obj2.value;
                end
            end
            % ---
            objout = Field(val);
        end
        %-------------------------------------------------------------------
    end
end
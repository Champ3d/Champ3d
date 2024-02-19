%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Xhandle < matlab.mixin.Copyable
    %----------------------------------------------------------------------
    properties (Hidden)
        tmp
        my
    end
    %----------------------------------------------------------------------
    methods
        %------------------------------------------------------------------
        function le(obj,objx)
            % ---
            if isstruct(objx)
                fname = fieldnames(objx);
            elseif isobject(objx)
                fname = properties(objx);
            end
            % ---
            validprop = properties(obj);
            % ---
            for i = 1:length(fname)
                if any(f_strcmpi(fname,validprop))
                    obj.(fname{i}) = objx.(fname{i});
                end
            end
        end
        %------------------------------------------------------------------
        function res = is_available(obj,args,field_name)
            arguments
                obj
                args struct = []
                field_name = []
            end
            % ---
            if nargin < 1
                res = 0;
                return
            end
            % ---
            if isempty(args)
                res = 0;
                return
            end
            % ---
            if isempty(field_name)
                field_name = fieldnames(args);
            end
            % ---
            field_name = f_to_scellargin(field_name);
            % ---
            res = 1;
            args4obj = [];
            for i = 1:length(field_name)
                if isfield(args,field_name{i})
                    if isempty(args.(field_name{i}))
                        res = 0;
                        args = rmfield(args,field_name{i});
                    else
                        args4obj.(field_name{i}) = args.(field_name{i});
                    end
                else
                    res = 0;
                end
            end
            % ---
            obj.tmp.args = f_to_namedarg(args4obj);
        end
        %------------------------------------------------------------------
        function confpar = conformize_parameter(obj,parameter)
            if ~isa(parameter,'Parameter')
                if isnumeric(parameter)
                    confpar = Parameter('f',parameter);
                else
                    warning('Non conformal parameter');
                    confpar = [];
                end
            end
        end
        %------------------------------------------------------------------
        function init(obj,args)
            arguments
                obj
                args.property_name = []
                args.field_names = []
                args.init_value = []
            end
            % ---
            if ~isempty(args.property_name)
                if isprop(obj,args.property_name)
                    field_names = f_to_scellargin(args.field_names);
                    for i = 1:length(field_names)
                        fn = field_names{i};
                        obj.(args.property_name).(fn) = args.init_value;
                    end
                end
            end
        end
        %------------------------------------------------------------------
        function [colx,array_type] = column_format(obj,x)
            if isnumeric(x)
                x = squeeze(x);
                % ---
                sx = size(x);
                lensx = length(sx);
                if lensx > 3
                    colx = x;
                    array_type = '4+dimensional';
                else
                    switch lensx
                        case 2
                            s1 = sx(1);
                            s2 = sx(2);
                            if s1 == s2
                                if s1 == 1
                                    colx = x;
                                    array_type = 'scalar';
                                else
                                    colx(1,:,:) = x;
                                    array_type = 'tensor';
                                end
                            elseif s1 < s2
                                colx = x.';
                                if s1 == 1 
                                    if s2 > 3
                                        array_type = 'scalar';
                                    else
                                        array_type = {'scalar','vector'};
                                    end
                                else
                                    array_type = 'vector';
                                end
                            else
                                colx = x;
                                if s2 == 1 
                                    if s1 > 3
                                        array_type = 'scalar';
                                    else
                                        array_type = {'scalar','vector'};
                                    end
                                else
                                    array_type = 'vector';
                                end
                            end
                        case 3
                            s1 = sx(1);
                            s2 = sx(2);
                            s3 = sx(3);
                            % ---
                            if s1 == s2 && s2 == s3
                                colx = x;
                                if s1 <= 3
                                    array_type = 'tensor';
                                else
                                    array_type = '4+dimensional';
                                end
                            else
                                if s1 == s2
                                    ielem = 3;
                                    % ---
                                    if s1 <= 3
                                        array_type = 'tensor';
                                    else
                                        array_type = '4+dimensional';
                                    end
                                elseif s1 == s3
                                    ielem = 2;
                                    % ---
                                    if s1 <= 3
                                        array_type = 'tensor';
                                    else
                                        array_type = '4+dimensional';
                                    end
                                elseif s2 == s3
                                    ielem = 1;
                                    % ---
                                    if s2 <= 3
                                        array_type = 'tensor';
                                    else
                                        array_type = '4+dimensional';
                                    end
                                else
                                    [~,ielem] = max(sx);
                                    array_type = '4+dimensional';
                                end
                                % ---
                                ix = [1 2 3];
                                ix(ielem) = [];
                                ix = [ielem ix];
                                colx = permute(x,ix);
                            end
                    end
                end
            end
        end
        %------------------------------------------------------------------
    end

    % ---
    methods (Hidden)
        % ---
        % ---
        % ---
    end

end
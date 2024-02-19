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
    end

    % ---
    methods (Hidden)
        % ---
        % ---
        % ---
    end

end
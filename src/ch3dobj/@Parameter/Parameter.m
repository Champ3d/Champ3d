%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Parameter % < Xhandle
    properties
        f
        depend_on
        from
        varargin_list
        fvectorized
        % ---
        argspath
        value
        value_type
    end

    % --- Contructor
    methods
        function obj = Parameter(args)
            arguments
                args.f = []
                args.depend_on {mustBeMember(args.depend_on,...
                    {'celem','cface', ...
                     'bv','jv','hv','pv','av','phiv','tv','omev','tempv',...
                     'bs','js','hs','ps','as','phis','ts','omes','temps'})} = 'celem'
                args.from = []
                args.varargin_list = []
                args.fvectorized = 0
            end
            % ---
            if isempty(args.f)
                error('#f must be given ! Give a function handle or numeric value');
            end
            % ---
            if isnumeric(args.f)
                constant_parameter = args.f;
                args.f = @()(constant_parameter);
            elseif isa(args.f,'function_handle')
                if isempty(args.from)
                    error('#from must be given ! Give EMModel, THModel, ... ');
                else
                    args.from = f_to_scellargin(args.from);
                end
            else
                error('#f must be function handle or numeric value');
            end
            % ---
            obj.f = args.f;
            obj.depend_on = args.depend_on;
            obj.from = args.from;
            obj.varargin_list = args.varargin_list;
            obj.fvectorized = args.fvectorized;
        end
    end

    % --- Methods
    methods
        function evaluate_on(obj,physical_dom)
            % ---
            obj.value = 0;
            obj.value_type = '';
        end
        % ---
        function get_argspath(obj,physical_dom)
            % ---
            obj.value = 0;
            obj.value_type = '';
        end
    end
end
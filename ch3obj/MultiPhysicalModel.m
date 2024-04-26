%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef MultiPhysicalModel < Xhandle

    % --- Properties
    properties
        model
        coupling
        time_system
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = MultiPhysicalModel()
            obj = obj@Xhandle;
            % ---
        end
    end
    % --- Methods
    methods
        function add_model(obj,args)
            arguments
                obj
                args.id
                args.model
            end
            % ---
            if ~isempty(args)
                if ~isempty(args.id) && ~isempty(args.model)
                    obj.model.(args.id) = args.model;
                end
            end
        end
        % ---
    end

    % --- Methods
    methods
        function build_timesystem(obj)
            % ---
            time_system_ = TimeSystem;
            model_ = fieldnames(obj.model);
            % ---
            for i = 1:length(model_)
                id_ = model_{i};
                ltime_ = obj.model.(model_{i}).ltime;
                time_system_.ltime.(id_) = ltime_;
            end
            % ---
            time_system_.init;
            % ---
            obj.time_system = time_system_;
        end
        % -----------------------------------------------------------------
        function solve(obj,args)
            arguments
                obj
                args.coupling_scheme {mustBeMember(args.coupling_scheme,{'weak','strong'})} = 'weak';
                args.emcoupling {mustBeMember(args.emcoupling,{'DomainDecomposition'})} = 'DomainDecomposition'
            end
            % ---
            if any(f_strcmpi(args.coupling_scheme,{'weak'}))
                argu = f_to_namedarg(args);
                % ---
                solveweak(obj,argu{:})
            elseif any(f_strcmpi(args.coupling_scheme,{'strong'}))
                argu = f_to_namedarg(args);
                % ---
                solvestrong(obj,argu{:})
            end
        end

end
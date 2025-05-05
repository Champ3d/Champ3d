%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef Line1d < Xhandle

    % --- Properties
    properties
        len
        dtype = 'lin'
        dnum = 1
        flog = 1.05
        node
        elem_code
    end

    properties (Access = private)
        setup_done = 0
    end

    properties
        dependent_obj = []
        defining_obj = []
    end

    % --- Dependent Properties
    properties (Dependent = true)

    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'id','len','dtype','dnum','flog'};
        end
    end
    % --- Constructors
    methods
        function obj = Line1d(args)
            arguments
                args.id char
                args.len {mustBeNumeric}  = 0
                args.dtype {mustBeMember(args.dtype,{'lin','log+','log-','log+-','log-+','log='})} = 'lin'
                args.dnum {mustBeInteger} = 1
                args.flog {mustBeNumeric} = 1.05
            end
            % ---
            obj@Xhandle;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            Line1d.setup(obj);
        end
    end

    % --- Methods
    methods (Static)
        function setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            if any(f_strcmpi(obj.dtype,{'log+-','log-+','log='}))
                if mod(obj.dnum,2) ~= 0
                    obj.dnum = obj.dnum + 1;
                end
            end
            %--------------------------------------------------------------
            len_   = obj.len;
            dnum_  = obj.dnum;
            dtype_ = obj.dtype;
            flog_  = obj.flog;
            %--------------------------------------------------------------
            if strcmpi(dtype_,'lin')
                ratio = dnum_;
                node_ = len_/ratio .* ones(1,ratio);
            end
            if strcmpi(dtype_,'log+') % || |  |   |
                ratio = logspace(0,flog_,dnum_)./sum(logspace(0,flog_,dnum_));
                node_ = len_ .* ratio;
            end
            if strcmpi(dtype_,'log-') % |   |  | ||
                ratio = logspace(0,flog_,dnum_)./sum(logspace(0,flog_,dnum_));
                node_ = len_ .* ratio;
                node_ = node_(end:-1:1);
            end
            if strcmpi(dtype_,'log+-') || strcmpi(dtype_,'log=') % || |  |   |   |  | ||
                dnum_  = dnum_ * 2;
                ratio = logspace(0,flog_,dnum_)./sum(logspace(0,flog_,dnum_));
                node_ = len_/2 .* ratio;
                node_ = [node_, node_(end:-1:1)];
            end
            if strcmpi(dtype_,'log-+') % |   |  | || |  |   |
                dnum_  = dnum_ * 2;
                ratio = logspace(0,flog_,dnum_)./sum(logspace(0,flog_,dnum_));
                node_ = len_/2 .* ratio;
                node_ = [node_(end:-1:1), node_];
            end
            %--------------------------------------------------------------
            obj.node = node_;
            obj.elem_code = f_str2code(obj.id);
            % ---
            obj.setup_done = 1;
            % ---
        end
    end
    % ---
    methods (Access = public)
        function reset(obj)
            obj.setup_done = 0;
            Line1d.setup(obj);
            % --- reset dependent objs
            obj.reset_dependent_obj;
        end
    end
end












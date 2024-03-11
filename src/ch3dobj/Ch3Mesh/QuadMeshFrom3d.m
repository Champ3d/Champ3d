%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef QuadMeshFrom3d < QuadMesh

    % --- Properties
    properties
        parallel_line_1
        parallel_line_2
        dtype_parallel = 'lin'
        dtype_orthogonal = 'lin'
        dnum_parallel = 6
        dnum_orthogonal = 6
        flog = 1.05
    end

    % --- Dependent Properties
    properties (Dependent = true)

    end

    % --- Constructors
    methods
        function obj = QuadMeshFrom3d(args)
            arguments
                % --- super
                args.parallel_line_1
                args.parallel_line_2
                args.dtype_parallel {mustBeMember(args.dtype_parallel,{'lin','log+','log-','log+-','log-+','log='})}
                args.dtype_orthogonal {mustBeMember(args.dtype_orthogonal,{'lin','log+','log-','log+-','log-+','log='})}
                args.dnum_parallel
                args.dnum_orthogonal
                args.flog
            end
            % ---
            obj@QuadMesh;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            obj.setup_done = 0;
            % ---
            obj.setup;
            % ---
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function obj = setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            if isempty(obj.parallel_line_1) || isempty(obj.parallel_line_2)
                return
            end
            % ---
            if size(obj.parallel_line_1,1) == 3
                obj.parallel_line_1 = obj.parallel_line_1.';
            end
            if size(obj.parallel_line_2,1) == 3
                obj.parallel_line_2 = obj.parallel_line_2.';
            end
            % ---
            if any(f_strcmpi(obj.dtype_parallel,{'log+-','log-+','log='}))
                if mod(obj.dnum_parallel,2) ~= 0
                    obj.dnum_parallel = obj.dnum_parallel + 1;
                end
            end
            % ---
            if any(f_strcmpi(obj.dtype_orthogonal,{'log+-','log-+','log='}))
                if mod(obj.dnum_orthogonal,2) ~= 0
                    obj.dnum_orthogonal = obj.dnum_orthogonal + 1;
                end
            end
            % ---
            bl = obj.parallel_line_1(1,:);
            br = obj.parallel_line_1(2,:);
            tl = obj.parallel_line_2(1,:);
            tr = obj.parallel_line_2(2,:);
            % ---
            vec1 = br - bl;
            vec2 = tr - tl;
            % ---
            if norm(cross(vec1,vec2)) ~= 0
                error('Lines are not parallel !')
            end
            % ---
            if dot(vec1,vec2) < 0
                tmp = tl;
                tl = tr;
                tr = tmp;
            end
            % ---
            dtype_p = obj.dtype_parallel;
            dtype_o = obj.dtype_orthogonal;
            dnum_p = obj.dnum_parallel;
            dnum_o = obj.dnum_orthogonal;
            flog_ = obj.flog;
            % ---
            node = zeros(3,(dnum_p+1) * (dnum_o+1));
            % --- divline
            node_l = f_divline(bl,tl,'dnum',dnum_o,'dtype',dtype_o,'flog',flog_);
            node_r = f_divline(br,tr,'dnum',dnum_o,'dtype',dtype_o,'flog',flog_);
            for i = 1:dnum_o+1
                tli = node_l(:,i);
                tri = node_r(:,i);
                % ---
                id_node = (i-1) * (dnum_p+1) + (1:dnum_p+1);
                node(:,id_node) = f_divline(tli,tri,'dnum',dnum_p,'dtype',dtype_p,'flog',flog_);
            end
            % ---
            elem = zeros(4,dnum_p * dnum_o);
            elem_code = ones(1,dnum_p * dnum_o);
            for i = 1:dnum_o
                id_elem = (i-1) * dnum_p + (1:dnum_p);
                idn1 = (i-1) * (dnum_p+1) + (1:dnum_p);
                idn2 = idn1 + 1;
                idn3 = (dnum_p+1) + idn2;
                idn4 = idn3 - 1;
                elem(:,id_elem) = [idn1; idn2; idn3; idn4];
            end
            % -------------------------------------------------------------
            obj.node = node;
            obj.elem = elem;
            obj.elem_code = elem_code;
            obj.setup_done = 1;
        end
        % -----------------------------------------------------------------
    end
    
end




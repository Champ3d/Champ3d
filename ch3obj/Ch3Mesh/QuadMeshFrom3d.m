%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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

classdef QuadMeshFrom3d < QuadMesh
    properties
        parallel_line_1
        parallel_line_2
        dtype_parallel = 'lin'
        dtype_orthogonal = 'lin'
        dnum_parallel = 6
        dnum_orthogonal = 6
        flog = 1.05
    end
    properties (Access = private)
        build_done = 0
        % ---
        build_meshds_done = 0;
        build_discrete_done = 0;
        build_intkit_done = 0;
        build_prokit_done = 0;
    end
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parallel_line_1','parallel_line_2', ...
                        'dtype_parallel','dtype_orthogonal', ...
                        'dnum_parallel','dnum_orthogonal', ...
                        'flog'};
        end
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
            QuadMeshFrom3d.setup(obj);
            % ---
        end
    end

    % --- Methods
    methods (Static)
        % -----------------------------------------------------------------
        function obj = setup(obj)
            obj.build_done = 0;
            % ---
            obj.build_meshds_done = 0;
            obj.build_discrete_done = 0;
            obj.build_intkit_done = 0;
            obj.build_prokit_done = 0;
            % ---
            obj.cal_flatnode;
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
            % if abs(dot(cross(vec1,vec2),vec1)) < 1e-9
            %     error('Lines are not in plane !')
            % end
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
            % --- 2d elem surface
            obj.velem = f_volume(node,elem,'elem_type',obj.elem_type);
            % --- edge length
            % obj.sface = f_area(node_,face_);
            % ---
        end
        % -----------------------------------------------------------------
    end

    methods (Access = public)
        function reset(obj)
            QuadMeshFrom3d.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end

    methods
        function build(obj)
            % ---
            if obj.build_done
                return
            end
            % ---
            if ~obj.build_meshds_done
                obj.build_meshds;
            end
            if ~obj.build_discrete_done
                obj.build_discrete;
            end
            if ~obj.build_intkit_done
                obj.build_intkit;
            end
            % ---
            obj.build_done = 1;
            % ---
        end
    end
end




%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef ProcessingSurface3d < CutVolumeDom3d

    % --- Properties
    properties
        parent_model
        %id_dom3d
        parallel_line_1
        parallel_line_2
        dtype_parallel
        dtype_orthogonal
        dnum_parallel
        dnum_orthogonal
        flog = 1.05;
        % ---
        mesh
        fields
        % ---
        %cut_equation
        %gid_elem
        %gid_side_node_1
        %gid_side_node_2
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = ProcessingSurface3d(args)
            arguments
                % ---
                args.parent_model = []
                args.parallel_line_1 = []
                args.parallel_line_2 = []
                args.dtype_parallel {mustBeMember(args.dtype_parallel,{'lin','log+','log-','log+-','log-+','log='})} = 'lin'
                args.dtype_orthogonal {mustBeMember(args.dtype_orthogonal,{'lin','log+','log-','log+-','log-+','log='})} = 'lin'
                args.dnum_parallel = 6
                args.dnum_orthogonal = 6
                args.flog = 1.05;
                args.id_dom3d = []
            end
            % ---
            obj <= args;
            % ---
            if isempty(obj.id_dom3d)
                obj.id_dom3d = 'default_domain';
            end
            % ---
            obj.parent_mesh = obj.parent_model.parent_mesh;
            % ---
            if obj.is_available(args,{'parallel_line_1','parallel_line_2'})
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
                obj.build;
            end
        end
    end

    % --- Methods
    methods (Access = private, Hidden)
        % -----------------------------------------------------------------
        function build(obj)
            % ---
            bl = obj.parallel_line_1(1,:);
            br = obj.parallel_line_1(2,:);
            tl = obj.parallel_line_2(1,:);
            % ---
            vec1 = br - bl;
            vec2 = tl - bl;
            % ---
            ci = cross(vec1,vec2);
            ci = f_normalize(f_tocolv(ci));
            % ---
            d = (ci(1)*bl(1) + ci(2)*bl(2) + ci(3)*bl(3));
            % ---
            obj.cut_equation = [num2str(ci(1)) '*x+' ...
                                num2str(ci(2)) '*y+' ...
                                num2str(ci(3)) '*z =' num2str(d)];
            % ---
            gid_elem_ = [];
            gid_side_node_1_ = [];
            gid_side_node_2_ = [];
            iddom3 = f_to_scellargin(obj.id_dom3d);
            for i = 1:length(iddom3)
                dom2cut = obj.parent_model.parent_mesh.dom.(iddom3{i});
                cut_dom = dom2cut.get_cutdom('cut_equation',obj.cut_equation);
                gid_elem_ = [gid_elem_ cut_dom.gid_elem];
                gid_side_node_1_ = [gid_side_node_1_ cut_dom.gid_side_node_1];
                gid_side_node_2_ = [gid_side_node_2_ cut_dom.gid_side_node_2];
            end
            % ---
            obj.gid_elem = gid_elem_;
            obj.gid_side_node_1 = gid_side_node_1_;
            obj.gid_side_node_2 = gid_side_node_2_;
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
    end

    % ---
    methods
        function plot(obj,args)
            arguments
                obj
                args.edge_color = [0.4940 0.1840 0.5560]
                args.face_color = 'c'
                args.alpha {mustBeNumeric} = 0.9
            end
            % ---
            argu = f_to_namedarg(args);
            plot@CutVolumeDom3d(obj,argu{:}); hold on
            % -------------------------------------------------------------
        end
    end

end




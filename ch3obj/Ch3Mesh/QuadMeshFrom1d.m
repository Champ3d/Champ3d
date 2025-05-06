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

classdef QuadMeshFrom1d < QuadMesh

    properties
        id_xline
        id_yline
    end

    properties (Access = private)
        setup_done = 0
        build_done = 0
    end

    % --- Dependent Properties
    properties (Dependent = true)

    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'node','elem','parent_mesh','id_xline', ...
                        'id_yline'};
        end
    end
    % --- Constructors
    methods
        function obj = QuadMeshFrom1d(args)
            arguments
                % --- super
                args.node
                args.elem
                % --- sub
                args.parent_mesh
                args.id_xline
                args.id_yline
            end
            % ---
            obj = obj@QuadMesh;
            % ---
            if isempty(fieldnames(args))
                return
            end
            % ---
            obj <= args;
            % ---
            QuadMeshFrom1d.setup(obj);
            % ---
        end
    end

    % --- Methods
    methods (Static)
        % -----------------------------------------------------------------
        function obj = setup(obj)
            % ---
            if obj.setup_done
                return
            end
            % ---
            setup@QuadMesh(obj);
            % ---
            if isempty(obj.parent_mesh) || isempty(obj.id_xline) || ...
                    isempty(obj.id_yline)
                return
            end
            % ---
            obj.parent_mesh.is_defining_obj_of(obj);
            % ---
            obj.id_xline = f_to_scellargin(obj.id_xline);
            obj.id_yline = f_to_scellargin(obj.id_yline);
            % ---
            all_id_line = fieldnames(obj.parent_mesh.dom);
            xline = [];
            yline = [];
            for i = 1:length(obj.id_xline)
                id = obj.id_xline{i};
                valid_id = f_validid(id,all_id_line);
                for j = 1:length(valid_id)
                    xline = [xline obj.parent_mesh.dom.(valid_id{j})];
                end
            end
            for i = 1:length(obj.id_yline)
                id = obj.id_yline{i};
                valid_id = f_validid(id,all_id_line);
                for j = 1:length(valid_id)
                    yline = [yline obj.parent_mesh.dom.(valid_id{j})];
                end
            end
            % -------------------------------------------------------------
            xdom    = [];
            codeidx = [];
            lenx    = numel(xline);
            for i = 1:lenx
                % ---
                xl = xline(i);
                % ---
                x     = xl.node;
                xdom  = [xdom x];
                % ---
                codeidx = [codeidx xl.elem_code .* ones(1,length(x))];
            end
            xmesh = [0 cumsum(xdom)];
            % -------------------------------------------------------------
            ydom    = [];
            codeidy = []; 
            leny    = numel(yline);
            for i = 1:leny
                % ---
                yl = yline(i);
                % ---
                y  = yl.node;
                ydom = [ydom y];
                % ---
                codeidy = [codeidy yl.elem_code .* ones(1,length(y))];
            end
            ymesh = [0 cumsum(ydom)];
            % -------------- meshing --------------------------------------
            [x1, y1] = meshgrid(xmesh, ymesh);
            x2=[]; y2=[];
            % ---
            for ik = 1:size(x1,1)
                x2 = [x2 x1(ik,:)];
            end
            % ---
            for ik = 1:size(y1,1)
                y2 = [y2 y1(ik,:)];
            end
            %----- centering
            %x2 = x2 - mean(x2);
            %y2 = y2 - mean(y2);
            %-----
            node_ = [x2; y2];
            %-----
            nblayx = size(x1,2) - 1; % number of layers x
            nblayy = size(x1,1) - 1; % number of layers y
            elem_  = zeros(4, nblayx * nblayy);
            iElem  = 0;
            elem_code_  = zeros(1, nblayx * nblayy);
            % ---
            for iy = 1 : nblayy      
                for ix = 1 : nblayx  
                    iElem = iElem+1;
                    elem_(1:4,iElem) = [size(x1,2) * (iy-1) + ix; ...
                                        size(x1,2) * (iy-1) + ix+1; ...
                                        size(x1,2) *  iy    + ix+1; ...
                                        size(x1,2) *  iy    + ix];
                    elem_code_(iElem) = codeidx(ix) * codeidy(iy); % id_xdom * id_ydom
                end
            end
            % ---
            obj.node = node_;
            obj.elem = elem_;
            obj.elem_code = elem_code_;
            % --- 2d elem surface
            obj.velem = f_volume(node_,elem_,'elem_type',obj.elem_type);
            % --- edge length
            % obj.sface = f_area(node_,face_);
            % ---
            obj.setup_done = 1;
            obj.build_done = 0;
        end
    end

    methods (Access = public)
        function reset(obj)
            % reset super class
            reset@QuadMesh(obj);
            % ---
            obj.setup_done = 0;
            QuadMeshFrom1d.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end

    methods
        function build(obj)
            % ---
            QuadMeshFrom1d.setup(obj);
            % ---
            build@QuadMesh(obj);
            % ---
            if obj.build_done
                return
            end
            % ---
            
            % ---
            obj.build_done = 1;
        end
    end
    
end




%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef QuadMeshFrom1d < QuadMesh

    % --- Properties
    properties
        id_xline
        id_yline
    end

    % --- Dependent Properties
    properties (Dependent = true)

    end

    % --- Constructors
    methods
        function obj = QuadMeshFrom1d(args)
            arguments
                % --- super
                args.info = 'no_info'
                args.node = []
                args.elem = []
                % --- sub
                args.parent_mesh
                args.id_xline = []
                args.id_yline = []
                % ---
            end
            % ---
            obj = obj@QuadMesh;
            % ---
            obj <= args;
            % ---
            if obj.is_available(args,{'parent_mesh','id_xline','id_yline'})
                obj.build;
            end
        end
    end

    % --- Methods
    methods (Access = private)
        % -----------------------------------------------------------------
        function obj = build(obj)
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
                xl.build;
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
                yl.build;
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
            %if f_istrue(obj.centering)
            %    x2 = x2 - mean(x2);
            %    y2 = y2 - mean(y2);
            %end
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
            obj.is_build = 1;
        end
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
    
end




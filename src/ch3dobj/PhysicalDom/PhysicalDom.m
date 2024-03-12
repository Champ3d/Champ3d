%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef PhysicalDom < Xhandle

    % --- entry
    properties
        id
        parent_model
        id_dom2d
        id_dom3d
    end

    % --- computed
    properties
        parent_mesh
        dom
    end

    % --- computed
    properties (Access = private)
        setup_done = 0
    end

    % ---
    properties(Access = private, Hidden)

    end
    % ---

    % --- Contructor
    methods
        function obj = PhysicalDom(args)
            arguments
                args.id
                args.parent_model
                args.id_dom2d
                args.id_dom3d
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
            obj.setup_done = 0;
            % ---
            obj.setup;
        end
    end
    
    % --- Methods
    methods
        function setup(obj)
            if obj.setup_done
                return
            end
            obj.get_geodom;
            % ---
            obj.setup_done = 1;
        end
    end
    % --- Methods
    methods
        function get_geodom(obj)
            if ~isempty(obj.parent_model)
                if ~isempty(obj.parent_model.parent_mesh)
                    % ---
                    if ~isempty(obj.id_dom3d)
                        id_dom_ = f_to_scellargin(obj.id_dom3d);
                    elseif ~isempty(obj.id_dom2d)
                        id_dom_ = f_to_scellargin(obj.id_dom2d);
                    end
                    % ---
                    %obj.dom = cell(1,length(id_dom_));
                    %for i = 1:length(id_dom_)
                    %    obj.dom{i} = obj.parent_model.parent_mesh.dom.(id_dom_{i});
                    %end
                    % ---
                    obj.dom = obj.parent_model.parent_mesh.dom.(id_dom_{1});
                    for i = 2:length(id_dom_)
                        obj.dom = obj.dom + obj.parent_model.parent_mesh.dom.(id_dom_{i});
                    end
                end
            end
        end
        % -----------------------------------------------------------------
    end

    % --- Methods
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
            obj.dom.plot(argu{:});
        end
        % -----------------------------------------------------------------
        function plotjv(obj,args)
            arguments
                obj
                args.show_dom = 1
            end
            % ---
            obj.plotfieldv('show_dom',args.show_dom,'field_name','jv')
        end
        % -----------------------------------------------------------------
        function plotev(obj,args)
            arguments
                obj
                args.show_dom = 1
            end
            % ---
            obj.plotfieldv('show_dom',args.show_dom,'field_name','ev')
        end
        % -----------------------------------------------------------------
        function plotbv(obj,args)
            arguments
                obj
                args.show_dom = 1
            end
            % ---
            obj.plotfieldv('show_dom',args.show_dom,'field_name','bv')
        end
        % -----------------------------------------------------------------
        function plotjs(obj,args)
            arguments
                obj
                args.show_dom = 0
            end
            % ---
            if args.show_dom
                obj.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none');
                hold on
            end
            % ---
            sdom = obj.dom;
            if isa(sdom,'SurfaceDom3d')
                id_face = sdom.gid_face;
                face = obj.parent_model.parent_mesh.face(:,id_face);
                node = obj.parent_model.parent_mesh.node;
                js   = obj.parent_model.fields.js(:,id_face);
                js   = f_magnitude(js);
                %--------------------------------------------------------------
                clear msh;
                %--------------------------------------------------------------
                msh.Vertices  = node.';
                msh.FaceColor = 'none';
                msh.EdgeColor = 'none'; % [0.7 0.7 0.7] --> gray
                %--------------------------------------------------------------
                id_tria = find(face(4,:) == 0);
                id_quad = setdiff(1:length(js),id_tria);
                % ---
                if ~isempty(id_tria)
                    msh.Faces = (face(1:3,id_tria)).';
                    msh.FaceVertexCData = f_tocolv(full(js(itria)));
                    msh.FaceColor = 'flat';
                    patch(msh); hold on
                end
                % ---
                if ~isempty(id_quad)
                    msh.Faces = (face(1:4,id_quad)).';
                    msh.FaceVertexCData = f_tocolv(full(js(id_quad)));
                    msh.FaceColor = 'flat';
                    patch(msh); hold on
                end
                % ---
                axis equal; axis tight; view(3); hold on
                %--------------------------------------------------------------
                f_chlogo;
            end
        end
        % -----------------------------------------------------------------
        
    end

    % --- Methods
    methods (Hidden)
        % -----------------------------------------------------------------
        function plotfieldv(obj,args)
            arguments
                obj
                args.show_dom = 1
                args.field_name = []
            end
            % ---
            if args.show_dom
                obj.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none')
            end
            % ---
            if isa(obj.dom,'VolumeDom3d')
                id_elem = obj.dom.gid_elem;
                fv = obj.parent_model.fields.(args.field_name)(:,id_elem);
                no = obj.parent_model.parent_mesh.celem(:,id_elem);
                if isreal(fv)
                    f_quiver(no,fv);
                else
                    subplot(121);
                    f_quiver(no,real(fv)); title('Real part')
                    subplot(122);
                    f_quiver(no,imag(fv)); title('Imag part')
                end
            end
        end
        % -----------------------------------------------------------------
        function plotfields(obj,args)
            arguments
                obj
                args.show_dom = 1
                args.field_name = []
            end
            % ---
            if args.show_dom
                obj.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none')
            end
            % ---
            if isa(obj.dom,'VolumeDom3d')
                node = obj.parent_model.parent_mesh.node;
                elem = obj.parent_model.parent_mesh.elem(:,obj.dom.gid_elem);
                elem_type = f_elemtype(elem);
                face = f_boundface(elem,node,'elem_type',elem_type);
                id_node = f_uniquenode(face);
                fs = obj.parent_model.fields.(args.field_name)(:,id_node);
                no = obj.parent_model.parent_mesh.celem(:,id_elem);
                if isreal(fs)
                    f_quiver(no,fs);
                else
                    subplot(121);
                    f_quiver(no,real(fs)); title('Real part')
                    subplot(122);
                    f_quiver(no,imag(fs)); title('Imag part')
                end
            end
        end
    end
end
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% XTODO - whole class
classdef TfaceField < Xhandle
    properties
        parent_model
        dof
        reference_potential = 0
    end
    properties (Dependent)
        cvalue
        ivalue
        gvalue
        node
    end
    % --- Contructor
    methods
        function obj = TfaceField(args)
            arguments
                args.parent_model {mustBeA(args.parent_model,'PhysicalModel')}
                args.dof {mustBeA(args.dof,'NodeDof')}
                args.reference_potential = 0
            end
            % ---
            obj = obj@Xhandle;
            % ---
            if ~isfield(args,'parent_model') || ~isfield(args,'dof')
                error('#parent_model and #dof must be given !');
            end
            obj <= args;
        end
    end
    % --- Methods/public
    methods
        % -----------------------------------------------------------------
        function val = get.cvalue(obj)
            val = obj.parent_model.parent_mesh.field_wn('dof',obj.dof.value,'on','center') ...
                  + obj.reference_potential;
        end
        % -----------------------------------------------------------------
        function val = get.node(obj)
            val = obj.parent_model.parent_mesh.celem;
        end
    end
    % --- Plot - XTODO
    methods
        % -----------------------------------------------------------------
        function plot(obj,args)
            arguments
                obj
                args.meshdom_obj = []
                args.id_meshdom = []
                args.id_elem = []
                args.id_face = []
                args.show_dom = 1
            end
            % ---
            if isempty(args.id_meshdom)
                args.show_dom = 0;
                % ---
                if isempty(args.meshdom_obj)
                    if isempty(args.id_elem)
                        if isempty(args.id_face)
                            text(0,0,'Nothing to plot !');
                            return
                        else
                            dom = SurfaceDom3d;
                            gid_face = args.id_face;
                        end
                    else
                        dom = VolumeDom3d;
                        gid_elem = args.id_elem;
                    end
                else
                    dom = args.meshdom_obj;
                    % ---
                    if isa(dom,'VolumeDom3d')
                        gid_elem = dom.gid_elem;
                    end
                    % ---
                    if isa(dom,'SurfaceDom3d')
                        gid_face = dom.gid_face;
                    end
                end
            else
                dom = obj.parent_model.parent_mesh.dom.(args.id_meshdom);
                % ---
                if isa(dom,'VolumeDom3d')
                    gid_elem = dom.gid_elem;
                end
                % ---
                if isa(dom,'SurfaceDom3d')
                    gid_face = dom.gid_face;
                end
            end
            % ---
            if args.show_dom
                dom.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none')
            end
            % ---
            if isa(dom,'VolumeDom3d')
                node_ = obj.parent_model.parent_mesh.node;
                elem = obj.parent_model.parent_mesh.elem(:,gid_elem);
                f_patch('node',node_,'elem',elem,'elem_field',obj.cvalue(gid_elem(id_elem_of_face)));
            end
            % ---
            if isa(dom,'SurfaceDom3d')
                node_ = obj.parent_model.parent_mesh.node;
                face = obj.parent_model.parent_mesh.face(:,gid_face);
                % ---
                f_patch(node_,face,'defined_on','face','scalar_field',obj.cvalue);
            end
        end
        % -----------------------------------------------------------------
    end
end
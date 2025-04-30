%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef TelemField < Xhandle
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
        function obj = TelemField(args)
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
                args.show_dom = 1
            end
            % ---
            if isempty(args.id_meshdom)
                args.show_dom = 0;
                % ---
                if isempty(args.meshdom_obj)
                    if isempty(args.id_elem)
                        text(0,0,'Nothing to plot !');
                    else
                        gid_elem = args.id_elem;
                    end
                else
                    dom = args.meshdom_obj;
                    if isa(dom,'VolumeDom3d')
                        gid_elem = dom.gid_elem;
                    else
                        text(0,0,'Nothing to plot, dom must be a VolumeDom3d !');
                    end
                end
            else
                dom = obj.parent_model.parent_mesh.dom.(args.id_meshdom);
                if isa(dom,'VolumeDom3d')
                    gid_elem = dom.gid_elem;
                else
                    text(0,0,'Nothing to plot, dom must be a VolumeDom3d !');
                end
            end
            % ---
            if args.show_dom
                dom.plot('alpha',0.5,'edge_color',[0.9 0.9 0.9],'face_color','none')
            end
            % ---
            node_ = obj.parent_model.parent_mesh.node;
            elem = obj.parent_model.parent_mesh.elem(:,gid_elem);
            f_patch('node',node_,'elem',elem,'elem_field',obj.cvalue(gid_elem));
        end
        % -----------------------------------------------------------------
    end
end
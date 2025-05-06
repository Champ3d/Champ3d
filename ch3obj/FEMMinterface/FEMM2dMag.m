%--------------------------------------------------------------------------
% Interface to FEMM
% FEMM (c) David Meeker 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
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

classdef FEMM2dMag < Xhandle
    properties
        id_project
        fr
        unit
        problem_type
        precision = 1e-8
        depth
        min_angle
        acsolver
        % ---
        femmfile
        meshfile
        % ---
        material
        circuit
        coil
        pmagnet
        bc
        draw
        box
        dom
        bound
        moveframe
        % --- for champ3d
        mesh
        dof
        field
        matrix
        % ---
    end
    properties (Hidden)
        reset_mesh = 1
        reset_dom = 1;
        % ---
        last_move
    end

    % --- Constructor
    methods
        function obj = FEMM2dMag(args)
            arguments
                args.id_project
                args.fr {mustBeNumeric} = 0
                args.unit {mustBeMember(args.unit,{'millimeters','centimeters','meters','micrometers'})} = 'meters'
                args.problem_type {mustBeMember(args.problem_type,{'planar','axi'})} = 'axi'
                args.precision {mustBeNumeric} = 1e-8
                args.depth {mustBeNumeric} = 1
                args.min_angle {mustBeNumeric} = 15
                args.acsolver {mustBeMember(args.acsolver,{'newton','successive_approximation'})} = 'newton'
            end
            % ---
            if args.precision > 1e-8
                args.precision = 1e-8;
            end
            % ---
            obj@Xhandle;
            % ---
            obj <= args;
            % ---
            obj.femmfile  = [obj.id_project '.fem'];
            obj.meshfile  = [obj.id_project '.ans'];
            % ---
            obj.add_material('id_material','by_default','material',FEMM2dMaterial());
            % ---
            obj.save;
        end
    end

    % --- Methods/public
    methods (Access = public)
        % -----------------------------------------------------------------
        function add_material(obj,args)
            arguments
                obj
                args.id_material = 'undefined';
                args.material {mustBeA(args.material,'FEMM2dMaterial')}
                % ---
            end
            % ---
            if f_strcmpi(args.id_material,'undefined')
                warning('id_material undefined');
            end
            % ---
            obj.material.(args.id_material) =+ args.material;
            obj.material.(args.id_material).parent_model = obj;
            % ---
            % obj.update_material(obj.material.(args.id_material));
            % ---
        end
        % -----------------------------------------------------------------
        function add_bc(obj,args)
            arguments
                obj
                args.id_bc = 'undefined';
                args.bc {mustBeA(args.bc,'FEMM2dBC')}
            end
            % ---
            if f_strcmpi(args.id_bc,'undefined')
                warning('id_bc undefined');
            end
            % ---
            obj.bc.(args.id_bc) =+ args.bc;
            obj.bc.(args.id_bc).parent_model = obj;
            % ---
        end
        % -----------------------------------------------------------------
        function add_circuit(obj,args)
            arguments
                obj
                args.id_circuit = 'undefined';
                args.circuit {mustBeA(args.circuit,'FEMM2dCircuit')}
            end
            % ---
            if f_strcmpi(args.id_circuit,'undefined')
                warning('id_circuit undefined');
            end
            % ---
            obj.circuit.(args.id_circuit) =+ args.circuit;
            obj.circuit.(args.id_circuit).id_circuit = args.id_circuit;
            obj.circuit.(args.id_circuit).parent_model = obj;
            % ---
        end
        % -----------------------------------------------------------------
        function add_jscoil(obj,args)
            arguments
                obj
                args.id_coil = 'undefined';
                args.id_wire = 'undefined';
                args.j
            end
            % ---
            if f_strcmpi(args.id_coil,'undefined')
                warning('id_coil undefined');
            end
            % ---
            if f_strcmpi(args.id_wire,'undefined')
                warning('id_wire undefined');
            end
            % ---
            obj.coil.(args.id_coil) =+ FEMM2dJsCoil;
            obj.coil.(args.id_coil).id_wire = args.id_wire;
            obj.coil.(args.id_coil).id_coil = args.id_coil;
            obj.coil.(args.id_coil).j = args.j;
            obj.coil.(args.id_coil).parent_model = obj;
            % ---
        end
        % -----------------------------------------------------------------
        function add_iscoil(obj,args)
            arguments
                obj
                args.id_coil = 'undefined';
                args.id_wire = 'undefined';
                args.id_circuit = 'undefined';
                args.nb_turn = 0
            end
            % ---
            if f_strcmpi(args.id_coil,'undefined')
                warning('id_coil undefined');
            end
            % ---
            if f_strcmpi(args.id_wire,'undefined')
                warning('id_wire undefined');
            end
            % ---
            if f_strcmpi(args.id_circuit,'undefined')
                warning('id_circuit undefined');
            end
            % ---
            obj.coil.(args.id_coil) =+ FEMM2dIsCoil;
            obj.coil.(args.id_coil).id_wire = args.id_wire;
            obj.coil.(args.id_coil).nb_turn = args.nb_turn;
            obj.coil.(args.id_coil).id_circuit = args.id_circuit;
            obj.coil.(args.id_coil).id_coil = args.id_coil;
            obj.coil.(args.id_coil).parent_model = obj;
            % ---
        end
        % -----------------------------------------------------------------
        function add_draw(obj,args)
            % -------------------------------------------------------------
            arguments
                obj
                args.id_draw = 'undefined';
                args.draw {mustBeA(args.draw,'FEMM2dDraw')}
            end
            % ---
            if f_strcmpi(args.id_draw,'undefined')
                warning('id_draw undefined');
            end
            % ---
            obj.draw.(args.id_draw) =+ args.draw;
            obj.draw.(args.id_draw).parent_model = obj;
            % ---
            obj.reset_mesh = 1;
            obj.reset_dom = 1;
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function add_box(obj,args)
            % -------------------------------------------------------------
            arguments
                obj
                args.id_box = 'undefined';
                args.draw {mustBeA(args.draw,{'FEMM2dRectangle','FEMM2dHalfDisk','FEMM2dArcRectangle','FEMM2dCircle'})}
            end
            % ---
            if f_strcmpi(args.id_box,'undefined')
                warning('id_box undefined');
            end
            % ---
            obj.box.(args.id_box) =+ args.draw;
            obj.box.(args.id_box).parent_model = obj;
            % ---
            obj.reset_mesh = 1;
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function add_moveframe(obj,args)
            % -------------------------------------------------------------
            arguments
                obj
                args.id_moveframe = 'undefined';
                args.moveframe {mustBeA(args.moveframe,'FEMM2dMovingFrame')}
            end
            % ---
            if f_strcmpi(args.id_moveframe,'undefined')
                warning('id_moveframe undefined');
            end
            % ---
            obj.moveframe.(args.id_moveframe) =+ args.moveframe;
            obj.moveframe.(args.id_moveframe).parent_model = obj;
            obj.moveframe.(args.id_moveframe).id_moveframe = args.id_moveframe;
            % -------------------------------------------------------------
        end
        % -----------------------------------------------------------------
        function set_dom(obj,args)
            arguments
                obj
                args.id_dom = 'undefined';
                args.id_draw = 'undefined';
                args.id_material = 'by_default';
                args.id_coil
                args.choosed_by {mustBeMember(args.choosed_by,...
                    {'center','bottomleft','bottomright',...
                     'topleft','topright','bottom','top',...
                     'right','left'})} = 'center'
                args.mesh_size = 0
                args.auto_pm_direction = []
                args.pm_direction = []
            end
            % ---
            if f_strcmpi(args.id_dom,'undefined')
                warning('id_dom undefined');
            end
            % ---
            if f_strcmpi(args.id_draw,'undefined')
                warning('id_draw undefined');
            end
            % ---
            if any(f_strcmpi(args.id_material,{'<no mesh>','nomesh','no_mesh','none'}))
                args.id_material = '<No Mesh>';
            end
            % ---
            obj.dom.(args.id_dom) = FEMM2dVdom;
            obj.dom.(args.id_dom) <= args;
            obj.dom.(args.id_dom).parent_model = obj;
            % ---
            obj.reset_dom = 1;
        end
        % -----------------------------------------------------------------
        function set_bound(obj,args)
            arguments
                obj
                args.id_bound = 'undefined';
                args.id_bc = [];
                args.id_box
                args.choosed_by {mustBeMember(args.choosed_by,...
                    {'all','bottom','top','right','left'})} = 'all'
                args.max_segment_len = 0
                args.max_segment_arclen = 0
                args.auto_mesh = 1
            end
            % ---
            if f_strcmpi(args.id_bound,'undefined')
                warning('id_bound undefined');
            end
            % ---
            if isempty(args.id_bc)
                warning('id_bc must be given');
            end
            % ---
            if isempty(args.choosed_by)
                warning('choosed_by must be given');
            end
            % ---
            obj.bound.(args.id_bound) = FEMM2dBound;
            obj.bound.(args.id_bound) <= args;
            obj.bound.(args.id_bound).parent_model = obj;
            % ---
        end
        % -----------------------------------------------------------------
        function add_line(obj,args)
            
        end
        % -----------------------------------------------------------------
        function setup(obj)
            if obj.reset_mesh
                % --- must setup box first !!!
                if ~isempty(obj.box)
                    id__ = fieldnames(obj.box);
                    for i = 1:length(id__)
                        obj.box.(id__{i}).setup;
                        obj.box.(id__{i}).setbound(id__{i});
                    end
                end
                % ---
                if ~isempty(obj.bc)
                    id__ = fieldnames(obj.bc);
                    for i = 1:length(id__)
                        obj.bc.(id__{i}).setup(id__{i});
                    end
                end
                % ---
                if ~isempty(obj.bound)
                    id__ = fieldnames(obj.bound);
                    for i = 1:length(id__)
                        obj.bound.(id__{i}).setup;
                    end
                end
                % ---
                if ~isempty(obj.material)
                    id__ = fieldnames(obj.material);
                    for i = 1:length(id__)
                        obj.material.(id__{i}).setup(id__{i});
                    end
                end
                % ---
                if ~isempty(obj.circuit)
                    id__ = fieldnames(obj.circuit);
                    for i = 1:length(id__)
                        obj.circuit.(id__{i}).setup;
                    end
                end
                % ---
                if ~isempty(obj.coil)
                    id__ = fieldnames(obj.coil);
                    for i = 1:length(id__)
                        obj.coil.(id__{i}).setup(id__{i});
                    end
                end
                % ---
                if ~isempty(obj.draw)
                    id__ = fieldnames(obj.draw);
                    for i = 1:length(id__)
                        obj.draw.(id__{i}).setup;
                    end
                end
                % ---
                if ~isempty(obj.dom)
                    id__ = fieldnames(obj.dom);
                    for i = 1:length(id__)
                        obj.dom.(id__{i}).setup(id__{i});
                        obj.dom.(id__{i}).id_femm = i; % id in femm file
                    end
                end
                % ---
                obj.reset_mesh = 0;
                obj.reset_dom = 0;
            end
            % ---
            if obj.reset_dom
                if ~isempty(obj.dom)
                    id__ = fieldnames(obj.dom);
                    for i = 1:length(id__)
                        obj.dom.(id__{i}).setup(id__{i});
                    end
                end
                obj.reset_dom = 0;
            end
        end
        % -----------------------------------------------------------------
        function solve(obj)
            % --- update problem
            if f_strcmpi(obj.acsolver,'successive_approximation')
                acsolver_ = 0;
            else
                acsolver_ = 1;
            end
            try 
                mi_probdef(obj.fr, obj.unit, obj.problem_type, obj.precision, ...
                    obj.depth, obj.min_angle, acsolver_);
            catch
                fprintf(['No FEMM opened. \n']);
                fprintf(['Load ' obj.femmfile '\n']);
                % ---
                closefemm;
                openfemm;
                opendocument(obj.femmfile);
                mi_probdef(obj.fr, obj.unit, obj.problem_type, obj.precision, ...
                    obj.depth, obj.min_angle, acsolver_);
            end
            % --- update mesh / dom
            if obj.reset_mesh || obj.reset_dom
                obj.setup;
            end
            % --- update dom
            % --- update material
            % --- update pmagnet dir_mag
            % --- update b-h data
            % --- update circuit properties
            % ---
            if ~isempty(obj.bc)
                id__ = fieldnames(obj.bc);
                for i = 1:length(id__)
                    obj.bc.(id__{i}).setup(id__{i});
                end
            end
            % ---
            if ~isempty(obj.material)
                id__ = fieldnames(obj.material);
                for i = 1:length(id__)
                    obj.material.(id__{i}).setup(id__{i});
                end
            end
            % ---
            if ~isempty(obj.circuit)
                id__ = fieldnames(obj.circuit);
                for i = 1:length(id__)
                    obj.circuit.(id__{i}).setup;
                end
            end
            % ---
            if ~isempty(obj.dom)
                id__ = fieldnames(obj.dom);
                for i = 1:length(id__)
                    if obj.dom.(id__{i}).is_pmagnet
                        obj.dom.(id__{i}).setpmdir;
                    end
                end
            end
            % ---
            f_fprintf(0,'Solving 2d problem with FEMM',0,'\n');
            tic;
            mi_analyze(1);
            % --- Log message
            f_fprintf(0, '--- in',...
                      1, toc,...
                      0, 's \n');
        end
        % -----------------------------------------------------------------
        function getdata(obj)
            % --- load mesh and solution of A
            mesh_ = TriMeshFromFemm('mesh_file',obj.meshfile);
            % --- add dom by id number
            id_alldom = fieldnames(obj.dom);
            nbdom = length(id_alldom);
            id_femm = zeros(1,nbdom);
            for i = 1:nbdom
                id_femm(i) = obj.dom.(id_alldom{i}).id_femm;
            end
            % ---
            for i = 1:nbdom
                id_dom = id_alldom{i};
                mesh_.add_vdom('id',id_dom,'elem_code',id_femm(i));
                obj.dom.(id_dom).meshdom = mesh_.dom.(id_dom);
            end
            % ---
            mesh_.build_intkit;
            % ---
            dof_.a = mesh_.data;
            if f_strcmpi(obj.problem_type,'axi')
                dof_.a = dof_.a ./ (2*pi*mesh_.node(1,:).');
            end
            % --- correct a (necessary due to singularity)
            dof_.a(isnan(dof_.a)) = 0;
            % ---
            nb_elem = size(mesh_.intkit.cgradWn{1},1);
            dim = size(mesh_.intkit.cgradWn{1},2);
            field_.b = zeros(nb_elem,dim);
            field_.a = zeros(nb_elem,1);
            for iN = 1:mesh_.refelem.nbNo_inEl
                % ---
                field_.b(:,2) = field_.b(:,2) + mesh_.intkit.cgradWn{1}(:,1,iN) .* dof_.a(mesh_.elem(iN,:));
                field_.b(:,1) = field_.b(:,1) + mesh_.intkit.cgradWn{1}(:,2,iN) .* dof_.a(mesh_.elem(iN,:));
                % ---
                field_.a(:,1) = field_.a(:,1) + mesh_.intkit.cWn{1}(:,iN) .* dof_.a(mesh_.elem(iN,:));
                % ---
            end
            field_.b(:,1) = - field_.b(:,1);
            % ---
            if f_strcmpi(obj.problem_type,'axi')
                field_.b(:,2) = field_.b(:,2) + (1./mesh_.celem(1,:).') .* field_.a;
            end
            % -------------------------------------------------------------
            obj.mesh = mesh_;
            obj.dof  = dof_;
            obj.field = field_;
        end
        % -----------------------------------------------------------------
        function open(obj)
            % ---
            closefemm;
            openfemm;
            opendocument(obj.femmfile);
            % ---
            if isfile(obj.meshfile)
                mi_loadsolution;
            end
        end
        % -----------------------------------------------------------------
        function createmesh(obj)
            try 
                % --- update mesh / dom
                if obj.reset_mesh || obj.reset_dom
                    obj.setup;
                end
                mi_analyse;
            catch
                fprintf(['No FEMM opened. \n']);
                fprintf(['Load ' obj.femmfile '\n']);
                % ---
                closefemm;
                openfemm;
                opendocument(obj.femmfile);
                % --- update mesh / dom
                if obj.reset_mesh || obj.reset_dom
                    obj.setup;
                end
                mi_analyse;
                % ---
            end
        end
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        function selectcircle(obj,args)
            arguments
                obj
                args.ref_point = [0,0] % must be in Oxy coordinates
                args.cen_x = 0
                args.cen_y = 0
                args.cen_r = 0
                args.cen_theta = 0
                args.r = 0
            end
            % ---
            argu = f_to_namedarg(args);
            % ---
            choosewindow = FEMM2dCircle(argu{:});
            % ---
            mi_clearselected;
            % ---
            mi_seteditmode('group');
            mi_selectcircle(choosewindow.center(1),choosewindow.center(2),...
                            choosewindow.r);
            % ---
            obj.last_move.window = 'circ';
            obj.last_move.select.center = choosewindow.center;
            obj.last_move.select.r = choosewindow.r;
            % ---
            clear choosewindow;
            % ---
        end
        % -----------------------------------------------------------------
    end
    % --- Methods/protected
    methods (Access = protected)
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
    end
    % --- Methods/private
    methods (Access = private)
        % -----------------------------------------------------------------
        function save(obj)
            closefemm
            openfemm
            if contains(obj.femmfile,'.fem')
                id_doc_ = 0;
                newdocument(id_doc_);
                mi_saveas(obj.femmfile);
                %mi_minimize;
            end
        end
        % -----------------------------------------------------------------
        function reset_dom_groupe(obj)
            if ~isempty(obj.dom)
                id__ = fieldnames(obj.dom);
                for i = 1:length(id__)
                    % ---
                    [px, py] = obj.dom.(id__{i}).get_choosed_point;
                    % ---
                    id_groupe_ = [id_dom '_dom'];
                    obj.dom.(id__{i}).id_group = f_str2code(id_groupe_,'code_type','integer');
                    %--------------------------------------------------------------
                    mi_clearselected;
                    mi_addblocklabel(px,py);
                    mi_selectlabel(px,py);
                    mi_setgroup(obj.dom.(id__{i}).id_group);
                    mi_clearselected;
                end
            end
        end
        % -----------------------------------------------------------------
        function update_material(obj,id_)
            matobj = obj.material.(id_);
            mi_deletematerial(id_);
            mi_addmaterial(id_,matobj.mur_x,matobj.mur_y,matobj.hc,matobj.j/1e6,...
                           matobj.sigma/1e6,matobj.lam_d,matobj.phi_hmax,...
                           matobj.lam_fill,matobj.material_type,matobj.phi_hx,matobj.phi_hy,...
                           matobj.nb_strand,matobj.wire_diameter/1000);
        end
        % -----------------------------------------------------------------
        function update_bc(obj,bcobj)
            %mi_addboundprop(bcobj.id_bc, bcobj.a0, bcobj.a1, bcobj.a2, ...
            %    bcobj.phi, bcobj.mur, bcobj.sigma, ...
            %    bcobj.c0, bcobj.c1, ...
            %    bcobj.bc_type, bcobj.ia, bcobj.oa);
        end
        % -----------------------------------------------------------------
        function update_circuit(obj,id_)
            cirobj = obj.circuit.(id_);
            mi_deletecircuit(id_);
            mi_addcircprop(id_,cirobj.i,cirobj.connexion);
        end
        % -----------------------------------------------------------------
        function check_completude(obj)
            % --- all vdom associated with a material
        end
        % -----------------------------------------------------------------
        function problem_info(obj)
            info = mo_getprobleminfo;
            pb_type = info(1);
            pb_fr = info(2);
            pb_depth = info(3);
            if (pb_type == 1)
                pb_type = 'axisymmetric';
            elseif (pb_type == 0)
                pb_type = 'planar';
            else
                pb_type = 'undefined';
            end
            % ---
            f_fprintf(0,'FEMM2d problem =',1,pb_type,0,'fr =',1,pb_fr,0,'depth =',1,pb_depth,0,'\n');
        end
        % -----------------------------------------------------------------
    end
end
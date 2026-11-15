%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2026 with AI assistance
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

classdef QuadMeshCircles < QuadMesh
    properties
        id_dom
        radius
        % ---
        anum = 3 % angle division
        rnum = 3 % nb of layers in each region
        rtype
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
            argslist = {'id','id_dom','radius','anum','rnum','rtype'};
        end
    end
    % --- Constructors
    methods
        function obj = QuadMeshCircles(args)
            arguments
                args.id_dom
                args.radius
                args.anum % angle division
                args.rnum % nb of layers in each region
                args.rtype % 'lin','log+','log-','log+-','log-+','log=' (1 ou 1xn)
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
            QuadMeshCircles.setup(obj);
            % ---
        end
    end
    % --- setup
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
            radius_ = obj.radius;
            rnum_   = obj.rnum;
            anum_   = obj.anum;
            % ---
            radius_ = radius_(:).';
            n = numel(radius_);
            assert(all(radius_ > 0) && all(diff(radius_) > 0), ...
                'radius doit être strictement croissant et positif');
            rnum_ = rnum_(:).';
            if isscalar(rnum_), rnum_ = rnum_*ones(1, n); end
            assert(numel(rnum_) == n, 'rnum doit être scalaire ou de taille 1xn');
            N = 4*anum_;  % noeuds par anneau
            % --- Division radiale de chaque région par Line1d
            rtype_ = obj.rtype;
            if isempty(rtype_), rtype_ = 'lin'; end
            if ischar(rtype_) || isstring(rtype_), rtype_ = cellstr(rtype_); end
            if isscalar(rtype_), rtype_ = repmat(rtype_, 1, n); end
            assert(numel(rtype_) == n, 'rtype doit être scalaire ou de taille 1xn');
            % ---
            rtype_{1} = 'lin';
            % ---
            tcum = cell(1, n);   % positions normalisées (0..1] des couches
            for q = 1:n
                ln = Line1d('id',['rline' num2str(q)],'len',1, ...
                              'dtype',rtype_{q},'dnum',rnum_(q));
                tcum{q} = cumsum(ln.node)/sum(ln.node);
            end
            % a tel que l'épaisseur radiale de la 1ère couche (R-a)*t1
            % = taille du coeur 2a/anum
            t1 = tcum{1}(1);
            a = min(radius_(1)*t1/(t1 + 2/anum_), 0.95*radius_(1)/sqrt(2)); % 95% of r1
            % --- Coeur carré (m x m éléments) de demi-côté a
            I = repmat((0:anum_).', anum_+1, 1);              % i varie le plus vite (x)
            J = repelem((0:anum_).', anum_+1);                % j varie lentement (y)
            node = [-a + 2*a*I/anum_, -a + 2*a*J/anum_];
            id = @(i, j) i + (anum_+1)*j + 1;             % indice du noeud (i,j)
            % ---
            elem = zeros(anum_*anum_, 4);
            e = 0;
            for j = 0:anum_-1
                for i = 0:anum_-1
                    e = e + 1;
                    elem(e,:) = [id(i,j) id(i+1,j) id(i+1,j+1) id(i,j+1)];
                end
            end
            elem_code = ones(anum_*anum_, 1);
            % --- Anneau frontière du carré (4m noeuds, sens trigo, départ coin (a,-a))
            ring = zeros(N, 1);
            k = 0;
            for j = 0:anum_-1,  k = k+1; ring(k) = id(anum_, j);   end   % côté droit  (montant)
            for i = anum_:-1:1, k = k+1; ring(k) = id(i, anum_);   end   % côté haut   (vers -x)
            for j = anum_:-1:1, k = k+1; ring(k) = id(0, j);   end   % côté gauche (descendant)
            for i = 0:anum_-1,  k = k+1; ring(k) = id(i, 0);   end   % côté bas    (vers +x)
            P0 = node(ring, :);                        % positions sur le carré
            th = -pi/4 + 2*pi*(0:N-1).'/N;             % angles uniformes sur les cercles
            U  = [cos(th) sin(th)];                    % directions radiales
            % --- Couches radiales
            rin   = [0 radius_(1:end-1)];               % rayon intérieur de chaque région
            prev  = ring;                              % indices de l'anneau précédent
            for q = 1:n
                L = numel(tcum{q});
                for l = 1:L
                    t = tcum{q}(l);
                    if q == 1
                        P = (1-t)*P0 + t*radius_(1)*U;          % carré -> cercle 1
                    else
                        P = ((1-t)*rin(q) + t*radius_(q)) * U;  % couronne q
                    end
                    cur = size(node,1) + (1:N).';
                    node = [node; P]; %#ok<AGROW>
                    kn = [2:N 1].';
                    elem = [elem; prev, cur, cur(kn), prev(kn)]; %#ok<AGROW>
                    elem_code  = [elem_code; q*ones(N,1)]; %#ok<AGROW>
                    prev = cur;
                end
            end
            % --- Orientation anti-horaire garantie (aire signée > 0), sinon inversion
            x = reshape(node(elem, 1), [], 4);
            y = reshape(node(elem, 2), [], 4);
            sgn = sum(x .* y(:, [2 3 4 1]) - x(:, [2 3 4 1]) .* y, 2);   % 2 x aire signée
            cw = sgn < 0;
            elem(cw, :) = elem(cw, [1 4 3 2]);
            assert(all(sgn ~= 0), 'élément dégénéré (aire nulle)');
            % ---
            obj.node = node.';
            obj.elem = elem.';
            % --- check and correct mesh
            [obj.node,obj.elem] = f_reorg2d(obj.node,obj.elem);
            % ---
            obj.elem_code = elem_code.';
            % --- 2d elem surface
            obj.velem = f_volume(node.',elem.','elem_type',obj.elem_type);
            % --- edge length
            % obj.sface = f_area(node_,face_);
            % --- region id
            for idd = 1:length(obj.radius)
                obj.add_vdom("id",obj.id_dom{idd},"elem_code",idd);
            end
        end
    end
    methods (Access = public)
        function reset(obj)
            QuadMeshCircles.setup(obj);
            % --- reset dependent obj
            obj.reset_dependent_obj;
        end
    end
    % --- build
    methods
        function build(obj)
            % ---
            if obj.build_done
                return
            end
            % ---
            if ~obj.build_meshds_done
                obj.build_meshds;
                obj.build_meshds_done = 1;
            end
            if ~obj.build_discrete_done
                obj.build_discrete;
                obj.build_discrete_done = 1;
            end
            if ~obj.build_intkit_done
                obj.build_intkit;
                obj.build_intkit_done = 1;
            end
            % ---
            obj.build_done = 1;
            % ---
        end
    end
end
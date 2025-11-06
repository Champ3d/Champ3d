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

classdef ProcessingLine3d < ProcessingSurface3d

    % --- Properties
    properties
        line
        dtype
        dnum
        len
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end
    
    % --- Valid args list
    methods (Static)
        function argslist = validargs()
            argslist = {'parent_model','line','dtype','dnum','flog','id_dom3d'};
        end
    end
    % --- Constructors
    methods
        function obj = ProcessingLine3d(args)
            arguments
                % ---
                args.parent_model = []
                args.line = []
                args.dtype {mustBeMember(args.dtype,{'lin','log+','log-','log+-','log-+','log='})} = 'lin'
                args.dnum = 6
                args.flog = 1.05;
                args.id_dom3d = []
            end
            % ---
            obj <= args;
            % ---
            if isempty(obj.id_dom3d)
                obj.id_dom3d = 'whole_mesh_dom';
            end
            % ---
            obj.parent_mesh = obj.parent_model.parent_mesh;
            % ---
            if f_is_available(args,{'line'})
                % ---
                if size(obj.line,1) == 3
                    obj.line = obj.line.';
                end
                % ---
                if any(f_strcmpi(obj.dtype,{'log+-','log-+','log='}))
                    if mod(obj.dnum,2) ~= 0
                        obj.dnum = obj.dnum + 1;
                    end
                end
                % ---
                obj.build;
            end
        end
    end

    % --- Methods
    methods
        % -----------------------------------------------------------------
        function build(obj)
            % ---
            e = 1e-6;
            % ---
            plin01 = obj.line - [e e 0];
            plin02 = obj.line + [e e 0];
            surf01 = ProcessingSurface3d('parent_model',obj.parent_model,...
                                   'id_dom3d',obj.id_dom3d, ...
                                   'parallel_line_1',plin01,...
                                   'parallel_line_2',plin02,...
                                   'dnum_orthogonal',1,...
                                   'dnum_parallel',1,...
                                   'dtype_orthogonal','lin',...
                                   'dtype_parallel','lin');
            % ---
            plin01 = obj.line - [e 0 e];
            plin02 = obj.line + [e 0 e];
            surf02 = ProcessingSurface3d('parent_model',obj.parent_model,...
                                   'id_dom3d',obj.id_dom3d, ...
                                   'parallel_line_1',plin01,...
                                   'parallel_line_2',plin02,...
                                   'dnum_orthogonal',1,...
                                   'dnum_parallel',1,...
                                   'dtype_orthogonal','lin',...
                                   'dtype_parallel','lin');
            % ---
            obj.gindex = intersect(surf01.gindex,surf02.gindex);
            % ---
            obj.mesh.node = f_divline(obj.line(1,:),obj.line(2,:),...
                                      'dnum',obj.dnum, ...
                                      'dtype',obj.dtype, ...
                                      'flog',obj.flog);
            obj.mesh.nb_node = size(obj.mesh.node,2);
            % ---
            ep1 = obj.mesh.node(:,1:end-1);
            ep2 = obj.mesh.node(:,2:end);
            vp  = ep2 - ep1;
            lv  = f_norm(vp);
            obj.len = [0 cumsum(lv)];
        end
        % -----------------------------------------------------------------
    end
    % ---------------------------------------------------------------------
    methods
        function plot(obj,args)
            arguments
                obj
                args.color = [0.4940 0.1840 0.5560]
                args.id_field = []
            end
            % ---
            color = args.color;
            mshalone  = 1;
            forcomplx = 1;
            forvector = 1;
            fval      = [];
            for3d     = 0;
            % ---
            id_field = args.id_field;
            if ~isempty(id_field)
                if isfield(obj.field,id_field)
                    fval = obj.field.(id_field);
                end
            end
            % ---
            if ~isempty(fval)
                mshalone = 0;
                fval = f_column_format(fval);
            end
            %--------------------------------------------------------------
            node = obj.mesh.node;
            %--------------------------------------------------------------
            if mshalone
                plot3(node(1,:),node(2,:),node(3,:),'ro');
                %f_showaxis(3,3)
                return
            end
            %--------------------------------------------------------------
            % ---
            if isreal(fval)
                forcomplx = 0;
            end
            % ---
            if size(fval,2) == 1
                forvector = 0;
            end
            % ---
            if size(fval,2) == 3
                for3d = 1;
            end
            %--------------------------------------------------------------
            if forvector
                fx = fval(:,1);
                fy = fval(:,2);
                if for3d
                    fz = fval(:,3);
                end
            end
            %--------------------------------------------------------------
            if forvector
                if forcomplx
                    % ---
                    subplot(131);
                    magf = f_magnitude(fval.');
                    plot(obj.len,magf,'Color',color);
                    title('Magnitude');
                    xlabel('length (m)');
                    % ---
                    subplot(132);
                    f_quiver(node,real(fval.'));
                    title('Real part')
                    f_showaxis(3,3);
                    % ---
                    subplot(133);
                    f_quiver(node,imag(fval.'));
                    title('Imag part')
                    f_showaxis(3,3);
                else
                    % ---
                    subplot(121);
                    magf = f_magnitude(fval.');
                    plot(obj.len,magf,'Color',color);
                    title('Magnitude');
                    xlabel('length (m)');
                    % ---
                    subplot(122);
                    f_quiver(node,fval.');
                    f_showaxis(3,3);
                end
            else
                if forcomplx
                    subplot(121);
                    magf = f_magnitude(fval.');
                    plot(obj.len,magf,'Color',color);
                    title('Magnitude');
                    xlabel('length (m)');
                    subplot(122);
                    magf = real(fval.');
                    plot(obj.len,magf,'Color',color);
                    title('Real part');
                    xlabel('length (m)');
                    subplot(123);
                    magf = imag(fval.');
                    plot(obj.len,magf,'Color',color);
                    title('Imag Part');
                    xlabel('length (m)');
                else
                    plot(obj.len,fval,'Color',color);
                    title(args.id_field);
                    xlabel('length (m)');
                end
            end
        end
    end
end




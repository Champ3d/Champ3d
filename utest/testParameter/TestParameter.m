classdef TestParameter < matlab.unittest.TestCase
    % Unit tests of the ch3obj/XParameter classes :
    % Parameter, ScalarParameter, VectorParameter, TensorParameter, FreeParameter
    %
    % Sample models are generated once by run_create_test_models.m
    % (adapted from tutorial/parameter/run_create_model.m) :
    %   model01 vs. model02 --- same parent_mesh models + same ltime
    %   model01 vs. model03 --- same parent_mesh models + diff ltime
    %   model01 vs. model04 --- diff parent_mesh models + diff ltime
    %
    % run with (champ3d folders on the MATLAB path) :
    %   addpath('utest/testParameter');
    %   results = runtests('TestParameter');
    %
    % /!\ this folder also contains the refactored Parameter.m proposal :
    %     when the folder comes before ch3obj/XParameter on the path, the
    %     tests run against the refactored version (see README.md).

    properties
        model01
        model02
        model03
        model04
        vdom % thconductor.plate        --- VolumeDom  (place = elem)
        sdom % convection.plate_surface --- SurfaceDom (place = face)
    end

    methods (TestClassSetup)
        function load_sample_models(testCase)
            here = fileparts(mfilename('fullpath'));
            matfile = fullfile(here,'sample_models_testParameter.mat');
            if ~isfile(matfile)
                run_create_test_models();
            end
            % ---
            data = load(matfile);
            testCase.model01 = data.model01;
            testCase.model02 = data.model02;
            testCase.model03 = data.model03;
            testCase.model04 = data.model04;
            % ---
            testCase.vdom = data.model01.thconductor.plate;
            testCase.sdom = data.model01.convection.plate_surface;
        end
    end

    %----------------------------------------------------------------------
    % --- construction / parsing (no model needed)
    methods (Test)
        %------------------------------------------------------------------
        function constant_scalar(testCase)
            p = Parameter('f',5);
            testCase.verifyEqual(p.getvalue,5);
        end
        %------------------------------------------------------------------
        function constant_vector_is_column(testCase)
            p = Parameter('f',[1 2 3]);
            testCase.verifyEqual(p.getvalue,[1;2;3]);
        end
        %------------------------------------------------------------------
        function constant_tensor(testCase)
            t = [1 4 0; 4 2 0; 0 0 3];
            p = Parameter('f',t);
            testCase.verifyEqual(p.getvalue,t);
        end
        %------------------------------------------------------------------
        function constant_invalid_errors(testCase)
            % neither scalar, 2/3-vector nor 2x2/3x3 tensor
            testCase.verifyError(@()Parameter('f',ones(1,4)),?MException);
        end
        %------------------------------------------------------------------
        function f_not_fhandle_errors(testCase)
            testCase.verifyError(@()Parameter('f','sigma'),?MException);
        end
        %------------------------------------------------------------------
        function depend_on_token_parsing(testCase)
            p = Parameter('parent_model',testCase.model01,'f',@(v,t)(v.*t),...
                          'depend_on',{'V(-1).mycoil','ltime'},'from',testCase.model01);
            % --- 'V(-1).mycoil' --> quantity V, previous time step, coil id
            testCase.verifyEqual(p.depend_on{1},'V');
            testCase.verifyEqual(p.dit{1},-1);
            testCase.verifyEqual(p.id_coil{1},'mycoil');
            % --- 'ltime' --> no time shift, no coil
            testCase.verifyEqual(p.depend_on{2},'ltime');
            testCase.verifyEqual(p.dit{2},0);
            % --- single #from expanded to all dependencies
            testCase.verifySize(p.from,[1 2]);
        end
        %------------------------------------------------------------------
        function future_time_step_errors(testCase)
            testCase.verifyError(@()Parameter('parent_model',testCase.model01,...
                'f',@(x)(x),'depend_on','T(1)','from',testCase.model01),?MException);
        end
        %------------------------------------------------------------------
        function missing_from_errors(testCase)
            testCase.verifyError(@()Parameter('parent_model',testCase.model01,...
                'f',@(x)(x),'depend_on','T'),?MException);
        end
        %------------------------------------------------------------------
        function nargin_mismatch_errors(testCase)
            testCase.verifyError(@()Parameter('parent_model',testCase.model01,...
                'f',@(x,y)(x+y),'depend_on','T','from',testCase.model01),?MException);
        end
        %------------------------------------------------------------------
    end

    %----------------------------------------------------------------------
    % --- free parameters (no parent model)
    methods (Test)
        %------------------------------------------------------------------
        function free_parameter_chain(testCase)
            p_free = Parameter('f',2);
            p = Parameter('f',@(x)(3*x),'depend_on',p_free);
            testCase.verifyEqual(p.getvalue,6);
        end
        %------------------------------------------------------------------
        function freeparameter_as_source(testCase)
            fp = FreeParameter(5);
            p = Parameter('f',@(v)(v+1),'depend_on','value','from',fp);
            testCase.verifyEqual(p.getvalue,6);
        end
        %------------------------------------------------------------------
        function varargin_list_passed_to_f(testCase)
            p_free = Parameter('f',3);
            p = Parameter('f',@f__affine,'depend_on',p_free,...
                          'varargin_list',{'gain',2,'offset',1});
            % f__affine : gain.*x + offset = 2*3 + 1
            testCase.verifyEqual(p.getvalue,7);
        end
        %------------------------------------------------------------------
    end

    %----------------------------------------------------------------------
    % --- model-bound parameters
    methods (Test)
        %------------------------------------------------------------------
        function mesh_data_celem(testCase)
            m01 = testCase.model01;
            gid = testCase.vdom.dom.gindex;
            % ---
            p = Parameter('parent_model',m01,'f',@(c)(c),'depend_on','celem',...
                          'from',m01,'fvectorized',1);
            v = p.getvalue('in_dom',testCase.vdom);
            % ---
            testCase.verifyEqual(v,m01.parent_mesh.celem(:,gid));
        end
        %------------------------------------------------------------------
        function time_ltime(testCase)
            m01 = testCase.model01;
            m01.ltime.it = 3;
            % ---
            p = Parameter('parent_model',m01,'f',@(t)(2*t),'depend_on','ltime','from',m01);
            % ---
            testCase.verifyEqual(p.getvalue('in_dom',testCase.vdom),...
                                 2*m01.ltime.t_now,'AbsTol',1e-12);
        end
        %------------------------------------------------------------------
        function field_same_model_elem(testCase)
            m01 = testCase.model01;
            m01.ltime.it = 3;
            gid = testCase.vdom.dom.gindex;
            % ---
            expected = m01.field{3}.T.elem.cvalue(gid) + 1;
            % ---
            p = Parameter('parent_model',m01,'f',@(x)(x + 1),'depend_on','T','from',m01);
            v = p.getvalue('in_dom',testCase.vdom);
            % ---
            testCase.verifyEqual(v(:),expected(:),'AbsTol',1e-12);
        end
        %------------------------------------------------------------------
        function field_same_model_face_complex(testCase)
            % face support (SurfaceDom) + complex valued field E
            m01 = testCase.model01;
            m01.ltime.it = 3;
            gid = testCase.sdom.dom.gindex;
            % ---
            expected = m01.field{3}.E.face.cvalue(gid);
            % ---
            p = Parameter('parent_model',m01,'f',@(x)(x),'depend_on','E','from',m01);
            v = p.getvalue('in_dom',testCase.sdom);
            % ---
            testCase.verifyEqual(v(:),expected(:),'AbsTol',1e-12);
        end
        %------------------------------------------------------------------
        function field_same_mesh_same_ltime(testCase)
            % model02 is a copy of model01 : same values expected
            m01 = testCase.model01;
            m01.ltime.it = 3;
            gid = testCase.vdom.dom.gindex;
            % ---
            expected = m01.field{3}.T.elem.cvalue(gid) + 1;
            % ---
            p = Parameter('parent_model',m01,'f',@(x)(x + 1),'depend_on','T',...
                          'from',testCase.model02);
            v = p.getvalue('in_dom',testCase.vdom);
            % ---
            testCase.verifyEqual(v(:),expected(:),'AbsTol',1e-12);
        end
        %------------------------------------------------------------------
        function field_same_mesh_diff_ltime(testCase)
            m01 = testCase.model01;
            m03 = testCase.model03;
            gid = testCase.vdom.dom.gindex;
            % ---
            p = Parameter('parent_model',m01,'f',@(x)(x + 1),'depend_on','T','from',m03);
            % --- at t = t0 the two time discretizations coincide : direct read
            m01.ltime.it = 1;
            v = p.getvalue('in_dom',testCase.vdom);
            expected = m03.field{1}.T.elem.cvalue(gid) + 1;
            testCase.verifyEqual(v(:),expected(:),'AbsTol',1e-12);
            % --- in-between time step : time interpolation, coherent finite values
            m01.ltime.it = 3;
            v = p.getvalue('in_dom',testCase.vdom);
            testCase.verifyEqual(numel(v),numel(gid));
            testCase.verifyTrue(all(isfinite(v(:))));
        end
        %------------------------------------------------------------------
        function field_cross_mesh_elem(testCase)
            % time + space interpolation from a different mesh
            m01 = testCase.model01;
            m01.ltime.it = 3;
            gid = testCase.vdom.dom.gindex;
            % --- scalar T
            p = Parameter('parent_model',m01,'f',@(x)(x),'depend_on','T',...
                          'from',testCase.model04);
            v = p.getvalue('in_dom',testCase.vdom);
            testCase.verifyEqual(numel(v),numel(gid));
            testCase.verifyTrue(all(isfinite(v(:))));
            testCase.verifyTrue(any(v(:) ~= 0));
            % --- vector B
            p = Parameter('parent_model',m01,'f',@(x)(x),'depend_on','B',...
                          'from',testCase.model04);
            v = p.getvalue('in_dom',testCase.vdom);
            testCase.verifySize(v,[numel(gid) 3]);
            testCase.verifyTrue(all(isfinite(v(:))));
        end
        %------------------------------------------------------------------
        function serial_equals_vectorized(testCase)
            m01 = testCase.model01;
            m01.ltime.it = 3;
            % ---
            ps = Parameter('parent_model',m01,'f',@(x)(x + 1),'depend_on','T',...
                           'from',m01,'fvectorized',0);
            pv = Parameter('parent_model',m01,'f',@(x)(x + 1),'depend_on','T',...
                           'from',m01,'fvectorized',1);
            % ---
            vs = ps.getvalue('in_dom',testCase.vdom);
            vv = pv.getvalue('in_dom',testCase.vdom);
            % ---
            testCase.verifyEqual(vs(:),vv(:),'AbsTol',1e-12);
        end
        %------------------------------------------------------------------
        function coil_quantity_missing_coil_errors(testCase)
            m01 = testCase.model01;
            m01.ltime.it = 3;
            % --- thermal model has no coil : must error at evaluation
            p = Parameter('parent_model',m01,'f',@(v)(v),'depend_on','V.mycoil','from',m01);
            testCase.verifyError(@()p.getvalue('in_dom',testCase.vdom),?MException);
        end
        %------------------------------------------------------------------
    end

    %----------------------------------------------------------------------
    % --- subclasses
    methods (Test)
        %------------------------------------------------------------------
        function scalar_parameter(testCase)
            m01 = testCase.model01;
            m01.ltime.it = 3;
            gid = testCase.vdom.dom.gindex;
            % ---
            p = ScalarParameter('parent_model',m01,'f',@(T)(1./T),'depend_on','T','from',m01);
            v = p.getvalue('in_dom',testCase.vdom);
            vi = p.get_inverse('in_dom',testCase.vdom);
            % ---
            testCase.verifyEqual(numel(v),numel(gid));
            testCase.verifyEqual(v(:).*vi(:),ones(numel(gid),1),'AbsTol',1e-9);
            % --- constant must be a scalar
            testCase.verifyError(@()ScalarParameter('parent_model',m01,'f',[1 2 3]),?MException);
        end
        %------------------------------------------------------------------
        function vector_parameter(testCase)
            m01 = testCase.model01;
            m01.ltime.it = 3;
            gid = testCase.vdom.dom.gindex;
            % ---
            p = VectorParameter('parent_model',m01,'f',@(x)(x),'depend_on','B','from',m01);
            v = p.getvalue('in_dom',testCase.vdom);
            % ---
            testCase.verifyEqual(numel(v),3*numel(gid));
            testCase.verifyTrue(all(isfinite(v(:))));
            % --- constant must be a 2/3-vector
            testCase.verifyError(@()VectorParameter('parent_model',m01,'f',5),?MException);
        end
        %------------------------------------------------------------------
        function tensor_parameter_inverse(testCase)
            m01 = testCase.model01;
            m01.ltime.it = 3;
            % ---
            p = TensorParameter('parent_model',m01,'f',@(T)(diag([T 2*T 3*T])),...
                                'depend_on','T','from',m01);
            v = p.getvalue('in_dom',testCase.vdom);
            vi = p.get_inverse('in_dom',testCase.vdom);
            % --- tensor * inverse = identity, entity per entity
            for i = 1:size(v,1)
                prod_ = squeeze(v(i,:,:)) * squeeze(vi(i,:,:));
                testCase.verifyEqual(prod_,eye(3),'AbsTol',1e-9);
            end
            % --- constant must be a 2x2/3x3 tensor
            testCase.verifyError(@()TensorParameter('parent_model',m01,'f',[1 2 3]),?MException);
        end
        %------------------------------------------------------------------
    end
end

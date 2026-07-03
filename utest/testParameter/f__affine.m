function y = f__affine(x,args)
% test helper for TestParameter : affine function with name-value options
% passed through #varargin_list (same mechanism as tutorial f__customized)

arguments
    x
    args.gain   = 1
    args.offset = 0
end

y = args.gain .* x + args.offset;

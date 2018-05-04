function Options = gl_parse_args(Options, argCell)
optionNames = fieldnames(Options);
nArgs = length(argCell);
if mod(nArgs,2) %If the number of arguments is not even
    st = dbstack();
    error([upper(st(2).name),' needs propertyName/propertyValue pairs'])
end

for pairIdx = reshape(argCell,2,[]) % pair is {propName;propValue}
    inpName = lower(pairIdx{1}); % make case insensitive
    
    if any(strcmp(inpName,lower(optionNames)))
        % overwrite options. If you want you can test for the right class here
        % Also, if you find out that there is an option you keep getting wrong,
        % you can use "if strcmp(inpName,'problemOption'),testMore,end"-statements
        argName = optionNames(strcmp(inpName, lower(optionNames)));
        Options.(argName{1}) = pairIdx{2};
    else
        st = dbstack();
        error('%s is not a recognized parameter name of ''%s''',pairIdx{1}, upper(st(2).name))
    end
end
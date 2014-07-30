function options = gl_parse_args(options, argCell)
optionNames = fieldnames(options);
nArgs = length(argCell);
st = dbstack();
if mod(nArgs,2) %If the number of arguments is not even
    error([upper(st(2).name),' needs propertyName/propertyValue pairs'])
end

for pairIdx = reshape(argCell,2,[]) % pair is {propName;propValue}
    inpName = lower(pairIdx{1}); % make case insensitive
    
    if any(strcmp(inpName,lower(optionNames)))
        % overwrite options. If you want you can test for the right class here
        % Also, if you find out that there is an option you keep getting wrong,
        % you can use "if strcmp(inpName,'problemOption'),testMore,end"-statements
        argName = optionNames(strcmp(inpName, lower(optionNames)));
        options.(argName{1}) = pairIdx{2};
    else
        error('%s is not a recognized parameter name of ''%s''',pairIdx{1}, upper(st(2).name))
    end
end
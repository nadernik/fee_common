function Status = sutterCloseConnection(s)
try
    fclose(s);
    Status = 1;
catch
    Status = 0;
end
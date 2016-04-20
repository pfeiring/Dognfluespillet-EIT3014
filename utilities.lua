
local utilities = {};

------------------------------------------------------------------

function utilities:value_or_default(value, default)
    
    if (value) then
        return value;
    end

    return default;
end

------------------------------------------------------------------

function utilities:conditioned_value_or_default(condition, value, default)
    
    if (condition) then
        return value;
    end

    return default;
end

return utilities;
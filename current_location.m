%{
Return the grass quantity and nutritional content of an x-y location
%}

function [grass_quantity, nutrition] = current_location(landscape, x, y)

grass_quantity = landscape(y, x, 1);
nutrition = landscape(y, x, 2);

end
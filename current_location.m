%{
Return the grass quantity and nutritional content of an x-y location
%}

function [grass_quantity, nutrition] = current_location(landscape, x, y)

x_round = round(x);
y_round = round(y);
grass_quantity = landscape(y_round, x_round, 1);
nutrition = landscape(y_round, x_round, 2);

end
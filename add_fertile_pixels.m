function landscape = add_fertile_pixels(landscape, n_pixels_extra, boundary, max_grass)

xdim = size(landscape, 2);
ydim = size(landscape, 1);
inside_boundary = landscape((boundary + 1):(ydim - boundary),...
    (boundary + 1):(xdim - boundary), 2);
%All of these variables are lists of indexes
not_fertile = find(inside_boundary ~= 1); %linear index of nonfertile squares within boundary
x_bounds = size(inside_boundary, 2);
y_bounds = size(inside_boundary, 1);
choose = randperm(size(not_fertile, 1), n_pixels_extra); %random indexes of values within not_fertile
change = not_fertile(choose); %values randomly selected from not_fertile
[not_fertile_y, not_fertile_x] = ind2sub([y_bounds, x_bounds], change);
not_fertile_x = not_fertile_x + boundary; %indices were taken from inside_boundary so need to be adjusted for landscape
not_fertile_y = not_fertile_y + boundary;

for pixel = 1:n_pixels_extra
    landscape(not_fertile_y(pixel), not_fertile_x(pixel), 1) = max_grass;
    landscape(not_fertile_y(pixel), not_fertile_x(pixel), 2) = 1;
end

end


%{
Initialize landscape for Doak-Peleg rotation project with
Liam Friar, Jack Gugel, Ellen Waddle, and Tristan Caro.

Landscape is a square grid. Agents can move at a finer scale.
Each point on grid stores visitation/dung count, current grass quantity,
nutritional quality.
Location of termite mounds or fertilization patches will be an initial
input, and initial attributes of grid points will be determined from those
inputs.

Note: x dimension refers to column, and y dimension to row. X dimension
increases left to right, Y dimension top to bottom.
%}

function landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy, max_grass, food_ratio, mound_radius)
%fertilizer_xy is a nx2 array of x-y points

validateattributes(xdim,{'numeric'},{'integer', 'positive'});
validateattributes(ydim,{'numeric'},{'integer', 'positive'});
validateattributes(fertilizer_xy, {'numeric'}, {'integer', 'positive',...
    'ncols', 2});
disp('All inputs to initialize_landscape_1 are ok.');

num_mounds = size(fertilizer_xy,1);
for xy = 1:num_mounds
    if fertilizer_xy(xy, 1) > xdim || fertilizer_xy(xy, 2) > ydim
        error('fertilizer coordinates exceed landscape bounds');
    end
end

%day = 0;
%initialize date!
init_food_off = max_grass / food_ratio;
init_nutrition_off = round(1 / food_ratio, 2);
landscape = zeros(ydim, xdim, 3);
%Z dimension will be 1-grass count 2-nutritional quality 3-poop count


%Calculate distances from closest mound
max_dist = round(sqrt(xdim^2 + ydim^2));
for xx = 1:xdim
    for yy = 1:ydim
        landscape(yy, xx, 1) = max_dist;
        landscape(yy, xx, 2) = max_dist;
        for mound = 1:num_mounds
            x_dist = xx - fertilizer_xy(mound, 1);
            y_dist = yy - fertilizer_xy(mound, 2);
            dist_to_mound = round(sqrt(x_dist^2 + y_dist^2));
            if dist_to_mound < landscape(yy, xx, 1)
                landscape(yy, xx, 1) = dist_to_mound;
                landscape(yy, xx, 2) = dist_to_mound; 
            end
        end
        if landscape(yy, xx, 1) < mound_radius
            %On mound
           landscape(yy, xx, 1) = max_grass;
           landscape(yy, xx, 2) = 1;
        else
            landscape(yy, xx, 1) = init_food_off;
            landscape(yy, xx, 2) = init_nutrition_off; 
        end
    end
end


end
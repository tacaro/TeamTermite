function [fertilizer_xy] = random_fertilizer(fertilizer_xy, n_mounds2add, xdim, ydim, boundary, mound_radius)
%Called by termite_model. Creates an array of xy points that do not
%overlap if they are the center of circles of radius mound_radius.
%Input an existing array so that additional random points can be added to
%an existing array.
n_mounds = size(fertilizer_xy);

for build_mound = n_mounds + 1 : n_mounds + n_mounds2add
   overlaps = true;
   while overlaps %Will keep generating random xy points until one does not overlap.
        overlaps = false;
        fert_x = randi([(1+boundary + floor(mound_radius)), (xdim - boundary - floor(mound_radius))]);
        fert_y = randi([(1+boundary + floor(mound_radius)), (ydim - boundary - floor(mound_radius))]);
        for compare_mound = 1 : build_mound-1 %Check for overlap
            x_dist = fert_x - fertilizer_xy(compare_mound, 1);
            y_dist = fert_y - fertilizer_xy(compare_mound, 2);
            dist_between = round(sqrt(x_dist^2 + y_dist^2), 2);
            if dist_between < 2 * mound_radius
                overlaps = true;
                break
            end    
        end
        fertilizer_xy(build_mound, 1:2) = [fert_x, fert_y]; %Will get overwritten if overlaps.
    end
end


end


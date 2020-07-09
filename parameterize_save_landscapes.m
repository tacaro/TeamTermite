%Using initialize_landscape_1 this script creates and saves landscapes for 
%use by termite_model


clearvars
close all

fertilizer_pattern = "random"; % random, hexagon, or square? (string)
mound_radius = 12.5; %Was 3.5 for rotation. Can be [0.5, 1, 13.5] or else mound_area_Map will not know mound_area
keep_constant = "mounds"; %number of "pixels" or "mounds" or the "fraction_fertile"
%to be kept constant if mound_radius or xdim or ydim change
xdim = 230;
ydim = 230;
boundary = 15; % fertile pixels will not initialize within this many pixels of the edge of the landscape.
              %animals CAN move in the boundary.
n_mounds = 16; % number of termite mounds
%if change n_mounds, change n_pixels below!!!
max_grass = 100; %starting grass/nutrition level for fertilizer patches
food_ratio = 5; %ratio of initial grass quantity and nutrition on fertilizered patches vs off
                            
              
mound_area_Map = containers.Map({0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5,...
    8.5, 9.5, 10.5, 11.5, 12.5, 13.5},...
    {1, 9, 21, 37, 69, 97, 137, 177, 225, 293, 349, 421, 489, 577});
%mound_area_Map is hardcoded from looking at landscapes
mound_area = values(mound_area_Map, {mound_radius});
mound_area = mound_area{1};        


    %Allow for different sized patches.
if keep_constant == "pixels"
    n_pixels = 7824; %Hardcoded from 16 mounds * 489 pixels/mound. (radius 12.5)
                    %Can find other mound areas in mound_area_Map container
    n_mounds = floor(n_pixels/mound_area);
    n_pixels_extra = n_pixels - (n_mounds * mound_area);
elseif keep_constant == "mounds"
    n_pixels = n_mounds * mound_area;
    n_pixels_extra = 0;
elseif keep_constant == "fraction_fertile"
    n_pixels = round(7824 * xdim * ydim / 200^2); %hardcoded from 16 mounds, radius 12.5, 200x200 landscape
    n_mounds = floor(n_pixels/mound_area);
    n_pixels_extra = n_pixels - (n_mounds * mound_area);
else
    error("Error: keep_constant variable assigned to unrecognized value")
end

%Create a meshgrid to make 2-letter identifiers for unique landscapes
alphabet = 'A':'Z';
[first_letter, second_letter] = meshgrid(alphabet, alphabet); 

%for scape_num = 1:45

    % Set up fertilizer mound locations, initialize landscape
    if fertilizer_pattern == "hexagon"
        [fertilizer_xy, n_mounds_extra] = hexGrid(xdim, ydim, boundary, mound_radius, n_mounds);   

    elseif fertilizer_pattern == "square"
        n_mounds_side = floor(sqrt(n_mounds));
        n_mounds_extra = n_mounds - n_mounds_side^2; 
        fert_x = linspace((boundary + 1 + floor(mound_radius)), (xdim - boundary - floor(mound_radius)), n_mounds_side);
        fert_y = linspace((boundary + 1 + floor(mound_radius)), (ydim - boundary - floor(mound_radius)), n_mounds_side);
        [X,Y] = meshgrid(fert_x, fert_y);
        fertilizer_xy = round([X(:), Y(:)]);

    elseif fertilizer_pattern == "random"
        fertilizer_xy = [];
        fertilizer_xy = random_fertilizer(fertilizer_xy, n_mounds, xdim, ydim, boundary, mound_radius);
        n_mounds_extra = 0;

    else
        disp("Exception: Fertilizer pattern not recognized. The options are 'random', 'hexagon', and 'square'")
        clearvars
        return
    end  

    %manual input of experimental values
    fertilizer_xy = 2 * [1	2	12	23	42	46	57	71	89	25	43	57	77	90	102	105; ...
19	37	1	45	4	37	35	36	32	64	56	94	81	75	74	99]' + boundary;
    %The following 2 if statements maintain a constant number of fertile pixels
    %on the initial landscape when the pattern and mound_radius do not
    %automatically create such a landscape.
    if n_mounds_extra ~= 0  %The circles do not contain a perfect square number of gridspaces, so randomly assign remainder.
        disp("Extra mounds did not fit in pattern and are randomly distributed.");
        fertilizer_xy = random_fertilizer(fertilizer_xy, n_mounds_extra, xdim, ydim, boundary, mound_radius);
    end
    landscape = initialize_landscape_1(xdim, ydim, fertilizer_xy, max_grass, food_ratio, mound_radius);
    if n_pixels_extra ~= 0
        disp("Extra pixels not divided evenly into mounds are randomly distributed.");
        landscape = add_fertile_pixels(landscape, n_pixels_extra, boundary, max_grass);
    end
    if sum(sum(landscape(:,:,2) == 1)) ~= n_pixels
       % error("Error: Landscape intialized with incorrect number of fertile spaces");
    end
 
    

    %% Data Export

    %Adjust working directory for local computer.
    wd = 'Rotations and Reading/Doak Rotation/TeamTermite/'; 

    %Create unique ID for unique landscapes.
    
    now = num2str(fix(clock));
    now = now(~isspace(now));
    now(1:4) = [];
    %runID = strcat(first_letter(scape_num), second_letter(scape_num));
    %landscape_ID = strcat(runID, '_', now);
    
    landscape_ID = strcat('plot7_', now);
    

    %This is all the parameters.
    fertilizer_pattern;
    radiusSTR = num2str(mound_radius);
    keep_constant;
    xdimSTR = num2str(xdim);
    ydimSTR = num2str(ydim);
    boundarySTR = num2str(boundary);
    n_moundsSTR = num2str(n_mounds);
    max_grassSTR = num2str(max_grass);
    food_ratioSTR = num2str(food_ratio);

    parameter_str = strcat(fertilizer_pattern, "_mounds", n_moundsSTR, "_rad", radiusSTR, "_dim", xdimSTR, ...
        ydimSTR);

    parameter_folder_name = strcat(wd, 'landscapes/', parameter_str, "/");
    landscape_path = strcat(parameter_folder_name, 'landscapes/');
    fertilizer_path = strcat(parameter_folder_name, 'fertilizer_xy/');
    if ~exist(parameter_folder_name, 'dir')
        mkdir(parameter_folder_name);
        mkdir(landscape_path);
        mkdir(fertilizer_path);

        MTDA = {'fertilizer_pattern', fertilizer_pattern;
                'mound_radius', mound_radius;
                'xdim', xdim;
                'ydim', ydim;
                'food_ratio', food_ratio;
                'boundary', boundary;
                'max_grass', max_grass;
                'n_mounds', n_mounds;
                };
      MTDA = cell2table(MTDA, 'VariableNames', {'Parameter', 'Value'});
      writetable(MTDA, strcat(parameter_folder_name, 'metadata.csv'));

    end

    if exist(strcat(landscape_path, landscape_ID, '_grass.csv'), 'file')
        error('A landscape already exists with this ID');
    else
        writematrix(landscape(:,:,1), strcat(landscape_path, landscape_ID, '_grass.csv'));
        %writematrix(landscape(:,:,2), strcat(landscape_path, landscape_ID, '_nutrition.csv'));
        %writematrix(landscape(:,:,3), strcat(landscape_path, landscape_ID, '_dung.csv'));

        writematrix(fertilizer_xy, strcat(fertilizer_path, landscape_ID, '_fertilizer_xy.csv'));
    end
%end
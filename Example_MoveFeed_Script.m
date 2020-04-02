%{
Example script using initializa_landscape_1, current_location,
move_and_feed_1, move_1

%}

%initialize landscape
fertilizer_xy =[2,5; 10,8; 1,7]; 
landscape = initialize_landscape_1(10, 10, fertilizer_xy);
disp("initial grass landscape: ");
disp(landscape(:,:,1));
disp("Is there poop yet???");
disp(landscape(:,:,3));


%At the start of a time step, an agent calls current_location on its
%current location to check if it wants to move.
x1 = 5;
y1 = 5;
[grass_quantity, nutrition] = current_location(landscape, x1, y1);
disp("grass_quantity = ");
disp(grass_quantity);

%Agent decides to move to new location. Updates landscape, feeds, and asks
%if it has exited the boundary region using move_and_feed_1 which calls
%move_1.

x2 = 4;
y2 = 7;
boundary = 2;
feed_amount = 5;
feed_time = 1;

[landscape, grass_consumed, nutrition, leave] = move_and_feed_1(landscape,...
    x1, y1, x2, y2, boundary, feed_amount, feed_time);

disp("LEAVE??? ");
disp(leave);
disp("how much did I eat???");
disp(grass_consumed);
disp("Updated grass landscape: ");
disp(landscape(:,:,1));
disp("Is there poop now???");
disp(landscape(:,:,3));





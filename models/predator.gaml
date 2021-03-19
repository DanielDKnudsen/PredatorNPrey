model predator

import "generic.gaml"
import "prey.gaml"

species predator parent: generic_species {
    rgb color <- #red;
    float max_energy <- predator_max_energy;
    float energy_transfert <- predator_energy_transfert;
    float energy_consum <- predator_energy_consum;
    float proba_reproduce <- predator_proba_reproduce;
    int nb_max_offsprings <- predator_nb_max_offsprings;
    float energy_reproduce <- predator_energy_reproduce;
    image_file my_icon <- image_file("../includes/data/wolff.png");
    float scaling_factor <- 100/grid_size;

    float energy_from_eat {
        list<prey> reachable_preys <- prey inside (my_cell);
        if(! empty(reachable_preys)) {
            ask one_of (reachable_preys) {
                do die;
            }
            return energy_transfert;
        }
        return 0.0;
    }
	

	
    vegetation_cell choose_cell {
        vegetation_cell visible_prey_cell <- shuffle(my_cell.neighbors2) first_with (!(empty(prey inside (each))));
        vegetation_cell scent_of_prey_cell <- shuffle(my_cell.neighbors6) first_with (!(empty(prey inside (each))));
        // If prey is visible, then sprint those two cells to the prey:
        
        if visible_prey_cell != nil {
			energy <- energy - calculate_number_of_cells_moved(my_cell.grid_x, visible_prey_cell.grid_x, my_cell.grid_y, visible_prey_cell.grid_y) * 0.25;
            return visible_prey_cell;
        } 
        // Alternatively, if prey is scented, then move in that direction:
        else if (scent_of_prey_cell != nil) {
	        prey preyInsideCell <- (prey inside scent_of_prey_cell)[0];
	        float direction <- self towards preyInsideCell;
	        float scaled_x <- scaling_factor * my_cell.grid_x + scaling_factor * 0.5;
	        float scaled_y <- scaling_factor * my_cell.grid_y + scaling_factor * 0.5;
	        
	        my_cell.location <- new_location_based_on_scent(direction, scaled_x, scaled_y);
	        energy <- energy - 0.2;	        	
        	return my_cell;
    	} 
    	// Take a normal random step
    	else {
        	energy <- energy - 0.2;
            return one_of(my_cell.neighbors1);
    	}           
    }
    
    // Calculates the number of cells that the predator has moved. The assumption is that it always moves by picking
    // the shortest path.
    // Example 1:
    //	1:	|_|_|_|_|_|_|_|
    //		|_|_|_|_|_|_|_|
    //		|_|_|_|_|_|_|_|
    //		|_|x|_|_|_|_|_|
    //		|_|_|_|_|_|_|_|
    //
    //	2:	|_|_|_|_|x|_|_|
    //		|_|_|_|2|_|_|_|
    //		|_|_|1|_|_|_|_|
    //		|_|_|_|_|_|_|_|
    //		|_|_|_|_|_|_|_|
    // 	In this case the predator moved 3 steps diagonally. 
    // Example 2:
    //	1:	|_|_|_|_|_|_|_|
    //		|_|_|_|_|_|_|_|
    //		|_|_|_|_|_|_|_|
    //		|_|x|_|_|_|_|_|
    //		|_|_|_|_|_|_|_|
    //
    //	2:	|_|_|x|_|_|_|_|
    //		|_|_|2|_|_|_|_|
    //		|_|_|1|_|_|_|_|
    //		|_|_|_|_|_|_|_|
    //		|_|_|_|_|_|_|_|
    // 	In this case the predator moved 1 step diagonally and 2 steps upwards. 
    // 
    // Based on this assumption, we can assume that the number of steps moved is equal to the largest change in the absolute 
    // value on either the x- or y-axis. 
    int calculate_number_of_cells_moved(int x_old, int x_new, int y_old, int y_new)
	{
    	int change_y <- abs(y_old-y_new);
    	int change_x <- abs(x_old-x_new);
    	return max([change_y, change_x]);
	}
	
	//Chooses a cell in the direction of the detected prey
	point new_location_based_on_scent(float direction, float scaled_x, float scaled_y) 
	{
		if(direction <= 45 or direction > 315)
        {
        // RIGHT
        return {scaled_x + scaling_factor, scaled_y, 0.0};        	
       	}
        else if(direction > 45 and direction <= 135)
        {
        // DOWN
        return {scaled_x, scaled_y + scaling_factor, 0.0};	        		
        }
    	else if(direction > 135 and direction <= 225)
    	{
    	// LEFT	
    	return {scaled_x - scaling_factor, scaled_y, 0.0};
    	}
    	else {
    	// UP
    	return {scaled_x, scaled_y - scaling_factor, 0.0};
    	}
	}   
}


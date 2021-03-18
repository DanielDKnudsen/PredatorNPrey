

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
        vegetation_cell my_cell_tmp <- shuffle(my_cell.neighbors2) first_with (!(empty(prey inside (each))));
        if my_cell_tmp != nil {
        	
        	int y_before <- my_cell_tmp.grid_y;
	    	int x_before <- my_cell_tmp.grid_x;
	    	int change_y <- abs(my_cell.grid_y-y_before);
	    	int change_x <- abs(my_cell.grid_x-x_before);
	    	int biggest_change <- max([change_y, change_x]);
			energy <- energy - biggest_change * 0.25;
        	
            return my_cell_tmp;
        } else {
        	vegetation_cell my_cell_tmp2 <- shuffle(my_cell.neighbors6) first_with (!(empty(prey inside (each))));
        	if(my_cell_tmp2 != nil)
        	{
	        	prey preyInsideCell <- (prey inside my_cell_tmp2)[0];
	        	float direction <- self towards preyInsideCell;
	        	float scaling_factor <- 100/grid_size;
	        	float scaled_x <- scaling_factor * my_cell.grid_x + scaling_factor * 0.5;
	        	float scaled_y <- scaling_factor * my_cell.grid_y + scaling_factor * 0.5;
	        	
	        	if(direction <= 45 or direction > 315)
	        	{
	        	// RIGHT
	        	my_cell.location <- {scaled_x + scaling_factor, scaled_y, 0.0};
	        	
	        	}
	        	else if(direction > 45 and direction <= 135)
	        	{
	        	// DOWN
	        	my_cell.location <- {scaled_x, scaled_y + scaling_factor, 0.0};
	        		
	        	}
	        	else if(direction > 135 and direction <= 225)
	        	{
	        	// LEFT	
	        	my_cell.location <- {scaled_x - scaling_factor, scaled_y, 0.0};
	        	}
	        	else {
	        	// UP
	        	my_cell.location <- {scaled_x, scaled_y - scaling_factor, 0.0};
	        	
	        	}
	        	return my_cell;
        	}
        	else {
	        	energy <- energy - 0.2;
	            return one_of(my_cell.neighbors1);
        	}   

        	

        }
    }
}
/* Insert your model definition here */


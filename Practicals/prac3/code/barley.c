/**************************************************
 *                                                *
 * First attempt at a code to calcule lost barley *
 * by A. Farmer                                   *
 * 18/05/18                                       *
 *                                                *
 **************************************************/

// Include any headers from the C standard library here
#include <stdio.h>
#include <math.h>

// Define any constants that I need to use here
#define PI 3.14

// This is where I should put my function prototypes
int query_object_count(char *type);
float area_of_circle(float radius); 
float percentage_loss(float area, float loss_area);

// Now I start my code with main()
int main() {

    // In here I need to delare my variables
    int i;
    int count;
    float current_radius;
    float current_ring_radius[2];
    float dims[2];
    float total_area;
    float field_size;
    float loss_in_kg;
    float monetary_loss;

    // Next I need to get input from the user.
    // I'll do this by using a printf() to ask the user to input the radii.
    total_area = 0;
    count = query_object_count("Circle");

    for (i = 0; i < count; i++)
    {
	printf("Input the radius of the circle (%d/%d):\n", i + 1, count);
	scanf("%f", &current_radius);
	total_area += area_of_circle(current_radius);
    };
    
    // Now do ring calculations
    count = query_object_count("Ring");
    for (i = 0; i < count; i++)
    {
	printf(
	    "Input the outer and inner radii of the ring (%d/%d)\n",
	    i+1, count
	);
	scanf("%f %f", &current_ring_radius[0], &current_ring_radius[1]);
	total_area += fabsf(
	    area_of_circle(current_ring_radius[0])
	    - area_of_circle(current_ring_radius[1])
	);
    };


    // Now I need to loop through the radii caluclating the area for each
    printf("Input the dimensions of the field:\n");
    scanf("%f %f", &dims[0], &dims[1]);
    // Next I'll sum up all of the individual areas
    
    /******************************************************************
     *                                                                *
     * Now I know the total area I can use the following information: *
     *                                                                *
     * One square meter of crop produces about 135 grams of barley    *
     *                                                                *
     * One kg of barley sells for about 10 pence                      *
     *                                                                *
     ******************************************************************/

    // Using the above I'll work out how much barley has been lost.
    loss_in_kg = total_area*0.135;
    field_size = dims[0] * dims[1];
    monetary_loss = 0.10 * loss_in_kg;

    // Finally I'll use a printf() to print this to the screen.
    printf("\nTotal area lossed in m^2 is:\t%f\n", total_area);
    printf("Total loss in kg is:\t\t%f\n", loss_in_kg);
    printf("Percentage loss is: %f\n", percentage_loss(field_size, total_area));
    printf("Monetary loss is: £%f\n", monetary_loss);
    return(0);
};

// I'll put my functions here:

int query_object_count(char *type)
{
    int count = 0;
    printf("Number of %s objects:\n", type);
    scanf("%d", &count);
    return count >= 0 ? count : 0;
}

float area_of_circle(float radius)
{
    return PI * radius * radius;
};

float percentage_loss(float area, float area_loss)
{
    return  area_loss / (area - area_loss) * 100;
};

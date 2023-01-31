#include <malloc.h>
#include "proj_high_level.h"

// run code:
// gcc proj_high_level.c -o proj; ./proj
// gcc proj_high_level_v1.c -o proj_v1; ./proj_v1
// valgrind ./proj

// gcc proj_high_level.c -o proj; gcc proj_high_level_v1.c -o proj_v1; ./proj > out1; ./proj_v1 > out2; diff out1 out2

// select configuration in header file

int ReLU(int x) {
	if (x < 0)
		return 0;
	if (x > 127)
		return 127;
	return x;
}

int max_val(int x, int y) {
	if (x > y)
		return x;
	return y;
}

void print_matrix(int size, int matrix[size][size]) {
	int i, j;

	for (i=0; i<size*4; i++) printf("-");
	printf("\n");

	for (i=0; i<size; i++) {
		for (j=0; j<size; j++) {
			printf("%3d ", matrix[i][j]);
		}
		printf("\n");
	}

	for (i=0; i<size*4; i++) printf("-");
	printf("\n");
}

int main(void) {

	int input[N][N] = in_MAT;
	int kernel[3][3] = KERNEL;
	int feature_map[2][2] = {{0}};
	int max[] = {0};
	int pool[Np][Np] = {{0}};
	int weight[Np][Np] = WEIGHT;
	int result[Np][Np] = {{0}};

    int i, j, k, v, h, p_i, p_j;

	printf("\nCONFIGURATIONS\n");
	printf("==============\n");

	printf("\nInput\n");
	print_matrix(N, input);

	printf("\nKernel\n");
	print_matrix(3, kernel);

	printf("\nWeight:\n");
	print_matrix(Np, weight);

	printf("\n\nCALCULATIONS\n");
	printf("============\n");


	// Convolution + Pooling + ReLU

	for (v=0; v<Nf; v += 2) {
		for (h=0; h<Nf; h += 2) {
			for (p_i=0; p_i<2; p_i++) {
				for (p_j=0; p_j<2; p_j++) {
					for (i=0; i<3; i++) {
						for (j=0; j<3; j++) {
							feature_map[p_i][p_j] += input[v+p_i+i][h+p_j+j] * kernel[i][j];
						}
					}
				}
				max[p_i] = max_val(feature_map[p_i][0], feature_map[p_i][1]);
				feature_map[p_i][0] = 0;
				feature_map[p_i][1] = 0;
			}
			int pool_val = ReLU(max_val(max[0], max[1]));
			for (i=0; i<Np; i++) {
				result[i][h>>1] += weight[i][v>>1] * pool_val;
				if (v == Nf-2) {
					result[i][h>>1] = ReLU(result[i][h>>1]);
				}
			}
		}
	}

	printf("\nResult:\n");
	print_matrix(Np, result);

	return 0;
}


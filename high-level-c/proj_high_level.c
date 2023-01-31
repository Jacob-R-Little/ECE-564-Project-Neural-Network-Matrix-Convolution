#include <malloc.h>
#include "proj_high_level.h"

// run code:
// gcc proj_high_level.c -o proj; ./proj
// valgrind ./proj

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
	int feature_map[Nf][Nf] = {{0}};
	int pool[Np][Np] = {{0}};
	int weight[Np][Np] = WEIGHT;
	int result[Np][Np] = {{0}};

    int i, j, k, v, h;

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


	// Convolution
	for (v=0; v<Nf; v++) {
		for (h=0; h<Nf; h++) {
			for (i=0; i<3; i++) {
				for (j=0; j<3; j++) {
					feature_map[v][h] += input[v+i][h+j] * kernel[i][j];
				}
			}
			feature_map[v][h] = ReLU(feature_map[v][h]);
		}
	}

	printf("\nFeature Map + ReLu:\n");
    print_matrix(Nf, feature_map);

	// Pooling
	for (i=0; i<Nf; i += 2) {
		for (j=0; j<Nf; j += 2) {
			int max_1 = max_val(feature_map[i][j], feature_map[i][j+1]);
			int max_2 = max_val(feature_map[i+1][j], feature_map[i+1][j+1]);
			pool[i>>1][j>>1] = max_val(max_1, max_2);
		}
	}

	printf("\nPool:\n");
	print_matrix(Np, pool);

	// Full Connected Layers
	for (i=0; i<Np; i++) {
		for (j=0; j<Np; j++) {
			for (k=0; k<Np; k++) {
				result[i][j] += weight[i][k] * pool[k][j];
			}
			result[i][j] = ReLU(result[i][j]);
		}
	}
	printf("\nResult:\n");
	print_matrix(Np, result);

	return 0;
}


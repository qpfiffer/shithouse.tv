// vim: noet ts=4 sw=4
#include <stdio.h>

/* Spits out CSS for text!
 * Usage: ./micro-anim <CSS class name>
 *
 * Compile with:
 *     gcc -o micro-anim micro-anim.c
 */
const static char *colors[] = {"#ff0000", "#ff8000", "#ffff00", "#80ff00", "#00ff00",
							   "#00ff80", "#00ffff", "#0080ff", "#0000ff", "#8000ff",
							   "#ff0080"};
const static char *browser_keyframes[] = {"@-webkit-keyframes", "@-ms-keyframes",
										  "@-o-keyframes", "@keyframes"};

int main(int argc, char *argv[]) {
	if (argc < 2) {
		printf("Usage: ./micro-anim <CSS class name>\n");
		return 1;
	}

	const char *class_name = argv[1];
	const int num_keyframes = sizeof(browser_keyframes)/sizeof(browser_keyframes[0]);
	int i;
	for (i = 0; i < num_keyframes; i++) {
		printf("%s %s {\n", browser_keyframes[i], class_name);
		int j;
		const int num_colors = sizeof(colors)/sizeof(colors[0]);
		int pct = 0;
		int shadow_px = 2;
		for (j = 0; j < num_colors; j++) {
			printf("    %i%% {", pct);
			printf("color: %s; ", colors[j]);
			printf("text-shadow:");

			int k;
			for (k = 0; k < (shadow_px / 2); k++) {
				if (k != 0)
					printf(",");
				printf(" 0 %ipx 0 %s", k * 2, colors[k]);
			}

			printf(";");
			printf("}\n");
			pct += 10;
			shadow_px += 2;
		}
		printf("}\n");
	}

	return 0;
}

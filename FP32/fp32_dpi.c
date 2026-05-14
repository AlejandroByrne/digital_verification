#include <stdio.h>
#include <stdlib.h>
#include <svdpi.h>

// DPI export to call the python script via shell (simple integration)
// For a production environment, one would use the Python C API.
// This executes the golden_model.py and parses the output.

void call_python_model(
    unsigned int a, 
    unsigned int b, 
    unsigned int rnd, 
    unsigned int *result, 
    unsigned int *flags
) {
    char command[512];
    char buffer[128];
    FILE *fp;

    // Command: python3 golden_model.py --mult 0x<a> 0x<b> <rnd>
    // We assume the script prints: RESULT:0x... FLAGS:0x...
    // Let's modify the script slightly to provide this parseable output.
    
    // Use GOLDEN_MODEL env var if set, otherwise try both common locations
    const char *model = getenv("GOLDEN_MODEL");
    if (model == NULL || model[0] == '\0') model = "golden_model.py";
    sprintf(command, "python3 %s --mult 0x%08x 0x%08x %u --quiet", model, a, b, rnd);
    
    fp = popen(command, "r");
    if (fp == NULL) {
        fprintf(stderr, "DPI ERROR: Failed to run python model\n");
        return;
    }

    if (fgets(buffer, sizeof(buffer), fp) != NULL) {
        // Expected format: "0x<RESULT> 0x<FLAGS>"
        sscanf(buffer, "%x %x", result, flags);
    }

    pclose(fp);
}

/*
 * SPDX-FileCopyrightText: 2026 Mike.Sierra.Nevada
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
/* Print kernel read/write sector counters for explicitly named block devices. */

#include <ctype.h>
#include <stdio.h>
#include <string.h>

static int valid_name(const char *name)
{
    if (!name || !*name) {
        return 0;
    }
    for (const unsigned char *cursor = (const unsigned char *)name; *cursor; ++cursor) {
        if (!isalnum(*cursor) && *cursor != '_' && *cursor != '-') {
            return 0;
        }
    }
    return 1;
}

int main(int argc, char **argv)
{
    for (int argument = 1; argument < argc; ++argument) {
        const char *name = argv[argument];
        char path[256];
        unsigned long long field[11] = {0};

        if (!valid_name(name)) {
            continue;
        }
        if (snprintf(path, sizeof(path), "/sys/class/block/%s/stat", name) >= (int)sizeof(path)) {
            continue;
        }

        FILE *stream = fopen(path, "r");
        if (!stream) {
            continue;
        }
        int fields = fscanf(stream,
                            "%llu %llu %llu %llu %llu %llu %llu %llu %llu %llu %llu",
                            &field[0], &field[1], &field[2], &field[3], &field[4], &field[5],
                            &field[6], &field[7], &field[8], &field[9], &field[10]);
        fclose(stream);

        if (fields >= 7) {
            printf("%s %llu %llu\n", name, field[2], field[6]);
        }
    }
    return 0;
}

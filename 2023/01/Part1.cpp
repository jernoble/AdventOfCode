//
//  Part1.cpp
//  01
//
//  Created by Jer on 12/18/23.
//

#include <stdio.h>
#include <string>
#include <optional>

using namespace std;

int main(int argc, char *argv[])
{
    int total = 0;
    optional<int> first;
    optional<int> last;

    auto* fp = fopen(argv[1], "r");
    for (auto c = fgetc(fp); c != EOF; c = fgetc(fp)) {
        if (c == '\n') {
            if (first && last)
                total += *first * 10 + *last;
            first = last = nullopt;
            continue;
        }
        if (c < '0' || c > '9')
            continue;
        if (!first)
            first = c - '0';
        last = c - '0';
    }
    printf("Total: %d\n", total);
    return 0;
}

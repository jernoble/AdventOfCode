//
//  Part2.cpp
//  01
//
//  Created by Jer on 12/18/23.
//

#include <stdio.h>
#include <string>
#include <optional>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
    int total = 0;
    optional<int> first;
    optional<int> last;
    string firstString;
    string lastString;

    static const vector<string> numbers = {
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
    };

    auto* fp = fopen(argv[1], "r");
    for (auto c = fgetc(fp); c != EOF; c = fgetc(fp)) {
        if (c == '\n') {
            if (first && last)
                total += *first * 10 + *last;
            first = last = nullopt;
            firstString = "";
            lastString = "";
            continue;
        }

        firstString += (char)c;
        lastString += (char)c;

        for (int i = 0; i < numbers.size(); ++i) {
            if (firstString.ends_with(numbers[i])
                || lastString.ends_with(numbers[i])) {
                c = '1' + i;
                break;
            }
        }


        if (c >= '0' && c <= '9') {
            if (!first)
                first = c - '0';
            last = c - '0';
            firstString = "";
            continue;
        }
    }
    printf("Total: %d\n", total);
    return 0;
}

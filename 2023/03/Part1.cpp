//
//  Part1.cpp
//  03
//
//  Created by Jer on 12/19/23.
//

#include <algorithm>
#include <charconv>
#include <fcntl.h>
#include <stdio.h>
#include <string>
#include <optional>
#include <vector>
#include <assert.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <ranges>
#include <string_view>

using namespace std;

char* readFile(char* path)
{
    int fd = open(path, O_RDONLY);

    struct stat s;
    if (-1 == fstat(fd, &s))
        return nullptr;

    return (char *)mmap(0, s.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
}

std::optional<int> to_int(const std::string_view& input)
{
    int out;
    auto result = std::from_chars(input.data(), input.data() + input.size(), out);
    if(result.ec == std::errc::invalid_argument || result.ec == std::errc::result_out_of_range)
        return std::nullopt;
    return out;
}

struct Location {
    int x { 0 };
    int y { 0 };
    int length { 0 };

    int minX() const { return x; }
    int maxX() const { return x + length; }
};

using NumberLocation = pair<int, Location>;

constexpr auto Numbers = "0123456789"sv;

int main(int argc, char *argv[])
{
    auto* input = readFile(argv[1]);
    string_view range { input };

    vector<NumberLocation> numberLocations;
    vector<Location> symbolLocations;

    int y = 0;
    for (auto splitLine : views::split(range, '\n')) {
        string_view line { splitLine };
        int x = 0;
        do {
            auto i = line.find_first_not_of('.');
            if (i == string_view::npos) {
                break;
            }

            line.remove_prefix(i);
            x += i;

            if (line[0] < '0' || line[0] > '9') {
                symbolLocations.push_back({ x, y, 1 });
                line.remove_prefix(1);
                ++x;
                continue;
            }

            i = line.find_first_not_of(Numbers);
            if (i == string_view::npos)
                i = line.length();
            auto possibleNumber = to_int(line.substr(0, i));
            line.remove_prefix(i);

            if (!possibleNumber)
                continue;

            numberLocations.push_back({ *possibleNumber, { x, y, (int)i - 1 } });
            x += i;
        } while(line.length());

        ++y;
    }

    auto isPartNumber = [&](auto& numberLocation) {
        return ranges::any_of(symbolLocations, [&](auto& symbolLocation) {
            return symbolLocation.y >= numberLocation.second.y - 1
                && symbolLocation.y <= numberLocation.second.y + 1
                && symbolLocation.x >= numberLocation.second.minX() - 1
                && symbolLocation.x <= numberLocation.second.maxX() + 1;
        });
    };

    int score = 0;
    for (auto& partNumber : numberLocations | views::filter(isPartNumber)) {
        score += partNumber.first;
    }

    printf("Total: %d\n", score);

    return 0;
}

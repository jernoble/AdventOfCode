//
//  Part2.cpp
//  02
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

constexpr int MaxRed = 12;
constexpr int MaxGreen = 13;
constexpr int MaxBlue = 14;
constexpr int MaxTotal = MaxRed + MaxGreen + MaxBlue;

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

struct RGB {
    int red { 0 };
    int green { 0 };
    int blue { 0 };
};

RGB scoreGame(const std::string_view& game)
{
    int blue = 0;
    int green = 0;
    int red = 0;

    for (auto colorSplit : views::split(game, ", "sv)) {
        string_view color { colorSplit };
        auto i = color.find(' ');
        if (i == string_view::npos)
            continue;

        auto count = to_int(color.substr(0, i));
        if (!count)
            continue;

        color.remove_prefix(i + 1);
        if (color == "blue")
            blue = *count;
        else if (color == "green")
            green = *count;
        else if (color == "red")
            red = *count;
    }
    return { red, green, blue };
}

int main(int argc, char *argv[])
{
    auto* input = readFile(argv[1]);
    string_view range { input };
    int score = 0;

    for (auto splitLine : views::split(range, '\n')) {
        // "Game XX: "
        string_view line { splitLine };
        auto i = line.find(' ');
        if (i != 4)
            continue;

        line.remove_prefix(i + 1);
        i = line.find(": ");

        auto gameNumber = to_int(line.substr(0, i));
        if (!gameNumber)
            continue;

        line.remove_prefix(i + 2);

        RGB maxScore;
        for (auto splitGame : views::split(line, "; "sv)) {
            auto score = scoreGame(string_view { splitGame });
            maxScore.red = max(maxScore.red, score.red);
            maxScore.green = max(maxScore.green, score.green);
            maxScore.blue = max(maxScore.blue, score.blue);
        }
        auto power = maxScore.red * maxScore.green * maxScore.blue;
        score += power;
    }

    printf("Total: %d\n", score);

    return 0;
}

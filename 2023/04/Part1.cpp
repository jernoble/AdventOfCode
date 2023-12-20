//
//  Part1.cpp
//  03
//
//  Created by Jer on 12/19/23.
//

#include <deque>
#include <algorithm>
#include <charconv>
#include <fcntl.h>
#include <set>
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

constexpr auto Numbers = "0123456789"sv;

int main(int argc, char *argv[])
{
    auto* input = readFile(argv[1]);
    string_view range { input };
    int score = 0;
    deque<int> extras;

    for (auto splitLine : views::split(range, '\n')) {
        auto line = string_view { splitLine };
        auto i = line.find(": ");
        if (i == string_view::npos)
            continue;

        line.remove_prefix(i + 2);
        i = line.find(" | ");
        auto setANumbers = line.substr(0, i)
            | views::split(' ')
            | views::transform([] (auto&& part) { return string_view { part }; })
            | views::transform(to_int)
            | views::filter([] (const auto& part) { return !!part; })
            | views::transform([] (auto&& part) { return *part; });

        set<int> setA;
        setA.insert(setANumbers.begin(), setANumbers.end());

        auto setBNumbers = line.substr(i + 3)
            | views::split(' ')
            | views::transform([] (auto&& part) { return string_view { part }; })
            | views::transform(to_int)
            | views::filter([] (const auto& part) { return !!part; })
            | views::transform([] (auto&& part) { return *part; });

        set<int> setB;
        setB.insert(setBNumbers.begin(), setBNumbers.end());

        setA.merge(setB);
        auto matches = setB.size();

        int multiplier = 1;
        if (!extras.empty()) {
            multiplier += extras.front();
            extras.pop_front();
        }

        score += multiplier;

        if (!matches)
            continue;

        auto moreExtras = deque<int>(matches, multiplier);
        if (extras.size() < matches)
            extras.resize(matches, 0);
        ranges::transform(moreExtras, extras, extras.begin(), plus { });
    }

    printf("Total: %d\n", score);

    return 0;
}

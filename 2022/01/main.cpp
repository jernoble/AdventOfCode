#include <ostream>
#include <vector>
#include <iostream>
#include <numeric>

using namespace std;

using Elf = vector<uint32_t>;
using ElfVector = vector<Elf>;

istream &operator>>(istream &is, Elf& elf)
{
	uint32_t input;
	while (is >> input) {
		elf.push_back(input);

		if (is.get() != '\n')
			break;

		if (is.peek() == '\n')
			break;
	}

	return is;
}

ostream &operator<<(ostream &os, const Elf& elf)
{
	if (elf.empty()) {
		os << "[ ]";
		return os;
	}

	os << "[ " << elf[0];
	for (size_t i = 1; i < elf.size(); ++i)
		os << ", " << elf[i];
	os << " ]";
	return os;
}


uint32_t sum(const Elf& elf)
{
	return accumulate(elf.begin(), elf.end(), 0);
}

uint32_t summer(uint32_t current, const Elf& elf)
{
	return current + sum(elf);
}

int main()
{
	ElfVector elves;
	Elf elf;
	while (cin >> elf) {
		elves.push_back(std::move(elf));
	}

	sort(elves.begin(), elves.end(), [](auto& elf1, auto& elf2){ return sum(elf1) > sum(elf2); });

	cerr << "Found " << elves.size() << " elves" << endl
		<< "max: " << sum(elves[0]) << endl
		<< "top 3: " << accumulate(&elves[0], &elves[3], 0, summer) << endl;

	return 0;
}
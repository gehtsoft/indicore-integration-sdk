#include "../stdafx.h"
#include "CsvTickDataParser.h"
#include "Utils.h"

std::string const& CSVRow::operator[](std::size_t index) const
{
    return mData[index];
}

std::size_t CSVRow::size() const
{
    return mData.size();
}

void CSVRow::readNextRow(std::istream& str)
{
    std::string line;
    std::getline(str, line);

    std::stringstream lineStream(line);
    std::string cell;

    mData.clear();
    while (std::getline(lineStream, cell, ';'))
    {
        mData.push_back(cell);
    }
    // This checks for a trailing comma with no data after it.
    if (!lineStream && cell.empty())
    {
        // If there was a trailing comma then add an empty element.
        mData.push_back("");
    }
}

std::istream& operator>>(std::istream& str, CSVRow& data)
{
    data.readNextRow(str);
    return str;
}

CsvTickDataLoader::CsvTickDataLoader(const char *filePath): mFilePath(filePath)
{
}

CsvTickDataLoader::~CsvTickDataLoader()
{
    if (mFile.is_open())
        mFile.close();
}

bool CsvTickDataLoader::init()
{
    mFile.open(mFilePath.c_str());
    if (mFile.fail())
        return false;

    mTickCount = std::count(std::istreambuf_iterator<char>(mFile),
        std::istreambuf_iterator<char>(), '\n') - 1; //without header;


    mFile.clear();
    mFile.seekg(0, mFile.beg);

    std::string str;
    std::getline(mFile, str); // skip the first line

    return true;
}

bool CsvTickDataLoader::loadNextTick(indicore3::TickPriceStorage *priceStorage)
{
    if (mFile.eof())
        return false;

    CSVRow row;
    if (mFile >> row)
    {
        double dtTime;
        if (!Utils::constructDate(row[0], dtTime))\
            return false;

        double ask = strToDbl(row[1]);
        double bid = strToDbl(row[2]);

        priceStorage->addTick(dtTime, ask, bid);
    }

    return true;
}

bool CsvTickDataLoader::loadNextTicks(indicore3::TickPriceStorage *priceStorage, std::size_t count)
{
    do 
    {
        if (!loadNextTick(priceStorage))
            return false;
        --count;
    } while (count > 0);

    return true;
}

std::size_t CsvTickDataLoader::getTicksCount() const
{
    return mTickCount;
}

double CsvTickDataLoader::strToDbl(const std::string &str)
{
    return std::atof(str.c_str());
}
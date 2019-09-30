#pragma once

class CSVRow
{
 public:
    std::string const& operator[](std::size_t index) const;
    std::size_t size() const;
    void readNextRow(std::istream& str);
 private:
    std::vector<std::string> mData;
};

class CsvTickDataLoader
{
    std::string mFilePath;
    std::ifstream mFile;
    std::size_t mTickCount;

 public:
    CsvTickDataLoader(const char *filePath);
    ~CsvTickDataLoader();
    bool init();
    bool loadNextTick(indicore3::TickPriceStorage *priceStorage);
    bool loadNextTicks(indicore3::TickPriceStorage *priceStorage, std::size_t count);
    std::size_t getTicksCount() const;

 private:
    double strToDbl(const std::string &str);
};
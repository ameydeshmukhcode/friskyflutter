class OrderHeader
{
  String time;
  int rank;

  OrderHeader(String time, int rank)
  {
    this.time = time;
    this.rank = rank;
  }

  String getTime()
  {
    return time;
  }

  int getRank()
  {
    return rank;
  }
}
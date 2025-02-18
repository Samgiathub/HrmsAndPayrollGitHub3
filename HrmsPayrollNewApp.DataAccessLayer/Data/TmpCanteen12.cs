using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpCanteen12
{
    public decimal EmpId { get; set; }

    public int? TotalTeaCoffeeCount { get; set; }

    public decimal? GrdId { get; set; }

    public int? ExtraTeaCoffee { get; set; }

    public decimal? TotalExtraTeaCoffeeAmount { get; set; }

    public decimal? GstPercentTeaCoffee { get; set; }

    public decimal? GstTeaCoffeeAmount { get; set; }

    public decimal? NetTeaCoffeeAmount { get; set; }
}

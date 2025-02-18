using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpCanteen21
{
    public decimal EmpId { get; set; }

    public int? TotalLunchCount { get; set; }

    public decimal? GrdId { get; set; }

    public int? ExtraLunch { get; set; }

    public decimal? TotalExtraLunchAmount { get; set; }

    public decimal? GstPercentLunch { get; set; }

    public decimal? GstLunchAmount { get; set; }

    public decimal? NetLunchAmount { get; set; }
}

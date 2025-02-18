using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpCanteen9
{
    public decimal EmpId { get; set; }

    public int? TotalDinneerCount { get; set; }

    public decimal? GrdId { get; set; }

    public int? ExtraDinneer { get; set; }

    public decimal? TotalExtraDinneerAmount { get; set; }

    public decimal? GstPercentDinneer { get; set; }

    public decimal? GstDinneerAmount { get; set; }

    public decimal? NetDinneerAmount { get; set; }
}

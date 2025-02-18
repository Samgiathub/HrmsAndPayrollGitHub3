using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpCanteen8
{
    public decimal EmpId { get; set; }

    public int? TotalDinnerCount { get; set; }

    public decimal? GrdId { get; set; }

    public int? ExtraDinner { get; set; }

    public decimal? TotalExtraDinnerAmount { get; set; }

    public decimal? GstPercentDinner { get; set; }

    public decimal? GstDinnerAmount { get; set; }

    public decimal? NetDinnerAmount { get; set; }
}

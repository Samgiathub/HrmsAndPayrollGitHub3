using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0051RetaintionRateDetail
{
    public decimal RrateDetailId { get; set; }

    public decimal? RrateId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? BranchId { get; set; }

    public string? Mode { get; set; }

    public decimal? Amount { get; set; }

    public decimal? FromLimit { get; set; }

    public decimal? ToLimit { get; set; }
}

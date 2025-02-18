using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040WeekoffMaster
{
    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? WeekoffDay { get; set; }

    public string WeekoffName { get; set; } = null!;

    public decimal CmpId { get; set; }
}

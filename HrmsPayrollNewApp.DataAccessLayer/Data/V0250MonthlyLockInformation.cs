using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0250MonthlyLockInformation
{
    public decimal LockId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal Month { get; set; }

    public decimal? Year { get; set; }

    public decimal IsLock { get; set; }

    public decimal UserId { get; set; }

    public DateTime SystemDate { get; set; }
}

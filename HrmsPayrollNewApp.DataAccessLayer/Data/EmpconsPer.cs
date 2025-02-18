using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class EmpconsPer
{
    public long? Rn { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? IncrementId { get; set; }
}

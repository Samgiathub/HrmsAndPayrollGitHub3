using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetEmployeeOfBranch
{
    public decimal LoginId { get; set; }

    public string LoginName { get; set; } = null!;

    public string LoginPassword { get; set; } = null!;

    public decimal BranchId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }
}

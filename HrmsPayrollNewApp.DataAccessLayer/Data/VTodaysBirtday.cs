using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class VTodaysBirtday
{
    public string? EmpFullName { get; set; }

    public string? DateOfBirth { get; set; }

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public string? WorkEmail { get; set; }

    public decimal CmpId { get; set; }
}

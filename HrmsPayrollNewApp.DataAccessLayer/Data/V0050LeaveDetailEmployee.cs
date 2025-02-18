using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050LeaveDetailEmployee
{
    public decimal GrdId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string GrdName { get; set; } = null!;

    public string LeaveName { get; set; } = null!;

    public decimal LeaveDays { get; set; }

    public decimal LeaveId { get; set; }
}

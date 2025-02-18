using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050LeaveDetailsEmployee
{
    public decimal EmpId { get; set; }

    public decimal GrdId { get; set; }

    public string? EmpFullName { get; set; }

    public string LeaveName { get; set; } = null!;

    public decimal CmpId { get; set; }
}

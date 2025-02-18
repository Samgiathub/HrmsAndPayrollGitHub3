using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050LeaveEmployeeDetail
{
    public string? LeaveName { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? GrdId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? LeaveId { get; set; }

    public decimal LeaveDays { get; set; }
}

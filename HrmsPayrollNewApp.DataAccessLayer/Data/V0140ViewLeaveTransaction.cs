using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140ViewLeaveTransaction
{
    public decimal? TotalUsedLeave { get; set; }

    public decimal LeaveDays { get; set; }

    public decimal LeaveId { get; set; }

    public decimal EmpId { get; set; }

    public decimal GrdId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? Balance { get; set; }

    public string LeaveName { get; set; } = null!;

    public string LeaveCode { get; set; } = null!;

    public decimal LeaveOpDays { get; set; }
}

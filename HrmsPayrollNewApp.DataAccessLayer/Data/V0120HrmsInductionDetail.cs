using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120HrmsInductionDetail
{
    public DateTime ScheduleDate { get; set; }

    public int InductionId { get; set; }

    public int CmpId { get; set; }

    public string FromTime { get; set; } = null!;

    public string ToTime { get; set; } = null!;

    public string DeptName { get; set; } = null!;

    public string? EmployeeName { get; set; }
}

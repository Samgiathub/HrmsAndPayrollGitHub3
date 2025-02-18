using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120HrmsInductionDetail
{
    public int InductionId { get; set; }

    public int CmpId { get; set; }

    public string EmpId { get; set; } = null!;

    public DateTime ScheduleDate { get; set; }

    public DateTime? FromTime { get; set; }

    public DateTime? ToTime { get; set; }

    public int DeptId { get; set; }

    public string ContactPersonId { get; set; } = null!;
}

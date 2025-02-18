using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120RecruitmentInductionDetail
{
    public DateTime ScheduleDate { get; set; }

    public int InductionId { get; set; }

    public int CmpId { get; set; }

    public string EmpId { get; set; } = null!;

    public string ContactPersonId { get; set; } = null!;

    public string FromTime { get; set; } = null!;

    public string ToTime { get; set; } = null!;

    public string DeptName { get; set; } = null!;

    public decimal DeptId { get; set; }

    public string? EmployeeName { get; set; }

    public string? ContactPersonName { get; set; }
}

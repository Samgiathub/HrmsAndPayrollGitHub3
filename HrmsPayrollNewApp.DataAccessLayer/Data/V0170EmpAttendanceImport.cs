using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0170EmpAttendanceImport
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal Month { get; set; }

    public decimal Year { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal BranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal PresentDays { get; set; }

    public decimal Absent { get; set; }

    public decimal WeeklyOff { get; set; }

    public decimal Holiday { get; set; }

    public string AttDetail { get; set; } = null!;
}

using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TempDatum
{
    public long? RowId { get; set; }

    public string DeptName { get; set; } = null!;

    public string? BranchName { get; set; }

    public string? MonthName { get; set; }

    public string? EmpList { get; set; }

    public string? TotalHours { get; set; }

    public string? TotalDtHours { get; set; }
}

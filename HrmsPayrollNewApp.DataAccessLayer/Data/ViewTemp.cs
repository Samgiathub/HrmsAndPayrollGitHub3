using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewTemp
{
    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal ShiftId { get; set; }

    public string ShiftName { get; set; } = null!;

    public string ShiftStTime { get; set; } = null!;

    public string ShiftEndTime { get; set; } = null!;

    public string ShiftDur { get; set; } = null!;

    public string? EmpLeft { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal CmpId { get; set; }
}

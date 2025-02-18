using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ExmptTable
{
    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? BranchName { get; set; }

    public string? GrdName { get; set; }

    public string? DesigName { get; set; }

    public string? DeptName { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public string? CmpName { get; set; }

    public string? CmpAddress { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? OutTime { get; set; }

    public DateTime? ShiftStTime { get; set; }

    public DateTime? ShiftEndTime { get; set; }

    public string? LateHours { get; set; }

    public string? EarlyHours { get; set; }

    public string? LateLimit { get; set; }

    public string? EarlyLimit { get; set; }

    public string? LateDeduction { get; set; }

    public string? EarlyDeduction { get; set; }

    public DateTime? ForDate { get; set; }

    public string? TypeName { get; set; }

    public string? VerticalName { get; set; }

    public string? SubVerticalName { get; set; }

    public string? BranchAddress { get; set; }

    public string? CompName { get; set; }

    public string? DeptDisNo { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? ExemptFlag { get; set; }
}

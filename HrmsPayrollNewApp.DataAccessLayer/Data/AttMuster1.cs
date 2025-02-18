using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class AttMuster1
{
    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public string? Status { get; set; }

    public decimal? LeaveCount { get; set; }

    public string? WoHo { get; set; }

    public string? Status2 { get; set; }

    public decimal? RowId { get; set; }

    public decimal? WoHoDay { get; set; }

    public decimal? PDays { get; set; }

    public decimal? ADays { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? BranchAddress { get; set; }

    public string? CompName { get; set; }

    public string? BranchName { get; set; }

    public string? DeptName { get; set; }

    public string GrdName { get; set; } = null!;

    public string? DesigName { get; set; }

    public DateTime? PFromDate { get; set; }

    public DateTime? PToDate { get; set; }

    public decimal BranchId { get; set; }
}

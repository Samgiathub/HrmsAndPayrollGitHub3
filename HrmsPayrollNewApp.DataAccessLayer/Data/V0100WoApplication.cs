using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100WoApplication
{
    public decimal WoApplicationId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal BranchId { get; set; }

    public string? ApplicationDate { get; set; }

    public string? ApplicationStatus { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? Month { get; set; }

    public decimal? Year { get; set; }

    public string Status { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public string MonthName { get; set; } = null!;

    public string EmpFirstName { get; set; } = null!;

    public DateTime? WoDate { get; set; }

    public DateTime? NewWoDate { get; set; }

    public string? NewWoDay { get; set; }

    public string? WoDay { get; set; }

    public decimal? WoApprovalId { get; set; }

    public decimal SupEmpId { get; set; }
}

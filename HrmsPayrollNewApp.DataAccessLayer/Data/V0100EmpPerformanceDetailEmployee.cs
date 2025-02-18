using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100EmpPerformanceDetailEmployee
{
    public decimal OutOfPer { get; set; }

    public decimal Percentage { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public int? Month { get; set; }

    public int? Year { get; set; }

    public decimal CmpId { get; set; }

    public decimal PerIncTranId { get; set; }

    public decimal PerDetailId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal BranchId { get; set; }

    public string PerName { get; set; } = null!;

    public string ApproveFrom { get; set; } = null!;

    public decimal? EmpSuperior { get; set; }

    public decimal LoginId { get; set; }

    public string? LoginName { get; set; }

    public decimal? REmpId { get; set; }

    public decimal EmpCode { get; set; }
}

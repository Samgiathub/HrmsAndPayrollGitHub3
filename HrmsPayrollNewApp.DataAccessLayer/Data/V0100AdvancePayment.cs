using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100AdvancePayment
{
    public decimal AdvId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal AdvAmount { get; set; }

    public decimal AdvPDays { get; set; }

    public decimal AdvApproxSalary { get; set; }

    public string AdvComments { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? EmpFirstName { get; set; }

    public decimal EmpId { get; set; }

    public decimal? EmpCode { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal BranchId { get; set; }

    public string? ReasonName { get; set; }

    public int? ResId { get; set; }

    public decimal? AdvApprovalId { get; set; }
}

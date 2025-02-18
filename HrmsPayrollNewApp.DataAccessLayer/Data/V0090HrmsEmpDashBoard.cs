using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsEmpDashBoard
{
    public decimal GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal LoginId { get; set; }

    public string Initiatedby { get; set; } = null!;

    public decimal EmpId { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public DateTime ForDate { get; set; }

    public decimal CmpId { get; set; }

    public decimal ApprIntId { get; set; }

    public decimal ApprDetailId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? EmpSupName { get; set; }

    public string? DesigName { get; set; }

    public decimal EmpCode { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal BranchId { get; set; }
}

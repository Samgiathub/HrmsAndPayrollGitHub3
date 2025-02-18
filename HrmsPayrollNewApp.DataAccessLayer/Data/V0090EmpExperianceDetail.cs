using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpExperianceDetail
{
    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? DateOfJoin { get; set; }

    public string? BranchName { get; set; }

    public string EmployerName { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public string? StDate { get; set; }

    public string? EndDate { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public string? Branch { get; set; }

    public string? Location { get; set; }

    public string? Manager { get; set; }

    public string? ManagerContactNumber { get; set; }

    public string? ExpRemarks { get; set; }

    public decimal? GrossSalary { get; set; }

    public decimal? CtcAmount { get; set; }

    public decimal? EmpExp { get; set; }
}

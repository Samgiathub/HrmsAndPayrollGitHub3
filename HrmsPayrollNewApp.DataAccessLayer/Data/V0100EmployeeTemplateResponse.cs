using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100EmployeeTemplateResponse
{
    public int? EmpId { get; set; }

    public DateTime? CreatedDate { get; set; }

    public int? TId { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public decimal? DeptId { get; set; }

    public string? DeptName { get; set; }

    public decimal? DesigId { get; set; }

    public string? DesigName { get; set; }
}

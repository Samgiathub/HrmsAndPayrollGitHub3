using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0055HrmsEmpSkillDetail
{
    public decimal SkillRId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string Status { get; set; } = null!;

    public string EmpFirstName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public decimal BranchId { get; set; }

    public string? AlphaEmpCode { get; set; }
}

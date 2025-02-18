using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GetGrievEmpDetail
{
    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? MobileNo { get; set; }

    public decimal? BranchId { get; set; }

    public string? BranchName { get; set; }

    public string? BranchAddress { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string WorkEmail { get; set; } = null!;
}

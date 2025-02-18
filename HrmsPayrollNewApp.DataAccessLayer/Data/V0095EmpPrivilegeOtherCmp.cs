using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0095EmpPrivilegeOtherCmp
{
    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? CmpList { get; set; }

    public decimal? BranchId { get; set; }

    public decimal LoginId { get; set; }
}

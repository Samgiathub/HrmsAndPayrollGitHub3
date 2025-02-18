using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0095DeptHodDetail
{
    public string DeptName { get; set; } = null!;

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? WorkEmail { get; set; }

    public decimal DeptId { get; set; }

    public decimal CmpId { get; set; }
}

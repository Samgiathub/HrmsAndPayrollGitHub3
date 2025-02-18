using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0015LoginRight
{
    public decimal LoginRightsId { get; set; }

    public decimal LoginTypeId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public decimal IsSave { get; set; }

    public decimal IsEdit { get; set; }

    public decimal IsDelete { get; set; }

    public decimal IsReport { get; set; }

    public string LoginType { get; set; } = null!;

    public decimal? BranchId { get; set; }

    public string? BranchName { get; set; }

    public string LoginName { get; set; } = null!;

    public string LoginPassword { get; set; } = null!;

    public decimal? EmpId { get; set; }

    public decimal? IsDefault { get; set; }
}

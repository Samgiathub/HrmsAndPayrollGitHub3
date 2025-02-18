using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040ClaimApplication
{
    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public decimal ClaimId { get; set; }

    public decimal CmpId { get; set; }

    public string ClaimName { get; set; } = null!;

    public decimal ClaimMaxLimit { get; set; }
}

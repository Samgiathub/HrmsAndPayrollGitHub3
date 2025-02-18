using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class P0160BranchNameGet
{
    public string? BranchName { get; set; }

    public string? BranchCode { get; set; }

    public decimal LoginId { get; set; }

    public decimal? BranchId { get; set; }

    public string LoginName { get; set; } = null!;
}

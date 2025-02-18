using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0011LoginShadow
{
    public long AuditId { get; set; }

    public decimal LoginId { get; set; }

    public decimal CmpId { get; set; }

    public string LoginName { get; set; } = null!;

    public string LoginPassword { get; set; } = null!;

    public decimal? EmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? LoginRightsId { get; set; }

    public decimal? IsDefault { get; set; }

    public string AuditAction { get; set; } = null!;

    public DateTime AuditDate { get; set; }

    public string AuditUser { get; set; } = null!;

    public string? AuditApp { get; set; }
}

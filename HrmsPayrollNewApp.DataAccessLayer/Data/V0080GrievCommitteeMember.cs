using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GrievCommitteeMember
{
    public int Gcmid { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpAlpha { get; set; }

    public string? BranchName { get; set; }

    public string? GcmType { get; set; }

    public int? CmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public int? IsActive { get; set; }

    public int? EmpId { get; set; }

    public string StatusColor { get; set; } = null!;
}

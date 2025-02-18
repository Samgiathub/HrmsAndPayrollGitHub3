using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040HrDocMaster
{
    public string? BranchName { get; set; }

    public string? DesigName { get; set; }

    public string? DeptName { get; set; }

    public string? GrdName { get; set; }

    public int? DisplayJoinining { get; set; }

    public string? DocContent { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? CmpId { get; set; }

    public string? DocTitle { get; set; }

    public decimal HrDocId { get; set; }

    public string DisplayJoininingName { get; set; } = null!;

    public string? Gender { get; set; }

    public string GenderName { get; set; } = null!;
}

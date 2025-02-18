using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050HrmsAppraisalSetting
{
    public decimal ApprId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? ActualCtc { get; set; }

    public decimal? Experience { get; set; }

    public decimal? MinAppraisal { get; set; }

    public decimal? MaxAppraisal { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? AppraisalDuration { get; set; }

    public decimal BranchId { get; set; }

    public string BranchName { get; set; } = null!;

    public decimal GrdId { get; set; }

    public string GrdName { get; set; } = null!;

    public decimal? DesigId { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal? DeptId { get; set; }

    public string DeptName { get; set; } = null!;
}
